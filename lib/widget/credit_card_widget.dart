import 'package:flutter/material.dart';
import '../extensions/app_extensions.dart';
import '../model/card_details.dart';


class CreditCardWidget extends StatelessWidget {
  final CardDetails cardDetails;

  const CreditCardWidget({super.key, required this.cardDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F36), Color(0xFF2D3561)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1F36).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: _Circle(size: 140, opacity: 0.06),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: _Circle(size: 100, opacity: 0.06),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CARD SCANNER',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cardDetails.isValid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          '✓ VALID',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // Chip icon
                Container(
                  width: 38,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
               addVerticalSpace(16),
                // Masked card number
                Text(
                  cardDetails.maskedCardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
               addVerticalSpace(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          cardDetails.cardHolderName ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (cardDetails.expiryDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            cardDetails.expiryDate!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
