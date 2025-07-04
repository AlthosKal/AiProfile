import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constant/app_constant.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;
  final bool isAnalysis;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
    this.isAnalysis = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppConstants.paddingVerticalSmall,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isError
                      ? Colors.red.shade700
                      : isAnalysis
                      ? Colors.orange.shade700
                      : Theme.of(context).primaryColor,
              child: Icon(
                isError
                    ? Icons.error_outline
                    : isAnalysis
                    ? Icons.analytics
                    : Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getBubbleColor(context),
                border:
                    isError || isAnalysis
                        ? Border.all(
                          color:
                              isError
                                  ? Colors.red.shade300
                                  : Colors.orange.shade300,
                          width: 1,
                        )
                        : null,
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium,
                ).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Escribiendo...'),
                        ],
                      ),
                    )
                  else
                    Text(
                      message,
                      style: TextStyle(
                        color:
                            isUser
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: TextStyle(
                      color:
                          isUser
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: AppConstants.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade600,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    if (isUser) {
      return Theme.of(context).primaryColor;
    } else if (isError) {
      return Colors.red.shade50;
    } else if (isAnalysis) {
      return Colors.orange.shade50;
    } else {
      return Theme.of(context).cardColor;
    }
  }
}
