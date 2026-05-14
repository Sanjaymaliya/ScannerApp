
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scannerapp/extensions/app_extensions.dart';

import '../../theme/app_theme.dart';
import '../../widget/info_tile.dart';
import '../../widget/loading_overlay.dart';
import '../../widget/scanned_image_preview.dart';
import 'bloc/passbook_scanner_bloc.dart';
import 'bloc/passbook_scanner_event.dart';
import 'bloc/passbook_scanner_state.dart';


class PassbookScannerScreen extends StatelessWidget {
  const PassbookScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PassbookScannerBloc(),
      child: const _PassbookScannerView(),
    );
  }
}

class _PassbookScannerView extends StatelessWidget {
  const _PassbookScannerView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Passbook Scanner'),
          actions: [
            BlocBuilder<PassbookScannerBloc, PassbookScannerState>(
              builder: (context, state) {
                if (state is PassbookScannerSuccess ||
                    state is PassbookScannerNoData) {
                  return TextButton.icon(
                    onPressed: () => context
                        .read<PassbookScannerBloc>()
                        .add(const PassbookScanReset()),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Reset',
                        style: TextStyle(color: Colors.white)),
                  );
                }
                return shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<PassbookScannerBloc, PassbookScannerState>(
          builder: (context, state) {
            return Stack(
              children: [
                _buildBody(context, state),
                if (state is PassbookScannerLoading)
                  LoadingOverlay(message: state.message),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PassbookScannerState state) {
    if (state is PassbookScannerInitial) return _InitialView();
    if (state is PassbookScannerSuccess) return _SuccessView(state: state);
    if (state is PassbookScannerNoData) return _NoDataView(state: state);
    if (state is PassbookScannerError) return _ErrorView(message: state.message);
    return shrink();
  }
}

// ─── Initial ──────────────────────────────────────────────────────────────────

class _InitialView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PassbookScannerBloc>();

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
                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_rounded,
                  size: 48, color: Color(0xFF0EA5E9)),
            ),
            addVerticalSpace(24),
            const Text(
              'Scan Passbook',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            addVerticalSpace(12),
            Text(
              'Scan or upload a bank passbook page to extract your account details automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium!,

            ),
            addVerticalSpace(36),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        bloc.add(const PassbookScanFromCamera()),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                  ),
                ),
                addHorizontalSpace(12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        bloc.add(const PassbookScanFromGallery()),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success ──────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final PassbookScannerSuccess state;

  const _SuccessView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bank = state.bankDetails;
    final bloc = context.read<PassbookScannerBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank card display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_rounded,
                        color: Colors.white70, size: 20),

                    addHorizontalSpace(8),

                    const Text(
                      'BANK ACCOUNT',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                addVerticalSpace(20),
                Text(
                  bank.accountHolderName ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                addVerticalSpace(8),
                Text(
                  bank.accountNumber != null
                      ? '•••• •••• ${bank.accountNumber!.substring(bank.accountNumber!.length > 4 ? bank.accountNumber!.length - 4 : 0)}'
                      : '—',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                if (bank.ifscCode != null) ...[
                  addVerticalSpace(4),
                  Text(
                    'IFSC: ${bank.ifscCode!}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          addVerticalSpace(24),
          ScannedImagePreview(imagePath: state.imagePath),

          addVerticalSpace(24),

          const Text(
            'Extracted Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          addVerticalSpace(12),
          if (bank.accountHolderName != null)
            InfoTile(
              label: 'Account Holder Name',
              value: bank.accountHolderName!,
              icon: Icons.person_rounded,
            ),
          if (bank.accountNumber != null)
            InfoTile(
              label: 'Account Number',
              value: bank.accountNumber!,
              icon: Icons.numbers_rounded,
            ),
          if (bank.ifscCode != null)
            InfoTile(
              label: 'IFSC Code',
              value: bank.ifscCode!,
              icon: Icons.account_balance_rounded,
            ),


          addVerticalSpace(8),

          _RawOcrExpansion(rawText: state.rawText),

          addVerticalSpace(20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => bloc.add(const PassbookScanFromCamera()),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan Again'),
                ),
              ),
              addHorizontalSpace(12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => bloc.add(const PassbookScanFromGallery()),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Upload'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── No Data ──────────────────────────────────────────────────────────────────

class _NoDataView extends StatelessWidget {
  final PassbookScannerNoData state;

  const _NoDataView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PassbookScannerBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          //ScannedImagePreview(imagePath: state.imagePath),
          addVerticalSpace(32),
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppTheme.textSecondary),
          addVerticalSpace(16),
          const Text(
            'No Bank Data Found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          addVerticalSpace(8),
          const Text(
            'Could not extract bank details. Please try again with a clearer image of the passbook page.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          addVerticalSpace(28),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => bloc.add(const PassbookScanFromCamera()),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                ),
              ),
              addHorizontalSpace(12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => bloc.add(const PassbookScanFromGallery()),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

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
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            addVerticalSpace(8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
            addVerticalSpace(28),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<PassbookScannerBloc>()
                  .add(const PassbookScanReset()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Raw OCR ──────────────────────────────────────────────────────────────────

class _RawOcrExpansion extends StatelessWidget {
  final String rawText;

  const _RawOcrExpansion({required this.rawText});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        'Raw OCR Output',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary),
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
    );
  }
}
