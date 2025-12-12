class Language {
  final String name;
  final String code;
  final String displayText;

  Language({
    required this.name,
    required this.code,
    required this.displayText,
  });
}

final List<Language> availableLanguages = [
  Language(
    name: 'English',
    code: 'A',
    displayText: '(US)',
  ),
  Language(
    name: 'Nepali',
    code: 'अ',
    displayText: '(नेपाली)',
  ),
  Language(
    name: 'Hindi',
    code: 'अ',
    displayText: '(हिंदी)',
  ),
  Language(
    name: 'Maithili',
    code: 'अ',
    displayText: '(मैथिली)',
  ),
  Language(
    name: 'Punjabi',
    code: 'ਏ',
    displayText: '(ਪੰਜਾਬੀ)',
  ),
];
