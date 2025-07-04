import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constant/app_constant.dart';
import '../../core/constant/app_theme.dart';
import '../../core/service/chat/chat_history_service.dart';
import '../../dto/chat/rest/chat_history_dto.dart';
import '../../widget/custom_card.dart';
import '../../widget/empty_state.dart';

class ChatHistoryScreen extends StatefulWidget {
  final String conversationId;

  const ChatHistoryScreen({super.key, required this.conversationId});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatHistoryService _chatHistoryService = ChatHistoryService();
  late Future<List<ChatHistoryDTO>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _chatHistoryService.getHistoryByConversationId(
      widget.conversationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial del Chat'),
        elevation: 0,
      ),
      body: FutureBuilder<List<ChatHistoryDTO>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el historial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: context.errorColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _historyFuture = _chatHistoryService
                            .getHistoryByConversationId(widget.conversationId);
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Sin mensajes',
              subtitle: 'No hay mensajes en esta conversación aún',
            );
          }

          return ListView.separated(
            padding: AppConstants.paddingLarge,
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final message = history[index];
              return _buildMessageCard(context, message, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, ChatHistoryDTO message, int index) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con timestamp y número de mensaje
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  'Mensaje #${index + 1}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy • HH:mm').format(message.date),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User prompt
          _buildPromptBubble(context, message.prompt),
          const SizedBox(height: 12),

          // AI response
          _buildResponseBubble(context, message.response),
        ],
      ),
    );
  }

  Widget _buildPromptBubble(BuildContext context, String prompt) {
    return Container(
      width: double.infinity,
      padding: AppConstants.paddingMedium,
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tu pregunta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBubble(BuildContext context, String response) {
    return Container(
      width: double.infinity,
      padding: AppConstants.paddingMedium,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Respuesta IA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
