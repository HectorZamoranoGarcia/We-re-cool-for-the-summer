import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/legal_constants.dart';

enum LegalDocumentType { privacyPolicy, termsOfService }

/// A reusable widget to securely open legal documents in the external browser.
/// Complies with Google Play requirement to show Privacy Policy inside the app.
class LegalActionButton extends StatelessWidget {
  final LegalDocumentType documentType;
  final String label;

  const LegalActionButton({
    super.key,
    required this.documentType,
    required this.label,
  });

  String get _url {
    switch (documentType) {
      case LegalDocumentType.privacyPolicy:
        return LegalConstants.privacyPolicyUrl;
      case LegalDocumentType.termsOfService:
        return LegalConstants.termsOfServiceUrl;
    }
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the legal document.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _launchUrl(context),
      icon: const Icon(Icons.open_in_new_outlined, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
