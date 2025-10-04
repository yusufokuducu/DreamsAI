import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Geçmiş',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz rüya yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yorumlanan rüyalar burada görünecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
