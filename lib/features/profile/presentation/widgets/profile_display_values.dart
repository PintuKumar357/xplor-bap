import '../../../on_boarding/domain/entities/user_data_entity.dart';

String profileDisplayName(UserDataEntity? userData) {
  final name = [
    _displayText(userData?.kyc?.firstName),
    _displayText(userData?.kyc?.lastName),
  ].where((value) => value.isNotEmpty).join(' ');
  return name.isEmpty ? 'Pintu Kumar' : name;
}

String profileDisplayEmail(UserDataEntity? userData) {
  final email = _displayText(userData?.kyc?.email);
  return email.isEmpty ? 'kushpintu355@gamil.com' : email;
}

String _displayText(String? value) {
  final text = value?.trim() ?? '';
  return text.toLowerCase() == 'null' || text.toUpperCase() == 'NA' ? '' : text;
}