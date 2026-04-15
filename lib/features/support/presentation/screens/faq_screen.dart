import 'package:flutter/material.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<FAQItem> faqs = const [
    FAQItem(
      question: 'How do I reset my password?',
      answer:
          'To reset your password, go to the login page and click "Forgot Password". Enter your registered email and follow the instructions sent to your inbox.',
    ),
    FAQItem(
      question: 'Is my personal information secure?',
      answer:
          'Yes, we use industry-standard 256-bit encryption and comply with international security standards to protect your data.',
    ),
    FAQItem(
      question: 'How long does a transfer take?',
      answer:
          'Most domestic transfers are completed within 2-4 hours. International transfers may take 2-5 business days.',
    ),
    FAQItem(
      question: 'What is the minimum transfer amount?',
      answer:
          'The minimum transfer amount is ₹100. Maximum varies based on your account type and verification level.',
    ),
    FAQItem(
      question: 'Can I cancel a transfer?',
      answer:
          'You can cancel a transfer if it\'s still in pending status. Completed transfers cannot be cancelled.',
    ),
    FAQItem(
      question: 'What are the transaction fees?',
      answer:
          'Domestic transfers are free. Some services may have minimal fees which are always displayed before confirmation.',
    ),
    FAQItem(
      question: 'How do I enable biometric login?',
      answer:
          'Go to Settings > Security and toggle "Enable Biometric Login". Your device must support fingerprint or face recognition.',
    ),
    FAQItem(
      question: 'Is 24/7 customer support available?',
      answer:
          'Yes, our support team is available 24/7 via chat, email, and phone to assist you.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return _FAQItemWidget(item: faqs[index]);
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});
}

class _FAQItemWidget extends StatefulWidget {
  final FAQItem item;

  const _FAQItemWidget({required this.item});

  @override
  State<_FAQItemWidget> createState() => _FAQItemWidgetState();
}

class _FAQItemWidgetState extends State<_FAQItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (_isExpanded) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          border: Border.all(
            color: _isExpanded ? AppTheme.primaryBlue : AppTheme.divider,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(_controller),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.divider)),
                ),
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Text(
                  widget.item.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
