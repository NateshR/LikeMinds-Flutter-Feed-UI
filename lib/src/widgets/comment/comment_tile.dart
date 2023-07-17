import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/src/utils/helpers.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';
import 'package:likeminds_feed_ui_fl/src/utils/utils.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/buttons/text_button.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/icon/icon.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/profile_picture.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/text/text_view.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/post/post_menu.dart';

class LMCommentTile extends StatefulWidget {
  const LMCommentTile({
    super.key,
    required this.user,
    required this.comment,
    this.profilePicture,
    this.titleText,
    this.subtitleText,
    this.commentActions,
    this.actionsPadding,
  });

  final User user;
  final Reply comment;

  final LMProfilePicture? profilePicture;
  final LMTextView? titleText;
  final LMTextView? subtitleText;
  final List<Widget>? commentActions;
  final EdgeInsets? actionsPadding;

  @override
  State<LMCommentTile> createState() => _LMCommentTileState();
}

class _LMCommentTileState extends State<LMCommentTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: kWhiteColor),
      padding: const EdgeInsets.all(kPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.profilePicture ?? const SizedBox(),
                kHorizontalPaddingLarge,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.titleText ??
                        LMTextView(
                          text: widget.user.name,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    widget.subtitleText != null
                        ? kVerticalPaddingSmall
                        : const SizedBox(),
                    widget.subtitleText ?? const SizedBox(),
                    Container(
                      width: 240,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: LMTextView(
                        text: TaggingHelper.convertRouteToTag(
                          widget.comment.text,
                          withTilde: false,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                LMPostMenu(
                  menuItems: widget.comment.menuItems,
                ),
              ],
            ),
          ),
          // kVerticalPaddingMedium,
          Padding(
            padding: widget.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: widget.commentActions ??
                  [
                    LMTextButton(
                      onTap: (active) {
                        if (active) {
                          print("Liked");
                        } else {
                          print("Unliked");
                        }
                      },
                      text: const LMTextView(
                        text: 'Like',
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: kGrey2Color,
                        ),
                      ),
                      icon: const LMIcon(
                        icon: Icons.favorite_outline,
                        color: kGrey2Color,
                        size: 16,
                      ),
                      activeIcon: const LMIcon(
                        icon: Icons.favorite,
                        size: 16,
                        color: kPrimaryColor,
                      ),
                    ),
                    kHorizontalPaddingMedium,
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: kFontSmallMed,
                        color: kGrey3Color,
                      ),
                    ),
                    kHorizontalPaddingMedium,
                    LMTextButton(
                      onTap: (active) {},
                      text: const LMTextView(
                        text: 'Reply',
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: kGrey2Color,
                        ),
                      ),
                    ),
                    kHorizontalPaddingMedium,
                    widget.comment.repliesCount > 0
                        ? GestureDetector(
                            onTap: () {},
                            child: LMTextView(
                              text: widget.comment.repliesCount > 1
                                  ? "${widget.comment.repliesCount}  replies"
                                  : "${widget.comment.repliesCount}  reply",
                              textStyle: const TextStyle(
                                color: kGrey2Color,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(),
                    const Spacer(),
                    LMTextView(
                      text: widget.comment.createdAt.timeAgo(),
                      textStyle: const TextStyle(
                        fontSize: kFontSmallMed,
                        color: kGrey3Color,
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }
}
