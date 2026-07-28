import 'dart:math' as math;
import '../services/nepali_date.dart';

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

  /// Calculate total days using 30-day month and 360-day year standard
  int _totalDays() {
    int startDays = (liekoSal * 360) + (liekoMahina * 30) + liekoGate;
    int endDays = (bhujaauneSal * 360) + (bhujaauneMahina * 30) + bhujaaune_Gate;
    return (endDays - startDays).clamp(0, 9999999);
  }

  /// Duration breakdown: sal / mahina / din (using 360-day year, 30-day month)
  Map<String, int> get byajChaleko {
    int totalDays = _totalDays();
    
    int years = totalDays ~/ 360;
    int remainingDays = totalDays % 360;
    int months = remainingDays ~/ 30;
    int days = remainingDays % 30;

    return {
      'sal': years,
      'mahina': months,
      'din': days,
    };
  }

  double get totalMonths {
    int totalDays = _totalDays();
    return totalDays / 30.0;
  }

  /// Chakriya Byaj (Compound Interest) - Annual Compounding
  /// Formula: CA = P × (1 + R/100)^T × (1 + mR/100)
  /// Where R = annual rate, T = complete years, m = remaining months (including days as decimal)
  /// User enters monthly rate, so annual rate = monthly rate × 12
  double get totalAmount {
    int totalDays = _totalDays();
    
    int completeYears = totalDays ~/ 360;
    int remainingDays = totalDays % 360;
    double remainingMonths = remainingDays / 30.0;  // Convert remaining days to decimal months
    
    double annualRate = byajDar * 12.0;  // Convert monthly % to annual %
    
    // If less than 1 year, use simple interest
    if (completeYears == 0) {
      double totalMonths = totalDays / 30.0;
      double interest = mulDhan * (byajDar / 100.0) * totalMonths;
      return mulDhan + interest;
    }
    
    // Annual compounding formula for T years and M months (as decimal)
    double compoundPart = mulDhan * math.pow(1 + annualRate / 100.0, completeYears);
    double monthlyPart = compoundPart * (1 + (remainingMonths * byajDar) / 100.0);
    
    return monthlyPart;
  }

  double get jammaByaj => totalAmount - mulDhan;
}
