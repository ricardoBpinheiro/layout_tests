import 'package:flutter/material.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Conteúdo da página de Configurações',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
