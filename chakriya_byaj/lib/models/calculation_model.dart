import 'dart:math' as math;

class CalculationModel {
  final int liekoSal;
  final int liekoMahina;
  final int liekoGate;
  final int bhujaauneSal;
  final int bhujaauneMahina;
  final int bhujaaune_Gate;
  final double mulDhan;
  final double byajDar; // monthly %

  const CalculationModel({
    required this.liekoSal,
    required this.liekoMahina,
    required this.liekoGate,
    required this.bhujaauneSal,
    required this.bhujaauneMahina,
    required this.bhujaaune_Gate,
    required this.mulDhan,
    required this.byajDar,
  });

  int _toDays(int sal, int mahina, int gate) =>
      (sal * 365) + (mahina * 30) + gate;

  /// Duration breakdown: sal / mahina / din
  Map<String, int> get byajChaleko {
    int start = _toDays(liekoSal, liekoMahina, liekoGate);
    int end = _toDays(bhujaauneSal, bhujaauneMahina, bhujaaune_Gate);
    int total = (end - start).clamp(0, 9999999);

    return {
      'sal': total ~/ 365,
      'mahina': (total % 365) ~/ 30,
      'din': (total % 365) % 30,
    };
  }

  double get totalMonths {
    int start = _toDays(liekoSal, liekoMahina, liekoGate);
    int end = _toDays(bhujaauneSal, bhujaauneMahina, bhujaaune_Gate);
    int total = (end - start).clamp(0, 9999999);
    return total / 30.0;
  }

  /// A = P * (1 + R/100)^t  — yearly compounding
  /// User enters monthly rate → multiplied by 12 = annual rate
  /// t = total days / 365 for accurate year fraction
  double get totalAmount {
    int start = _toDays(liekoSal, liekoMahina, liekoGate);
    int end   = _toDays(bhujaauneSal, bhujaauneMahina, bhujaaune_Gate);
    int totalDays = (end - start).clamp(0, 9999999);

    double annualRate = byajDar * 12.0;   // monthly % → annual %
    double r = annualRate / 100.0;        // annual decimal
    double t = totalDays / 365.0;         // days → years (365 days = 1 year)
    return mulDhan * math.pow(1 + r, t);
  }

  double get jammaByaj => totalAmount - mulDhan;
}
