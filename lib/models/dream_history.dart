import 'package:hive/hive.dart';

part 'dream_history.g.dart';

@HiveType(typeId: 0)
class DreamHistory extends HiveObject {
  @HiveField(0)
  final String dream;

  @HiveField(1)
  final String interpretation;

  @HiveField(2)
  final DateTime timestamp;

  DreamHistory({
    required this.dream,
    required this.interpretation,
    required this.timestamp,
  });
}
