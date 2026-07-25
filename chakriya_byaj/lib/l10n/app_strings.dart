/// Language toggle strings — Nepali, English & Hindi
class AppStrings {
  final String languageCode;
  
  AppStrings({bool? isNepali, String? languageCode})
      : languageCode = languageCode ?? (isNepali == true ? 'np' : 'en');

  bool get isNepali => languageCode == 'np';
  bool get isHindi => languageCode == 'hi';
  bool get isEnglish => languageCode == 'en';

  // App bar
  String get appTitle {
    if (isNepali) return 'चक्रिय ब्याज';
    if (isHindi) return 'चक्रवृद्धि ब्याज';
    return 'Compound Interest';
  }

  // Section headers
  String get liekoMiti {
    if (isNepali) return 'रकम लिएको मिति';
    if (isHindi) return 'ऋण लेने की तिथि';
    return 'Amount Taken Date';
  }
  String get bhujaaune {
    if (isNepali) return 'रकम भुझाउने मिति';
    if (isHindi) return 'भुगतान की तिथि';
    return 'Amount Return Date';
  }

  // Date fields
  String get sal {
    if (isNepali) return 'साल';
    if (isHindi) return 'वर्ष';
    return 'Year';
  }
  String get mahina {
    if (isNepali) return 'महिना';
    if (isHindi) return 'महीना';
    return 'Month';
  }
  String get gate {
    if (isNepali) return 'गते';
    if (isHindi) return 'तारीख';
    return 'Day';
  }

  // Input labels
  String get mulDhan {
    if (isNepali) return 'मूलधन';
    if (isHindi) return 'मूलधन';
    return 'Principal';
  }
  String get byajDar {
    if (isNepali) return 'ब्याज दर';
    if (isHindi) return 'ब्याज दर';
    return 'Interest Rate';
  }
  String get perMonth {
    if (isNepali) return '% प्रति महिना';
    if (isHindi) return '% प्रति माह';
    return '% per month';
  }

  // Buttons
  String get calculate {
    if (isNepali) return 'गणना गर्नुहोस्';
    if (isHindi) return 'गणना करें';
    return 'Calculate';
  }
  String get newCalc {
    if (isNepali) return 'अर्को हिसाब';
    if (isHindi) return 'नया हिसाब';
    return 'New Calculation';
  }

  // Hint
  String get rateHint {
    if (isNepali) return 'ब्याजदरमा प्रति महिना लाग्ने\nब्यजप्रतिशत लेख्नुहोला';
    if (isHindi) return 'ब्याज दर प्रति माह प्रतिशत में दर्ज करें';
    return 'Enter monthly interest\nrate percentage';
  }

  // Result labels
  String get liekoMitiResult {
    if (isNepali) return 'रकम लिएको मिति';
    if (isHindi) return 'ऋण लेने की तिथि';
    return 'Amount Taken Date';
  }
  String get bhujaauneMitiResult {
    if (isNepali) return 'रकम भुझाउने मिति';
    if (isHindi) return 'भुगतान की तिथि';
    return 'Amount Return Date';
  }
  String get mulDhanResult {
    if (isNepali) return 'मूलधन';
    if (isHindi) return 'मूलधन';
    return 'Principal';
  }
  String get byajDarResult {
    if (isNepali) return 'ब्याज दर';
    if (isHindi) return 'ब्याज दर';
    return 'Interest Rate';
  }
  String get byajChaleko {
    if (isNepali) return 'ब्याज चलेको';
    if (isHindi) return 'ब्याज की अवधि';
    return 'Interest Duration';
  }
  String get jammaByaj {
    if (isNepali) return 'जम्मा ब्याज';
    if (isHindi) return 'कुल ब्याज';
    return 'Total Interest';
  }
  String get jammaRakam {
    if (isNepali) return 'जम्मा रकम ब्याज सहित';
    if (isHindi) return 'ब्याज सहित कुल राशि';
    return 'Total Amount with Interest';
  }

  // Date format
  String get salSuffix {
    if (isNepali) return ' साल ';
    if (isHindi) return ' वर्ष ';
    return ' Year ';
  }
  String get mahinaSuffix {
    if (isNepali) return ' महिना ';
    if (isHindi) return ' महीना ';
    return ' Month ';
  }
  String get gateSuffix {
    if (isNepali) return ' गते';
    if (isHindi) return ' दिन';
    return ' Day';
  }
  String get dinSuffix {
    if (isNepali) return ' दिन';
    if (isHindi) return ' दिन';
    return ' Days';
  }
  String get currency {
    if (isHindi) return '₹ ';
    return 'रु ';
  }

  // Validation errors
  String get errLiekoMiti {
    if (isNepali) return 'रकम लिएको मिति राम्ररी भर्नुहोस्';
    if (isHindi) return 'कृपया ऋण लेने की तिथि भरें';
    return 'Please fill Amount Taken Date';
  }
  String get errBhujaauneMiti {
    if (isNepali) return 'रकम भुझाउने मिति राम्ररी भर्नुहोस्';
    if (isHindi) return 'कृपया भुगतान की तिथि भरें';
    return 'Please fill Amount Return Date';
  }
  String get errMulDhan {
    if (isNepali) return 'मूलधन राम्ररी भर्नुहोस्';
    if (isHindi) return 'कृपया मूलधन सही से भरें';
    return 'Please enter Principal amount';
  }
  String get errByajDar {
    if (isNepali) return 'ब्याजदरमा प्रति महिना लाग्ने\nब्यजप्रतिशत लेख्नुहोला';
    if (isHindi) return 'कृपया प्रति माह ब्याज दर दर्ज करें';
    return 'Please enter monthly\ninterest rate';
  }

  // Footer
  String get footerName => 'Tech Procod PVT LTD';
  String get footerPhone => '+977 9805916598';

  // Language toggle button label
  String get langToggle {
    if (isNepali) return 'EN';
    if (isHindi) return 'ने';
    return 'हि';
  }
}
