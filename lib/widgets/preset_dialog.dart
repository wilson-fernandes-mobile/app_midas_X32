import 'package:flutter/material.dart';

/// Dialog para salvar ou editar um preset
class PresetDialog extends StatefulWidget {
  final String? initialName; // Nome inicial (para edição)
  final String title; // Título do dialog
  final String confirmButtonText; // Texto do botão de confirmação

  const PresetDialog({
    super.key,
    this.initialName,
    this.title = 'Salvar Preset',
    this.confirmButtonText = 'Salvar',
  });

  @override
  State<PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<PresetDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.bookmark,
            color: Color(0xFFFF723A),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Digite um nome para o preset:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: Vocal Principal',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(
                  Icons.label,
                  color: Color(0xFFFF723A),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF723A),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite um nome para o preset';
                }
                if (value.trim().length < 3) {
                  return 'Nome muito curto (mínimo 3 caracteres)';
                }
                if (value.trim().length > 50) {
                  return 'Nome muito longo (máximo 50 caracteres)';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF723A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.confirmButtonText),
        ),
      ],
    );
  }
}

/// Mostra o dialog para salvar um novo preset
Future<String?> showSavePresetDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const PresetDialog(
      title: 'Salvar Preset',
      confirmButtonText: 'Salvar',
    ),
  );
}

/// Mostra o dialog para editar um preset existente
Future<String?> showEditPresetDialog(BuildContext context, String currentName) {
  return showDialog<String>(
    context: context,
    builder: (context) => PresetDialog(
      title: 'Editar Preset',
      confirmButtonText: 'Atualizar',
      initialName: currentName,
    ),
  );
}

