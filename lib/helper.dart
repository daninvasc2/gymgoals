import 'package:fluttertoast/fluttertoast.dart';
export 'package:fluttertoast/fluttertoast.dart';

export 'helper.dart';

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

int calculateDaysLeft(DateTime startDate, DateTime expirationDate) {
  final difference = expirationDate.difference(startDate);
  return difference.inDays;
}
