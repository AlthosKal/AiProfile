import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/service/app/transaction_service.dart';

class TransactionExcelScreen extends StatefulWidget {
  const TransactionExcelScreen({super.key});

  @override
  State<TransactionExcelScreen> createState() => _TransactionExcelScreenState();
}

class _TransactionExcelScreenState extends State<TransactionExcelScreen> {
  final TransactionService _transactionService = TransactionService();

  Future<void> _exportExcel() async {
    try {
      final file = await _transactionService.exportTransactionsToExcel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel exportado correctamente')),
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _importExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        await _transactionService.importTransactionsFromExcel(file);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel importado exitosamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar / Exportar Excel'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _exportExcel,
              icon: const Icon(Icons.download),
              label: const Text('Exportar Transacciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _importExcel,
              icon: const Icon(Icons.upload),
              label: const Text('Importar desde Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
