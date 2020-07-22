extension CardUtil on String {
  bool get isLuhn {
    var sum = 0;
    String digit;
    var shouldDouble = false;

    for (var i = length - 1; i >= 0; i--) {
      digit = substring(i, (i + 1));
      var tmpNum = int.parse(digit);
      if (shouldDouble == true) {
        tmpNum *= 2;
        if (tmpNum >= 10) {
          sum += ((tmpNum % 10) + 1);
        } else {
          sum += tmpNum;
        }
      } else {
        sum += tmpNum;
      }
      shouldDouble = !shouldDouble;
    }
    return (sum % 10 == 0);
  }
}
