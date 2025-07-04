import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controller/home_controller.dart';
import '../../core/constant/app_constant.dart';
import '../../core/constant/app_theme.dart';
import '../../core/service/app/profile_service.dart';
import '../../widget/custom_card.dart';
import '../../widget/loading_button.dart';

class UserDetails extends StatefulWidget {
  final HomeController controller;

  const UserDetails({super.key, required this.controller});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final ProfileService _profileService = ProfileService();
  bool _isUpdatingImage = false;
  bool _isDeletingImage = false;

  Future<void> _updateImage() async {
    setState(() => _isUpdatingImage = true);
    
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        final file = File(picked.path);
        await _profileService.updateProfileImage(file);
        await widget.controller.loadCurrentUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: context.incomeColor),
                  const SizedBox(width: 8),
                  const Text('Imagen actualizada exitosamente'),
                ],
              ),
              backgroundColor: context.incomeColor.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: context.errorColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al actualizar imagen: $e')),
              ],
            ),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingImage = false);
    }
  }

  Future<void> _deleteImage() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;
    
    setState(() => _isDeletingImage = true);
    
    try {
      await _profileService.deleteProfileImage();
      await widget.controller.loadCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Imagen eliminada'),
              ],
            ),
            backgroundColor: context.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: context.errorColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al eliminar imagen: $e')),
              ],
            ),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingImage = false);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar imagen?'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu imagen de perfil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showImageOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: AppConstants.paddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Opciones de imagen',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: context.primaryColor,
                ),
              ),
              title: const Text('Seleccionar de galería'),
              subtitle: const Text('Elige una foto desde tu galería'),
              onTap: () {
                Navigator.pop(context);
                _updateImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: context.primaryColor,
                ),
              ),
              title: const Text('Tomar foto'),
              subtitle: const Text('Usa la cámara para tomar una nueva foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() => _isUpdatingImage = true);
    
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        final file = File(picked.path);
        await _profileService.updateProfileImage(file);
        await widget.controller.loadCurrentUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: context.incomeColor),
                  const SizedBox(width: 8),
                  const Text('Imagen actualizada exitosamente'),
                ],
              ),
              backgroundColor: context.incomeColor.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: context.errorColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al tomar foto: $e')),
              ],
            ),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.controller.isLoading,
        builder: (_, isLoading, __) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ValueListenableBuilder(
            valueListenable: widget.controller.currentUser,
            builder: (_, user, __) {
              if (user == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudieron cargar los datos del usuario',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: AppConstants.paddingLarge,
                child: Column(
                  children: [
                    // Header con avatar y acciones
                    _buildProfileHeader(user),
                    const SizedBox(height: 32),
                    
                    // Información del usuario
                    _buildUserInfo(user),
                    const SizedBox(height: 24),
                    
                    // Estadísticas rápidas
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    
                    // Acciones de la cuenta
                    _buildAccountActions(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return CustomCard(
      child: Column(
        children: [
          // Avatar con indicador de loading para imagen
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.primaryColor,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user.imageUrl != null
                      ? NetworkImage(user.imageUrl!)
                      : null,
                  backgroundColor: context.primaryColor.withOpacity(0.1),
                  child: user.imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: context.primaryColor,
                        )
                      : null,
                ),
              ),
              if (_isUpdatingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              // Botón de editar imagen
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    onPressed: _isUpdatingImage ? null : () => _showImageOptionsBottomSheet(context),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Nombre y email
          Text(
            user.username,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Botones de acción para imagen
          if (user.imageUrl != null)
            LoadingButton(
              text: 'Eliminar Imagen',
              isLoading: _isDeletingImage,
              onPressed: _deleteImage,
              backgroundColor: context.errorColor,
              icon: Icons.delete_outline,
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(user) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Información de la Cuenta',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nombre de usuario', user.username, Icons.person),
          const SizedBox(height: 16),
          _buildInfoRow('Correo electrónico', user.email, Icons.email),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Fecha de registro',
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 20,
            color: context.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Estadísticas Rápidas',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Transacciones',
                  '0', // TODO: Implementar contador real
                  Icons.receipt_long,
                  context.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Consultas IA',
                  '0', // TODO: Implementar contador real
                  Icons.smart_toy,
                  Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: AppConstants.paddingMedium,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppConstants.iconSizeLarge,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Configuración de Cuenta',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionTile(
            'Cambiar contraseña',
            'Actualiza tu contraseña de acceso',
            Icons.lock_outline,
            () {
              // TODO: Implementar cambio de contraseña
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función no implementada aún'),
                ),
              );
            },
          ),
          const Divider(),
          _buildActionTile(
            'Notificaciones',
            'Configura tus preferencias de notificaciones',
            Icons.notifications_outlined,
            () {
              // TODO: Implementar configuración de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función no implementada aún'),
                ),
              );
            },
          ),
          const Divider(),
          _buildActionTile(
            'Privacidad y seguridad',
            'Administra la privacidad de tu cuenta',
            Icons.security,
            () {
              // TODO: Implementar configuración de privacidad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función no implementada aún'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Icon(
          icon,
          color: context.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: AppConstants.fontSizeSmall,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
