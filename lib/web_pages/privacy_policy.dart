import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _HeroSection(),
                SizedBox(height: 20),
                _PolicyCard(
                  title: '1. Information We Collect',
                  content:
                  'We may collect personal information such as your name, email address, phone number, billing information, and any information you provide when contacting us or creating an account. We may also collect usage information including pages visited, device details, IP address, browser type, and interactions with our services. Cookies and similar technologies may be used to improve functionality and analyze traffic.',
                ),
                _PolicyCard(
                  title: '2. How We Use Your Information',
                  content:
                  'Otonav uses collected information to provide, maintain, and improve our services, communicate with users, personalize user experience, monitor platform performance, enhance security, and comply with legal obligations.',
                ),
                _PolicyCard(
                  title: '3. How We Share Information',
                  content:
                  'We do not sell your personal information. We may share data with trusted service providers who help us operate our platform, where required by law, to protect our rights or users, or as part of a business transaction such as a merger or acquisition.',
                ),
                _PolicyCard(
                  title: '4. Data Retention',
                  content:
                  'We retain personal information only for as long as necessary to provide our services, resolve disputes, enforce agreements, and meet legal or regulatory obligations.',
                ),
                _PolicyCard(
                  title: '5. Data Security',
                  content:
                  'We implement reasonable administrative, technical, and organizational safeguards to protect your information. However, no online system can be guaranteed to be completely secure.',
                ),
                _PolicyCard(
                  title: '6. Your Rights and Choices',
                  content:
                  'Depending on your location, you may have rights to access, correct, delete, or restrict the processing of your personal data, and to withdraw consent where applicable. You may contact us to exercise these rights.',
                ),
                _PolicyCard(
                  title: '7. Third-Party Services',
                  content:
                  'Our platform may contain links to third-party websites or integrations with third-party tools. We are not responsible for the privacy practices of those third parties, and you should review their policies independently.',
                ),
                _PolicyCard(
                  title: '8. Children\'s Privacy',
                  content:
                  'Our services are not directed at children under the age required by applicable law, and we do not knowingly collect personal information from children without proper consent where required.',
                ),
                _PolicyCard(
                  title: '9. International Data Transfers',
                  content:
                  'Your information may be processed and stored in countries outside your own. Where this happens, we take appropriate steps to ensure your data is handled in accordance with applicable privacy laws.',
                ),
                _PolicyCard(
                  title: '10. Changes to This Privacy Policy',
                  content:
                  'We may update this Privacy Policy from time to time. Any updates will be posted on this page with a revised effective date. Continued use of our services after changes means you accept the updated policy.',
                ),
                _PolicyCard(
                  title: '11. Contact Us',
                  content:
                  'If you have any questions about this Privacy Policy or our data practices, please contact Otonav via your official support email and company address.',
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    '© 2026 Otonav. All rights reserved.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F3C88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagLabel(text: 'Privacy Policy'),
          SizedBox(height: 18),
          Text(
            'Otonav Privacy Policy',
            style: TextStyle(
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'At Otonav, we value your privacy and are committed to protecting your personal information. This page explains how we collect, use, store, and safeguard information when you use our website, products, and services.',
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFFDCE6FF),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Effective Date: January 1, 2026',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String text;

  const _TagLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
