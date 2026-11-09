import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

const supportIntakeMaxLength = 200;

enum SupportIntakeProblem { required, tooLong, number, date, choice }

final _number = RegExp(r'^-?[0-9]{1,15}([.,][0-9]{1,4})?$');
final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

bool isSupportIntakeDate(String value) {
  if (!_isoDate.hasMatch(value)) return false;
  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(5, 7));
  final day = int.parse(value.substring(8, 10));
  final date = DateTime.utc(year, month, day);
  return date.year == year && date.month == month && date.day == day;
}

String supportIntakeDateValue(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

SupportIntakeProblem? checkSupportIntakeAnswer(SupportIntakeField field, String? answer) {
  final value = answer?.trim() ?? '';
  if (value.isEmpty) return field.isRequired ? SupportIntakeProblem.required : null;
  if (value.length > supportIntakeMaxLength) return SupportIntakeProblem.tooLong;
  return switch (field.type) {
    SupportIntakeType.text => null,
    SupportIntakeType.number => _number.hasMatch(value) ? null : SupportIntakeProblem.number,
    SupportIntakeType.date => isSupportIntakeDate(value) ? null : SupportIntakeProblem.date,
    SupportIntakeType.choice => field.optionLabel(value) != null ? null : SupportIntakeProblem.choice,
  };
}

Map<String, SupportIntakeProblem> validateSupportIntake(List<SupportIntakeField> fields, Map<String, String> answers) =>
    {for (final field in fields) field.key: ?checkSupportIntakeAnswer(field, answers[field.key])};

Map<String, String> supportIntakePayload(List<SupportIntakeField> fields, Map<String, String> answers) => {
  for (final field in fields)
    if ((answers[field.key]?.trim() ?? '').isNotEmpty) field.key: answers[field.key]!.trim(),
};
