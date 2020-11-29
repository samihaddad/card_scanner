import 'package:card_scanner/card_extension.dart';

class CardInfoValidator {
  CardInfoValidator(this.text);

  String text;

  RegExp _cardNumberReg = RegExp(
      r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');

  RegExp _cardExpiryReg = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$');

  RegExp _cardholderName = RegExp(r'^((?:[A-Za-z]+ ?){1,3})$');

  bool isValidCardNumber() {
    // TODO: check is valid card type (visa,mastercard...)

    return _cardNumberReg.hasMatch(sanitized) && sanitized.isLuhn;
  }

  bool isValidExpiryDate() {
    return _cardExpiryReg.hasMatch(text);
  }

  bool isValidCardholderName() {
    // TODO: use text size/dimensions and a blaclist to filter out bank text
    var blockList = [
      'bank',
      'card',
      'valid',
      'thru',
      'visa',
      'master',
      'gold',
      'platinum',
      'debit',
      'credit'
    ];
    var hasBlockedString = blockList.firstWhere(
          (el) => text.toLowerCase().contains(el.toLowerCase()),
          orElse: () => null,
        ) !=
        null;

    return !hasBlockedString && _cardholderName.hasMatch(text);
    // !blockList.contains(text.toLowerCase());
  }

  String get sanitized {
    var embossedFontCorrections = <String, String>{
      'D': '0',
      'O': '0',
      'H': '4',
      'b': '6',
    };
    embossedFontCorrections.forEach((char, number) {
      text = text.replaceAll(char, number);
    });
    return text.replaceAll(RegExp(r'[^0-9]+'), '');
  }
}

enum CardType {
  amex,
  jcb,
  visa,
  masterCard,
  discover,
}
