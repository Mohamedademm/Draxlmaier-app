import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widget pour afficher le logo Draexlmaier avec un design élégant
class DraexlmaierLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final bool isWhite;
  final BoxFit fit;
  final bool showShadow;
  final bool animate;

  const DraexlmaierLogo({
    Key? key,
    this.height,
    this.width,
    this.isWhite = false,
    this.fit = BoxFit.contain,
    this.showShadow = false,
    this.animate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: showShadow ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: showShadow
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            )
          : null,
      child: Image.asset(
        AppConstants.logoPath,
        height: height,
        width: width,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Erreur chargement logo: $error');
          print('📁 Chemin: ${AppConstants.logoPath}');
          return _buildPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height ?? AppConstants.logoSizeMedium,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isWhite
              ? [Colors.white, Colors.grey[100]!]
              : [const Color(0xFF003DA5), const Color(0xFF00A9E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWhite
              ? Colors.grey[300]!
              : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isWhite ? Colors.blue[900] : Colors.white)?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center,
                color: isWhite ? const Color(0xFF003DA5) : Colors.white,
                size: (height ?? AppConstants.logoSizeMedium) * 0.25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'DRÄXLMAIER',
              style: TextStyle(
                color: isWhite ? const Color(0xFF003DA5) : Colors.white,
                fontSize: (height ?? AppConstants.logoSizeMedium) * 0.13,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: showShadow
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
