import 'package:hive/hive.dart';
import '../models/dream_history.dart';

class DreamHistoryService {
  // Uygulama başlangıcında açılan kutuyu al
  final Box<DreamHistory> _historyBox = Hive.box('dream_history');

  // Yeni bir rüyayı geçmişe kaydet
  Future<void> saveDream(String dream, String interpretation) async {
    try {
      final newHistory = DreamHistory(
        dream: dream,
        interpretation: interpretation,
        timestamp: DateTime.now(),
      );
      await _historyBox.add(newHistory);
    } catch (e) {
      print('Error saving dream to history: $e');
      // İsteğe bağlı olarak hatayı yeniden fırlatabilir veya işleyebilirsiniz
    }
  }

  // Geçmişteki tüm rüyaları al (en yeniden eskiye sıralı)
  List<DreamHistory> getDreamHistory() {
    try {
      // Hive kutuları sırayı garanti etmez, bu yüzden manuel olarak sıralıyoruz.
      var dreams = _historyBox.values.toList();
      dreams.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return dreams;
    } catch (e) {
      print('Error getting dream history: $e');
      return [];
    }
  }

  // Tüm geçmişi temizle
  Future<void> clearHistory() async {
    try {
      await _historyBox.clear();
    } catch (e) {
      print('Error clearing dream history: $e');
    }
  }
}
