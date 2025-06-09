import 'dart:math';

import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset direction;
  double speed;
  double size;
  double opacity;

  Particle({
    required this.position,
    required this.direction,
    this.speed = 2.0,
    this.size = 20.0,
    this.opacity = 0.7,
  });

  void move(Size screenSize) {
    position = position.translate(direction.dx * speed, direction.dy * speed);

    if (position.dx - size / 2 < 0 ||
        position.dx + size / 2 > screenSize.width) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy - size / 2 < 0 ||
        position.dy + size / 2 > screenSize.height) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(particle.position, particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleAnimation extends StatefulWidget {
  const ParticleAnimation({super.key});

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;
  final int numberOfParticles = 40;
  final Random random = Random();
  Size? _screenSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 33), // ~30 FPS
    )..repeat();

    particles = [];
    _controller.addListener(_updateParticles);
  }

  void _initializeParticles() {
    if (_screenSize == null) return;

    particles = List.generate(numberOfParticles, (index) {
      return Particle(
        position: Offset(
          random.nextDouble() * _screenSize!.width,
          random.nextDouble() * _screenSize!.height,
        ),
        direction: _normalizedRandomDirection(),
        speed: 0.1 + random.nextDouble() * 0.1,
        size: 25.0 + random.nextDouble() * 35.0,
        opacity: 0.3 + random.nextDouble() * 0.7,
      );
    });
  }

  Offset _normalizedRandomDirection() {
    final dx = (random.nextDouble() * 2) - 1;
    final dy = (random.nextDouble() * 2) - 1;
    final magnitude = sqrt(dx * dx + dy * dy);
    return Offset(dx / magnitude, dy / magnitude);
  }

  void _updateParticles() {
    if (!mounted || _screenSize == null) return;

    for (var particle in particles) {
      particle.move(_screenSize!);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          if ((_screenSize == null || _screenSize != size)) {
            _screenSize = size;
            _initializeParticles();
          }

          return RepaintBoundary(
            child: CustomPaint(painter: ParticlePainter(particles), size: size),
          );
        },
      ),
    );
  }
}
