import 'package:flutter/material.dart';
import 'package:popbash/core/theme/settings_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _asciiController = TextEditingController();

  final Map<String, Color> _themes = {
    'tokyo_night': const Color(0xFF89B4FA), // Azul
    'hacker_green': const Color(0xFFA6E3A1), // Verde
    'cyberpunk': const Color(0xFFF38BA8), // Rosa/Rojo
    'dracula': const Color(0xFFCBA6F7), // Morado
    'gruvbox': const Color(0xFFFAB387), // Naranja
  };

  @override
  void dispose() {
    _asciiController.dispose();
    super.dispose();
  }

  void _editAscii() {
    _asciiController.text = SettingsService().customAsciiNotifier.value;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('nano custom_logo.txt', style: TextStyle(color: Colors.white, fontSize: 14)),
          content: TextField(
            controller: _asciiController,
            maxLines: 8,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            decoration: const InputDecoration(
              hintText: 'Paste your custom ASCII art here...',
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF313244))),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF89B4FA))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('[CANCEL]', style: TextStyle(color: Color(0xFFF38BA8))),
            ),
            TextButton(
              onPressed: () {
                SettingsService().updateAscii(_asciiController.text);
                Navigator.pop(context);
              },
              child: const Text('[SAVE]', style: TextStyle(color: Color(0xFFA6E3A1))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('user@popbash:~/config\$ nano user.conf'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<Color>(
          valueListenable: SettingsService().primaryColorNotifier,
          builder: (context, primaryColor, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('# PopBash Global Configuration', style: TextStyle(color: Color(0xFF6C7086))),
                const Text('# User: root | Editor: nano', style: TextStyle(color: Color(0xFF6C7086))),
                const SizedBox(height: 24),
                
                // Color Theme selection
                const Text('theme_color = [', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themes.entries.map((entry) {
                    final isSelected = primaryColor == entry.value;
                    return InkWell(
                      onTap: () => SettingsService().updateColor(entry.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? entry.value : Colors.transparent,
                          border: Border.all(color: entry.value),
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1E1E2E) : entry.value,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                const Text(']', style: TextStyle(fontSize: 16)),
                
                const SizedBox(height: 32),
                
                // ASCII Art customization
                const Text('custom_ascii_logo = "', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _editAscii,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF313244)),
                      color: const Color(0xFF181825),
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: SettingsService().customAsciiNotifier,
                      builder: (context, ascii, _) {
                        return Text(
                          ascii.isEmpty ? 'TAP TO EDIT CUSTOM ASCII' : ascii,
                          style: TextStyle(
                            color: ascii.isEmpty ? const Color(0xFF6C7086) : primaryColor,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('"', style: TextStyle(fontSize: 16)),

                const Spacer(),
                const Divider(color: Color(0xFF313244)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('^X Exit', style: TextStyle(color: Colors.white)),
                    Text('^O WriteOut', style: TextStyle(color: Colors.white)),
                    Text('^W WhereIs', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
