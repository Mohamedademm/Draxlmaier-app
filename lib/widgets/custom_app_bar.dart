import 'package:flutter/material.dart';
import '../theme/draexlmaier_theme.dart';
import '../widgets/draexlmaier_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;
  final bool centerTitle;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
    this.centerTitle = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DraexlmaierLogo(
                  height: 32,
                  isWhite: true,
                ),
                if (title != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            )
          : (title != null ? Text(title!) : null),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: DraexlmaierTheme.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
