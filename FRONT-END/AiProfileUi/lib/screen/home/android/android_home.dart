import 'package:ai_profile_ui/screen/chat/chat_ai_analysis_screen.dart';
import 'package:ai_profile_ui/screen/logic/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controller/home_controller.dart';
import '../../../core/service/app/auth_service.dart';
import '../../../core/service/chat/chat_history_service.dart';
import '../../../dto/chat/rest/chat_history_dto.dart';
import '../../../route/app_routes.dart';

class AndroidHomeScreen extends StatefulWidget {
  const AndroidHomeScreen({super.key});

  @override
  State<AndroidHomeScreen> createState() => _AndroidHomeScreenState();
}

class _AndroidHomeScreenState extends State<AndroidHomeScreen> {
  final HomeController _controller = HomeController();

  final List<Widget> _screens = const [
    TransactionScreen(),
    ChatAiAnalysisScreen(),
  ];

  final List<String> _titles = const ['Mis Transacciones', 'Asistente AI'];

  @override
  void initState() {
    super.initState();

    _controller.selectedIndex.addListener(() {
      setState(() {});
    });

    _controller.currentUser.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _controller.selectedIndex.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'AiProfile, una app financiera con IA integrada',
                  ),
                ),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ✅ SOLUCIÓN 1: DrawerHeader más compacto con mejor distribución del espacio
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ValueListenableBuilder(
                valueListenable: _controller.currentUser,
                builder: (context, user, _) {
                  if (user == null) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    // ✅ Importante: usar solo el espacio necesario
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar y datos del usuario en una fila para ahorrar espacio
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24, // ✅ Reducido de 28 a 24
                            backgroundImage:
                                user.imageUrl != null
                                    ? NetworkImage(user.imageUrl!)
                                    : null,
                            child:
                                user.imageUrl == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: Colors.white,
                                    )
                                    : null,
                            backgroundColor: Colors.grey.shade800,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            // ✅ Usar Expanded para evitar overflow
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // ✅ Manejo de texto largo
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // ✅ Manejo de texto largo
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ✅ Reducido el espaciado
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDrawerActionButton(
                            icon: Icons.person,
                            tooltip: 'Perfil',
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.profile,
                                arguments: _controller,
                              );
                            },
                          ),
                          _buildDrawerActionButton(
                            icon: Icons.logout,
                            tooltip: 'Cerrar sesión',
                            onPressed: () async {
                              final authService = AuthService();
                              await authService.logout();

                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // ✅ SOLUCIÓN 2: Historial de conversaciones optimizado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Conversaciones Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            FutureBuilder<List<ChatHistoryDTO>>(
              future: ChatHistoryService().getAllConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Sin conversaciones aún',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // ✅ Limitar a máximo 5 conversaciones para evitar drawer muy largo
                final limitedConversations = conversations.take(5).toList();

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: limitedConversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = limitedConversations[index];
                    return ListTile(
                      dense: true, // ✅ Hacer los tiles más compactos
                      title: Text(
                        c.prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM HH:mm').format(c.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chatHistory,
                          arguments: c.conversationId,
                        );
                      },
                    );
                  },
                );
              },
            ),

            // ✅ Botón para ver todas las conversaciones si hay más de 5
            FutureBuilder<List<ChatHistoryDTO>>(
              future: ChatHistoryService().getAllConversations(),
              builder: (context, snapshot) {
                final conversations = snapshot.data ?? [];
                if (conversations.length > 5) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navegar a una pantalla de historial completo
                        Navigator.pop(context);
                        // Navigator.pushNamed(context, AppRoutes.fullChatHistory);
                      },
                      child: Text('Ver todas (${conversations.length})'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),

      body: _screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _controller.onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Transacciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Asistente'),
        ],
      ),
    );
  }

  // ✅ Widget helper para los botones del drawer
  Widget _buildDrawerActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
