extension CardUtil on String {
  bool get isLuhn {
    int sum = 0;
    String digit;
    bool shouldDouble = false;

    for (int i = this.length - 1; i >= 0; i--) {
      digit = this.substring(i, (i + 1));
      int tmpNum = int.parse(digit);
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
