import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool remindersEnabled = true;
  String storageMethod = 'Shared Preferences';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A2342),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Enable Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                    Switch(
                      value: remindersEnabled,
                      activeColor: const Color(0xFFFFC700),
                      onChanged: (val) {
                        setState(() {
                          remindersEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Storage Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                const SizedBox(height: 8),
                Text(storageMethod, style: const TextStyle(fontSize: 16, color: Color(0xFF0A2342))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
