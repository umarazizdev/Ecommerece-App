import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class JazzCashSandboxService {
  static const String merchantId = "MC30293";
  static const String password = "8u5v2w2x2z";
  static const String integritySalt = "z60gb5u008";
  static const String returnUrl = "https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";

  static String _formatDate(DateTime dt) {
    return "${dt.year}${dt.month.toString().padLeft(2,'0')}${dt.day.toString().padLeft(2,'0')}${dt.hour.toString().padLeft(2,'0')}${dt.minute.toString().padLeft(2,'0')}${dt.second.toString().padLeft(2,'0')}";
  }

  static String generateHtml({required String amount}) {
    String txnRef = "T${DateTime.now().millisecondsSinceEpoch}";
    String dateTime = _formatDate(DateTime.now());
    String expiry = _formatDate(DateTime.now().add(const Duration(days: 1)));
    String amountInPaisa = (int.parse(amount) * 100).toString();

    // Hash String - WebView form ke liye ye order chahiye
    String hashString = "$integritySalt&$amountInPaisa&billRef&Order $amount&EN&$merchantId&$password&$returnUrl&PKR&$dateTime&$expiry&$txnRef&MWALLET&1.1&$returnUrl&$returnUrl";

    var key = utf8.encode(integritySalt);
    var bytes = utf8.encode(hashString);
    var hmac = crypto.Hmac(crypto.sha256, key);
    String secureHash = hmac.convert(bytes).toString();

    return """
      <html><body onload='document.forms[0].submit()'>
      <form method='POST' action='https://sandbox.jazzcash.com.pk/CustomerPortal/transactionmanagement/merchantform/'>
        <input type='hidden' name='pp_Version' value='1.1'>
        <input type='hidden' name='pp_TxnType' value='MWALLET'>
        <input type='hidden' name='pp_Language' value='EN'>
        <input type='hidden' name='pp_MerchantID' value='$merchantId'>
        <input type='hidden' name='pp_Password' value='$password'>
        <input type='hidden' name='pp_TxnRefNo' value='$txnRef'>
        <input type='hidden' name='pp_Amount' value='$amountInPaisa'>
        <input type='hidden' name='pp_TxnCurrency' value='PKR'>
        <input type='hidden' name='pp_TxnDateTime' value='$dateTime'>
        <input type='hidden' name='pp_TxnExpiryDateTime' value='$expiry'>
        <input type='hidden' name='pp_BillReference' value='billRef'>
        <input type='hidden' name='pp_Description' value='Order $amount'>
        <input type='hidden' name='pp_ReturnURL' value='$returnUrl'>
        <input type='hidden' name='pp_SecureHash' value='$secureHash'>
      </form>
      <h3>Redirecting to JazzCash Sandbox...</h3>
      </body></html>
    """;
  }
}