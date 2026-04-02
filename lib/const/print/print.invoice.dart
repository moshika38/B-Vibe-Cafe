class PrintInvoice {
  static Future<bool> printPrimaryPrinter() async {
    print("✔✔ Receipt Printed successful");
    return true;
  }

  static Future<bool> printSecondaryPrinter() async {
    print("✔✔ KOT printed successful");
    return true;
  }
}
