import 'dart:convert';

class SavedRecord {
  final String id;
  final String name;        // Borrower / person name
  final String note;        // Optional note
  final int liekoSal;
  final int liekoMahina;
  final int liekoGate;
  final int bhujaauneSal;
  final int bhujaauneMahina;
  final int bhujaaune_Gate;
  final double mulDhan;
  final double byajDar;
  final double jammaByaj;
  final double totalAmount;
  final DateTime savedAt;

  const SavedRecord({
    required this.id,
    required this.name,
    required this.note,
    required this.liekoSal,
    required this.liekoMahina,
    required this.liekoGate,
    required this.bhujaauneSal,
    required this.bhujaauneMahina,
    required this.bhujaaune_Gate,
    required this.mulDhan,
    required this.byajDar,
    required this.jammaByaj,
    required this.totalAmount,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'note': note,
        'liekoSal': liekoSal,
        'liekoMahina': liekoMahina,
        'liekoGate': liekoGate,
        'bhujaauneSal': bhujaauneSal,
        'bhujaauneMahina': bhujaauneMahina,
        'bhujaaune_Gate': bhujaaune_Gate,
        'mulDhan': mulDhan,
        'byajDar': byajDar,
        'jammaByaj': jammaByaj,
        'totalAmount': totalAmount,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedRecord.fromJson(Map<String, dynamic> j) => SavedRecord(
        id: j['id'],
        name: j['name'] ?? '',
        note: j['note'] ?? '',
        liekoSal: j['liekoSal'],
        liekoMahina: j['liekoMahina'],
        liekoGate: j['liekoGate'],
        bhujaauneSal: j['bhujaauneSal'],
        bhujaauneMahina: j['bhujaauneMahina'],
        bhujaaune_Gate: j['bhujaaune_Gate'],
        mulDhan: (j['mulDhan'] as num).toDouble(),
        byajDar: (j['byajDar'] as num).toDouble(),
        jammaByaj: (j['jammaByaj'] as num).toDouble(),
        totalAmount: (j['totalAmount'] as num).toDouble(),
        savedAt: DateTime.parse(j['savedAt']),
      );

  String toJsonString() => jsonEncode(toJson());
  factory SavedRecord.fromJsonString(String s) =>
      SavedRecord.fromJson(jsonDecode(s));
}
