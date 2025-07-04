import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../dto/chat/request/chat_dto.dart';
import '../../../dto/chat/request/chat_multipart_dto.dart';
import '../../../dto/chat/rest/chat_response_dto.dart';
import '../../../util/enums/model.dart';
import '../../core/constant/app_constant.dart';
import '../../core/service/chat/chat_history_service.dart';
import '../../core/service/chat/chat_service.dart';
import '../../widget/chat_message_bubble.dart';
import '../../widget/custom_card.dart';

class ChatAiAnalysisScreen extends StatefulWidget {
  const ChatAiAnalysisScreen({super.key});

  @override
  State<ChatAiAnalysisScreen> createState() => _ChatAiAnalysisScreenState();
}

class _ChatAiAnalysisScreenState extends State<ChatAiAnalysisScreen> {
  final ChatService _chatService = ChatService();
  final ChatHistoryService _historyService = ChatHistoryService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  Model _selectedModel = Model.OPENAI;
  ChatResponseDTO? _response;
  File? _selectedFile;

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'xlsx', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Archivo seleccionado: ${result.files.single.name}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  void _clearFile() {
    setState(() => _selectedFile = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Archivo removido'),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: prompt));
      _isLoading = true;
    });

    _promptController.clear();
    _scrollToBottom();

    try {
      if (_selectedFile != null) {
        final file = await MultipartFile.fromFile(_selectedFile!.path);
        final dto = ChatMultipartDTO(
          model: _selectedModel,
          conversationId: _conversationId,
          prompt: prompt,
          file: file,
        );
        final res = await _chatService.askAiWithFile(dto);

        setState(() {
          _conversationId = res.conversationId;
          _messages.add(ChatMessage(role: 'assistant', content: res.response));
          _selectedFile = null;
        });
      } else {
        final dto = ChatDTO(
          model: _selectedModel,
          conversationId: _conversationId,
          prompt: prompt,
        );
        final res = await _chatService.askAi(dto);

        setState(() {
          _response = res;
          _conversationId = res.conversationId;
          _messages.add(
            ChatMessage(role: 'assistant', content: res.analysis.response),
          );

          // Si hay análisis automático, agregarlo como mensaje separado
          if (res.analysis.analysis.isNotEmpty) {
            _messages.add(
              ChatMessage(role: 'analysis', content: res.analysis.analysis),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'error',
            content: 'Error: No pude procesar tu solicitud. $e',
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // ✅ MEJORA 1: Selector de modelo más prominente
          _buildEnhancedModelSelector(),

          // ✅ MEJORA 2: Indicador de archivo seleccionado más claro
          if (_selectedFile != null) _buildFileIndicator(),

          // ✅ MEJORA 3: Chat con burbujas - separación visual clara
          Expanded(child: _buildChatMessages()),

          // ✅ MEJORA 4: Input mejorado
          _buildChatInput(),
        ],
      ),
    );
  }

  // ✅ MEJORA 1: Selector de modelo más visible y atractivo
  Widget _buildEnhancedModelSelector() {
    return CustomCard(
      padding: AppConstants.paddingMedium,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.psychology,
              color: Theme.of(context).primaryColor,
              size: AppConstants.iconSizeLarge,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Modelo IA:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppConstants.fontSizeLarge,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: DropdownButton<Model>(
                value: _selectedModel,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                onChanged: (model) {
                  if (model != null) setState(() => _selectedModel = model);
                },
                items:
                    Model.values.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Row(
                          children: [
                            Icon(
                              Icons.smart_toy,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              model.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MEJORA 2: Indicador de archivo más claro y con acción
  Widget _buildFileIndicator() {
    final fileName = _selectedFile!.path.split('/').last;

    return Container(
      margin: AppConstants.paddingHorizontalMedium,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.attach_file,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Archivo adjunto:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearFile,
            icon: Icon(Icons.close, color: Colors.red.shade600, size: 20),
            tooltip: 'Remover archivo',
          ),
        ],
      ),
    );
  }

  // ✅ MEJORA 3: Chat con burbujas y separación visual clara
  Widget _buildChatMessages() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: AppConstants.paddingMedium,
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return ChatMessageBubble(
          message: message.content,
          isUser: message.role == 'user',
          isError: message.role == 'error',
          isAnalysis: message.role == 'analysis',
          timestamp: DateTime.now(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Hola! Soy tu asistente IA',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes preguntarme sobre tus finanzas,\nadjuntar archivos para analizar, o\nsimplemente chatear conmigo.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'IA está escribiendo...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ MEJORA 4: Input mejorado con mejor UX
  Widget _buildChatInput() {
    return Container(
      padding: AppConstants.paddingMedium,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botón de archivo
          Container(
            decoration: BoxDecoration(
              color:
                  _selectedFile != null
                      ? Colors.blue.shade100
                      : Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              border: Border.all(
                color:
                    _selectedFile != null
                        ? Colors.blue.shade300
                        : Theme.of(context).dividerColor,
              ),
            ),
            child: IconButton(
              onPressed: _pickFile,
              icon: Icon(
                Icons.attach_file,
                color:
                    _selectedFile != null ? Colors.blue.shade700 : Colors.grey,
              ),
              tooltip: 'Adjuntar archivo',
            ),
          ),
          const SizedBox(width: 8),

          // Campo de texto expandido
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextField(
                controller: _promptController,
                onSubmitted: (_) => _sendPrompt(),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu pregunta aquí...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de envío
          Container(
            decoration: BoxDecoration(
              color:
                  _promptController.text.isNotEmpty && !_isLoading
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendPrompt,
              icon:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade600,
                          ),
                        ),
                      )
                      : const Icon(Icons.send, color: Colors.white),
              tooltip: 'Enviar mensaje',
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para representar mensajes del chat
class ChatMessage {
  final String role; // 'user', 'assistant', 'analysis', 'error'
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
