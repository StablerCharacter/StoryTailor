class SizeUnitConversion {
  static String bytesToAppropriateUnits(int byte, {fractionDigits = 2}) {
    if (byte >= 1e+6) {
      return "${bytesToMegabytes(byte).toStringAsFixed(fractionDigits)}MB";
    } else if (byte >= 1000) {
      return "${bytesToKilobyte(byte).toStringAsFixed(fractionDigits)}KB";
    }

    return "${byte}B";
  }

  static double bytesToMegabytes(int byte) {
    return byte / 1e+6;
  }

  static double bytesToKilobyte(int byte) {
    return byte / 1000;
  }
}
