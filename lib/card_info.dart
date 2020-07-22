class CardInfo {
  String cardNumber;
  String cardholderName;
  String expiry;
  // TODO: use instead of expiry
  String expiryMonth;
  String expiryYear;


  // TODO: implement
  String get maskedCardNumber {
    return '';
  }

  CardInfo({
    this.cardNumber,
    this.cardholderName,
    this.expiry,
  });
}