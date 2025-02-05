import '../../../chat_uikit.dart';
import 'package:flutter/material.dart';

typedef EmojiClick = void Function(String emoji);

class ChatUIKitEmojiPanel extends StatelessWidget {
  final double maxCrossAxisExtent;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  final double bigSizeRatio;

  final EmojiClick? emojiClicked;

  final VoidCallback? deleteOnTap;

  final EdgeInsets? padding;

  final List<String>? selectedEmojis;

  final Color? selectedColor;

  const ChatUIKitEmojiPanel({
    super.key,
    this.maxCrossAxisExtent = 36,
    this.mainAxisSpacing = 19.0,
    this.crossAxisSpacing = 19.0,
    this.childAspectRatio = 1.0,
    this.bigSizeRatio = 0.0,
    this.emojiClicked,
    this.padding,
    this.deleteOnTap,
    this.selectedColor,
    this.selectedEmojis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChatUIKitTheme.instance;
    Widget content = GridView.custom(
      shrinkWrap: true,
      padding: padding ??
          const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 60),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: maxCrossAxisExtent,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, position) => _getEmojiItemContainer(position),
        childCount: ChatUIKitEmojiData.listSize,
      ),
    );
    if (deleteOnTap != null) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: 20,
            bottom: 20,
            width: 36,
            height: 36,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                deleteOnTap?.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: theme.color.isDark
                      ? ChatUIKitShadow.darkSmall
                      : ChatUIKitShadow.lightSmall,
                  borderRadius: BorderRadius.circular(24),
                  color: (theme.color.isDark
                      ? theme.color.neutralColor3
                      : theme.color.neutralColor98),
                ),
                child: ChatUIKitImageLoader.emojiDelete(
                  size: 20,
                  color: (theme.color.isDark
                      ? theme.color.neutralColor98
                      : theme.color.neutralColor3),
                ),
              ),
            ),
          ),
        ],
      );
    }

    content = ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            theme.color.isDark
                ? theme.color.neutralColor3
                : theme.color.neutralColor98,
          ],
          stops: const [0.05, 0.9, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: content,
    );

    return content;
  }

  _getEmojiItemContainer(int index) {
    var emojiPath = ChatUIKitEmojiData.emojiImagePaths[index];
    bool highlight =
        selectedEmojis?.contains(ChatUIKitEmojiData.getEmoji(emojiPath)) ??
            false;
    return ChatExpression(
      emojiPath,
      bigSizeRatio,
      emojiClicked,
      highlightedColor: selectedColor,
      highlighted: highlight,
    );
  }
}

class ChatExpression extends StatelessWidget {
  final String emojiName;

  final double bigSizeRatio;

  final EmojiClick? emojiClicked;

  final bool highlighted;

  final Color? highlightedColor;

  const ChatExpression(
    this.emojiName,
    this.bigSizeRatio,
    this.emojiClicked, {
    this.highlighted = false,
    this.highlightedColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Image.asset(
      emojiName,
      package: ChatUIKitEmojiData.packageName,
      width: 32,
      height: 32,
    );
    return Container(
      padding: const EdgeInsets.all(3.2),
      decoration: BoxDecoration(
        color: highlighted ? highlightedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          emojiClicked?.call(emojiName);
        },
        child: icon,
      ),
    );
  }
}
