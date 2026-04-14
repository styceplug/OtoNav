import 'package:flutter/material.dart';

class AccountDeletionRequestPage extends StatefulWidget {
  const AccountDeletionRequestPage({super.key});

  @override
  State<AccountDeletionRequestPage> createState() =>
      _AccountDeletionRequestPageState();
}

class _AccountDeletionRequestPageState
    extends State<AccountDeletionRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController confirmationController = TextEditingController();

  bool acknowledgeDataLoss = false;
  bool acknowledgeIrreversible = false;
  bool isSubmitting = false;
  bool requestSubmitted = false;
  String requestId = '';

  @override
  void dispose() {
    emailController.dispose();
    reasonController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!acknowledgeDataLoss || !acknowledgeIrreversible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all confirmations before continuing.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final generatedId =
        'DEL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    setState(() {
      requestSubmitted = true;
      isSubmitting = false;
      requestId = generatedId;
    });
  }

  void resetForm() {
    _formKey.currentState?.reset();
    emailController.clear();
    reasonController.clear();
    confirmationController.clear();

    setState(() {
      acknowledgeDataLoss = false;
      acknowledgeIrreversible = false;
      isSubmitting = false;
      requestSubmitted = false;
      requestId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: requestSubmitted ? _buildSuccessState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Account Deletion Request',
                style: TextStyle(
                  color: Color(0xFFBE123C),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Request account deletion',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use this form to request deletion of your Otonav account. This demo simulates a live submission flow and returns a generated request ID after successful submission.',
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),
            _inputLabel('Email address'),
            const SizedBox(height: 8),
            _textField(
              controller: emailController,
              hint: 'Enter your account email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _inputLabel('Reason for deletion'),
            const SizedBox(height: 8),
            _textField(
              controller: reasonController,
              hint: 'Tell us why you want to delete your account',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                if (value.trim().length < 10) {
                  return 'Reason should be a bit more descriptive';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _inputLabel('Type DELETE to confirm'),
            const SizedBox(height: 8),
            _textField(
              controller: confirmationController,
              hint: 'Type DELETE',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Confirmation is required';
                }
                if (value.trim() != 'DELETE') {
                  return 'You must type DELETE exactly';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _checkTile(
              value: acknowledgeDataLoss,
              onChanged: (value) {
                setState(() => acknowledgeDataLoss = value ?? false);
              },
              title: 'I understand that my data may be permanently removed.',
            ),
            _checkTile(
              value: acknowledgeIrreversible,
              onChanged: (value) {
                setState(() => acknowledgeIrreversible = value ?? false);
              },
              title: 'I understand this request may be irreversible once processed.',
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Submit deletion request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Request submitted successfully',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your account deletion request has been logged successfully. A support agent can now review it. This is a simulated success flow for demo purposes.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 14),
                _detailRow('Request ID', requestId),
                _detailRow('Email', emailController.text.trim()),
                _detailRow('Status', 'Pending review'),
                _detailRow('Submitted at', DateTime.now().toString().substring(0, 16)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: resetForm,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  child: const Text(
                    'Submit another request',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
        ),
      ),
    );
  }

  Widget _checkTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFFDC2626),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
