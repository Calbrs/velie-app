import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/post_channel.dart';
import '../../core/theme/app_colors.dart';

/// Brand icon for a channel (SVG). Disabled channels render greyed out.
class ChannelIcon extends StatelessWidget {
  const ChannelIcon(this.channel, {super.key, this.size = 20, this.enabled = true});

  final PostChannel channel;
  final double size;
  final bool enabled;

  static String assetFor(PostChannel channel) => switch (channel) {
        PostChannel.waStatus || PostChannel.waGroup => 'assets/icons/ic_whatsapp.svg',
      };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetFor(channel),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        enabled ? AppColors.textPrimary : AppColors.buttonDisabled,
        BlendMode.srcIn,
      ),
    );
  }
}
