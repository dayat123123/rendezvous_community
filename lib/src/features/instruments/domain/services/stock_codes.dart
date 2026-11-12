final _codeFormat = RegExp(r'^[A-Z][A-Z0-9]{0,19}(?:-[A-Z0-9]{1,19})*$');

final _plainStockCode = RegExp(r'^[A-Z][A-Z0-9]{1,11}$');

String normalizeStockCode(String code) => code.trim().replaceFirst(RegExp(r'^\$+'), '').toUpperCase();

bool isStockCodeFormat(String code) => code.length >= 2 && code.length <= 24 && _codeFormat.hasMatch(code);

bool isPlainStockCode(String code) => _plainStockCode.hasMatch(code);
