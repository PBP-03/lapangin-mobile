import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import 'app_logo.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandedAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.elevation,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.showLogo = true,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final bool showLogo;
  final Color backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedForeground = foregroundColor ?? AppColors.primary;
    final resolvedTitleTextStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: resolvedForeground);

    const appBarLogo = AppLogo(
      size: 44,
      assetPath: 'assets/images/logo/logo.png',
      fit: BoxFit.contain,
    );

    Widget? resolvedLeading = leading;
    double? resolvedLeadingWidth;

    if (resolvedLeading == null && showLogo) {
      final canPop =
          automaticallyImplyLeading && Navigator.of(context).canPop();

      if (canPop) {
        resolvedLeadingWidth = 160;
        resolvedLeading = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackButton(color: resolvedForeground),
            const SizedBox(width: 6),
            appBarLogo,
          ],
        );
      } else {
        resolvedLeadingWidth = 84;
        resolvedLeading = Padding(
          padding: const EdgeInsets.only(left: 12),
          child: appBarLogo,
        );
      }
    }

    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      foregroundColor: resolvedForeground,
      titleTextStyle: resolvedTitleTextStyle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: resolvedLeading,
      leadingWidth: resolvedLeadingWidth,
      title: title,
      actions: actions,
      bottom: bottom,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }
}
