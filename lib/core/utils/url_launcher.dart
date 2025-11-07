import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  Future launchURL(url) async {
    try {
      await launchUrl(Uri.parse(url));
      await Future.delayed(Duration(seconds: 5));
    } catch (err) {
      Fluttertoast.showToast(
        msg: "Invalid URL",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  dynamic launchEmail(String? url, {String? subject}) async {
    try {
      Uri email = Uri(
        scheme: 'mailto',
        path: url,
        queryParameters: {'subject': subject?.replaceAll(" ", '') ?? ''},
      );
      await launchUrl(email);
    } catch (err) {
      Fluttertoast.showToast(
        msg: "Unable to Re-Direct to mail",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  dynamic launchTel(String? url) async {
    try {
      Uri tel = Uri(scheme: 'tel', path: url);

      await launchUrl(tel);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to Re-Direct",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  dynamic launchURl() async {
    Fluttertoast.showToast(
      msg: "Long Press to open link",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
