import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../extensions/app_extensions.dart';
import '../../theme/app_theme.dart';
import '../../widget/credit_card_widget.dart';
import '../../widget/info_tile.dart';
import '../../widget/loading_overlay.dart';
import '../../widget/scanned_image_preview.dart';
import 'bloc/card_scanner_bloc.dart';
import 'bloc/card_scanner_event.dart';
import 'bloc/card_scanner_state.dart';


class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardScannerBloc(),
      child: const _CardScannerView(),
    );
  }
}

class _CardScannerView extends StatelessWidget {
  const _CardScannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner'),
        actions: [
          BlocBuilder<CardScannerBloc, CardScannerState>(
            builder: (context, state) {
              if (state is CardScannerSuccess || state is CardScannerNoData) {
                return TextButton.icon(
                  onPressed: () =>
                      context.read<CardScannerBloc>().add(const CardScanReset()),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text('Reset',
                      style: TextStyle(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CardScannerBloc, CardScannerState>(
        builder: (context, state) {
          return Stack(
            children: [
              _buildBody(context, state),
              if (state is CardScannerLoading)
                LoadingOverlay(message: state.message),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardScannerState state) {
    if (state is CardScannerInitial) return _InitialView();
    if (state is CardScannerSuccess) return _SuccessView(state: state);
    if (state is CardScannerNoData) return _NoDataView(state: state);
    if (state is CardScannerError) return _ErrorView(message: state.message);
    return const SizedBox.shrink(); // Loading — overlay handles it
  }
}

// ─── Initial State ────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                size: 48,
                color: AppTheme.accent,
              ),
            ),
           addVerticalSpace(24),
            const Text(
              'Scan Your Card',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
           addVerticalSpace(12),
            const Text(
              'Point your camera at a credit or debit card. Make sure the card is well-lit and fully visible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
           addVerticalSpace(36),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<CardScannerBloc>().add(const CardScanStarted()),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Open Camera'),
            ),
           addVerticalSpace(24),
            // Tips
            _TipsCard(),
          ],
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📸 Tips for best results',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
         addVerticalSpace(8),
          ...[
            'Hold the phone steady above the card',
            'Ensure good lighting — avoid glare',
            'Fit the entire card in the frame',
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppTheme.accentGreen),
                 addHorizontalSpace(8),
                  Text(tip,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success State ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final CardScannerSuccess state;

  const _SuccessView({required this.state});

  @override
  Widget build(BuildContext context) {
    final card = state.cardDetails;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual card preview
          CreditCardWidget(cardDetails: card),
         addVerticalSpace(24),

          // Scanned image
          ScannedImagePreview(imagePath: state.imagePath),
         addVerticalSpace(24),

          // Extracted details
          const Text(
            'Extracted Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
         addVerticalSpace(12),

          if (card.cardNumber != null)
            InfoTile(
              label: 'Card Number (Masked)',
              value: card.maskedCardNumber,
              icon: Icons.credit_card_rounded,
            ),
          if (card.expiryDate != null)
            InfoTile(
              label: 'Expiry Date',
              value: card.expiryDate!,
              icon: Icons.calendar_month_rounded,
            ),
          if (card.cardHolderName != null)
            InfoTile(
              label: 'Card Holder',
              value: card.cardHolderName!,
              icon: Icons.person_rounded,
            ),

          // Validity badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card.isValid
                  ? AppTheme.accentGreen.withOpacity(0.1)
                  : AppTheme.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: card.isValid ? AppTheme.accentGreen : AppTheme.accentRed,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  card.isValid
                      ? Icons.verified_rounded
                      : Icons.cancel_rounded,
                  color:
                      card.isValid ? AppTheme.accentGreen : AppTheme.accentRed,
                  size: 20,
                ),
               addHorizontalSpace(10),
                Text(
                  card.isValid
                      ? 'Card number passed Luhn validation'
                      : 'Card number failed Luhn validation',
                  style: TextStyle(
                    color: card.isValid
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

         addVerticalSpace(16),

          // Raw OCR collapsible
          _RawOcrExpansion(rawText: state.rawText),

         addVerticalSpace(20),

          // Scan again
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<CardScannerBloc>().add(const CardScanStarted()),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Scan Again'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── No Data State ─────────────────────────────────────────────────────────────

class _NoDataView extends StatelessWidget {
  final CardScannerNoData state;

  const _NoDataView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ScannedImagePreview(imagePath: state.imagePath),
         addVerticalSpace(32),
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppTheme.textSecondary),
         addVerticalSpace(16),
          const Text(
            'No Card Data Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
         addVerticalSpace(8),
          const Text(
            'The scan didn\'t return recognisable card information. Try again with better lighting.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
         addVerticalSpace(28),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<CardScannerBloc>().add(const CardScanStarted()),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppTheme.accentRed),
           addVerticalSpace(16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
           addVerticalSpace(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
            ),
           addVerticalSpace(28),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<CardScannerBloc>().add(const CardScanReset()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Raw OCR Expansion Tile ────────────────────────────────────────────────────

class _RawOcrExpansion extends StatelessWidget {
  final String rawText;

  const _RawOcrExpansion({required this.rawText});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text(
          'Raw OCR Output',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              rawText.isEmpty ? '(empty)' : rawText,
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'monospace', height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
