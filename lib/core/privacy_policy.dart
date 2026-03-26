import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String privacyPolicyUrl =
    'https://gist.github.com/Canary330/2dd293e6aa0daf7a12526f61ac6d349a';
const String appleStandardEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

Future<void> openPrivacyPolicy(BuildContext context) async {
  await _openExternalUrl(
    context,
    url: privacyPolicyUrl,
    failureMessage: '暂时无法打开隐私政策网页',
  );
}

Future<void> openAppleStandardEula(BuildContext context) async {
  await _openExternalUrl(
    context,
    url: appleStandardEulaUrl,
    failureMessage: '暂时无法打开 Apple EULA 网页',
  );
}

Future<void> _openExternalUrl(
  BuildContext context, {
  required String url,
  required String failureMessage,
}) async {
  final opened = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failureMessage)));
  }
}
