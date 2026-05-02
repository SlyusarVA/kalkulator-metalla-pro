import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Удобный виджет для иконок Tabler из assets/icons/tabler/
class TIcon extends StatelessWidget {
  final String name;       // имя файла без расширения, напр. 'arrow-left'
  final double size;
  final Color? color;

  const TIcon(this.name, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      'assets/icons/tabler/$name.svg',
      width: size, height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

// Иконка поверх AppBar (белая по умолчанию)
class TIconAppBar extends StatelessWidget {
  final String name;
  final double size;
  const TIconAppBar(this.name, {super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final fgColor = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
    return SvgPicture.asset(
      'assets/icons/tabler/$name.svg',
      width: size, height: size,
      colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
    );
  }
}
