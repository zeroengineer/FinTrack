import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _salaryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _goToStep(int i) {
    _pageController.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _onNameNext() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      return;
    }
    setState(() => _nameError = null);
    _goToStep(2);
  }

  Future<void> _finish() async {
    final salary = double.tryParse(_salaryController.text.trim()) ?? 0;
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;
    await ref.read(settingsProvider.notifier).completeOnboarding(
          userName: _nameController.text.trim(),
          monthlySalary: salary,
          monthlyBudget: budget,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomeStep(onNext: () => _goToStep(1)),
            _NameStep(controller: _nameController, error: _nameError, onNext: _onNameNext),
            _SalaryBudgetStep(
              salaryController: _salaryController,
              budgetController: _budgetController,
              onFinish: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? content;
  final String buttonLabel;
  final Key buttonKey;
  final VoidCallback onPressed;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    this.content,
    required this.buttonLabel,
    required this.buttonKey,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.palette.textSecondary)),
          if (content != null) ...[const SizedBox(height: 32), content!],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              key: buttonKey,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Welcome to FinTrack',
      subtitle: 'Track your spending, stick to a budget, and see where your money goes — all on your device.',
      buttonLabel: 'Get Started',
      buttonKey: const Key('onboarding_get_started_button'),
      onPressed: onNext,
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onNext;
  const _NameStep({required this.controller, required this.error, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "What's your name?",
      subtitle: "We'll use this to greet you on the Home screen.",
      content: TextField(
        key: const Key('onboarding_name_field'),
        controller: controller,
        decoration: InputDecoration(labelText: 'Your name', errorText: error),
      ),
      buttonLabel: 'Next',
      buttonKey: const Key('onboarding_name_next_button'),
      onPressed: onNext,
    );
  }
}

class _SalaryBudgetStep extends StatelessWidget {
  final TextEditingController salaryController;
  final TextEditingController budgetController;
  final Future<void> Function() onFinish;
  const _SalaryBudgetStep({
    required this.salaryController,
    required this.budgetController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Salary & budget',
      subtitle: 'Set your monthly salary and how much you plan to spend. You can change these later in Profile.',
      content: Column(
        children: [
          TextField(
            key: const Key('onboarding_salary_field'),
            controller: salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly salary (₹)'),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('onboarding_budget_field'),
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly budget (₹)'),
          ),
        ],
      ),
      buttonLabel: 'Finish',
      buttonKey: const Key('onboarding_finish_button'),
      onPressed: onFinish,
    );
  }
}
