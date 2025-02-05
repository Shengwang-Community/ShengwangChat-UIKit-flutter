import '../../chat_uikit.dart';

import 'package:flutter/material.dart';

class ThreadMembersView extends StatefulWidget {
  ThreadMembersView.arguments(
    ThreadMembersViewArguments arguments, {
    super.key,
  })  : thread = arguments.thread,
        attributes = arguments.attributes,
        viewObserver = arguments.viewObserver,
        enableAppBar = arguments.enableAppBar,
        appBarModel = arguments.appBarModel,
        controller = arguments.controller;

  const ThreadMembersView({
    required this.thread,
    super.key,
    this.attributes,
    this.controller,
    this.enableAppBar = true,
    this.appBarModel,
    this.viewObserver,
  });

  final String? attributes;
  final ChatUIKitViewObserver? viewObserver;

  final ChatThread thread;
  final ThreadMembersViewController? controller;
  final bool enableAppBar;
  final ChatUIKitAppBarModel? appBarModel;

  @override
  State<ThreadMembersView> createState() => _ThreadMembersViewState();
}

class _ThreadMembersViewState extends State<ThreadMembersView>
    with ChatUIKitProviderObserver, ChatUIKitThemeMixin {
  late ThreadMembersViewController controller;
  late final ScrollController _scrollController = ScrollController();
  ChatUIKitAppBarModel? appBarModel;
  @override
  void initState() {
    super.initState();
    ChatUIKitProvider.instance.addObserver(this);
    controller = widget.controller ??
        ThreadMembersViewController(
          thread: widget.thread,
        );

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    controller.fetchMembers();
  }

  @override
  void dispose() {
    ChatUIKitProvider.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void onProfilesUpdate(Map<String, ChatUIKitProfile> map) {
    if (controller.modelsList
        .any((element) => map.keys.contains(element.profile.id))) {
      for (var i = 0; i < controller.modelsList.length; i++) {
        controller.modelsList[i].profile =
            map[controller.modelsList[i].profile.id]!;
      }
      setState(() {});
    }
  }

  void updateAppBarModel(ChatUIKitTheme theme) {
    appBarModel = ChatUIKitAppBarModel(
      title: widget.appBarModel?.title ??
          ChatUIKitLocal.threadMembers.localString(context),
      centerWidget: widget.appBarModel?.centerWidget,
      titleTextStyle: widget.appBarModel?.titleTextStyle ??
          TextStyle(
            color: theme.color.isDark
                ? theme.color.neutralColor98
                : theme.color.neutralColor1,
            fontWeight: theme.font.titleMedium.fontWeight,
            fontSize: theme.font.titleMedium.fontSize,
          ),
      subtitle: widget.appBarModel?.subtitle,
      subTitleTextStyle: widget.appBarModel?.subTitleTextStyle,
      leadingActions: widget.appBarModel?.leadingActions ??
          widget.appBarModel?.leadingActionsBuilder?.call(context, null),
      trailingActions: widget.appBarModel?.trailingActions ??
          widget.appBarModel?.trailingActionsBuilder?.call(context, null),
      showBackButton: widget.appBarModel?.showBackButton ?? true,
      onBackButtonPressed: widget.appBarModel?.onBackButtonPressed,
      centerTitle: widget.appBarModel?.centerTitle ?? false,
      systemOverlayStyle: widget.appBarModel?.systemOverlayStyle,
      backgroundColor: widget.appBarModel?.backgroundColor,
      bottomLine: widget.appBarModel?.bottomLine,
      bottomLineColor: widget.appBarModel?.bottomLineColor,
    );
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    updateAppBarModel(theme);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.color.isDark
          ? theme.color.neutralColor1
          : theme.color.neutralColor98,
      appBar: widget.enableAppBar ? ChatUIKitAppBar.model(appBarModel!) : null,
      body: SafeArea(
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (_scrollController.position.pixels -
                      _scrollController.position.maxScrollExtent >
                  -1500) {
                controller.fetchMembers();
              }
            }

            return true;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (ctx, index) {
              return ChatUIKitContactListViewItem(controller.modelsList[index]);
            },
            itemCount: controller.modelsList.length,
          ),
        ),
      ),
    );
  }
}
