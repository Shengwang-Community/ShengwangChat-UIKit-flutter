import '../../chat_uikit.dart';

import 'package:flutter/material.dart';

class ConversationsView extends StatefulWidget {
  /// 会话列表构造方法，如果需要自定义会话列表可以使用这个方法。具体参考 [ConversationsViewArguments]。
  ConversationsView.arguments(ConversationsViewArguments arguments, {super.key})
      : itemBuilder = arguments.itemBuilder,
        beforeWidgets = arguments.beforeWidgets,
        afterWidgets = arguments.afterWidgets,
        onSearchTap = arguments.onSearchTap,
        searchBarHideText = arguments.searchBarHideText,
        emptyBackground = arguments.emptyBackground,
        onItemTap = arguments.onItemTap,
        onItemLongPressHandler = arguments.onItemLongPressHandler,
        appBarModel = arguments.appBarModel,
        controller = arguments.controller,
        enableAppBar = arguments.enableAppBar,
        enableSearchBar = arguments.enableSearchBar,
        viewObserver = arguments.viewObserver,
        moreActionsBuilder = arguments.moreActionsBuilder,
        enablePinHighlight = arguments.enablePinHighlight,
        backgroundWidget = arguments.backgroundWidget,
        attributes = arguments.attributes;

  /// 会话列表构造方法，如果需要自定义会话列表可以使用这个方法。
  const ConversationsView({
    this.itemBuilder,
    this.beforeWidgets,
    this.afterWidgets,
    this.onSearchTap,
    this.searchBarHideText,
    this.emptyBackground,
    this.onItemTap,
    this.onItemLongPressHandler,
    this.appBarModel,
    this.controller,
    this.enableAppBar = true,
    this.enableSearchBar = true,
    this.attributes,
    this.viewObserver,
    this.moreActionsBuilder,
    this.enablePinHighlight = true,
    this.backgroundWidget,
    super.key,
  });

  /// 会话列表控制器，用户管理会话列表数据，如果不设置将会自动创建。详细参考 [ConversationListViewController]。
  final ConversationListViewController? controller;

  /// 会话列表的AppBar模型，用于自定义AppBar。具体参考 [ChatUIKitAppBarModel]。
  final ChatUIKitAppBarModel? appBarModel;

  /// 点击搜索按钮的回调，点击后会把当前的会话列表数据传递过来。如果不设置默认会跳转到搜索页面。具体参考 [SearchView]。
  final void Function(List<ConversationItemModel> data)? onSearchTap;

  /// 会话列表之前的数据。
  final List<Widget>? beforeWidgets;

  /// 会话列表之后的数据。
  final List<Widget>? afterWidgets;

  /// 会话列表的 `item` 构建器，如果设置后需要显示会话时会直接回调，如果不处理可以返回 `null`。
  final ConversationItemBuilder? itemBuilder;

  /// 点击会话列表的回调，点击后会把当前的会话数据传递过来。具体参考 [ConversationItemModel]。 如果不是设置默认会跳转到消息页面。具体参考 [MessagesView]。
  final void Function(BuildContext context, ConversationItemModel info)?
      onItemTap;

  /// 长按会话列表的回调，如果不设置默认会弹出默认的长按菜单。如果设置长按时会把默认的弹出菜单项传给你，你需要调整后返回来，返回来的数据会用于菜单显示，如果返回 `null` 将不会显示菜单。
  final ConversationsViewItemLongPressHandler? onItemLongPressHandler;

  /// 会话搜索框的隐藏文字。
  final String? searchBarHideText;

  /// 是否开启搜索框，默认为 `true`。如果设置为 `false` 将不会显示搜索框。
  final bool enableSearchBar;

  /// 会话列表的背景，会话为空时会显示，如果设置后将会替换默认的背景。
  final Widget? emptyBackground;

  /// 是否显示AppBar, 默认为 `true`。 当为 `false` 时将不会显示AppBar。同时也会影响到是否显示标题。
  final bool enableAppBar;

  /// View 附加属性，设置后的内容将会带入到下一个页面。
  final String? attributes;

  /// 用于刷新页面的Observer
  final ChatUIKitViewObserver? viewObserver;

  /// 更多操作构建器，用于构建更多操作的菜单，如果不设置将会使用默认的菜单。
  final ChatUIKitMoreActionsBuilder? moreActionsBuilder;

  /// 是否开启置顶消息点击高亮，默认为 `true`。如果设置为 `false` 将不会显示置顶高亮。
  final bool enablePinHighlight;

  /// 背景组件，如果设置后将会替换默认的背景组件。
  final Widget? backgroundWidget;

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView>
    with ChatUIKitThemeMixin {
  late ConversationListViewController controller;
  ChatUIKitAppBarModel? appBarModel;
  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ConversationListViewController();
    widget.viewObserver?.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.viewObserver?.dispose();
    super.dispose();
  }

  void updateAppBarModel(ChatUIKitTheme theme) {
    appBarModel = ChatUIKitAppBarModel(
      title: widget.appBarModel?.title ?? 'Chats',
      centerWidget: widget.appBarModel?.centerWidget,
      titleTextStyle: widget.appBarModel?.titleTextStyle ??
          TextStyle(
            color: theme.color.isDark
                ? theme.color.primaryColor6
                : theme.color.primaryColor5,
            fontSize: theme.font.titleLarge.fontSize,
            fontWeight: FontWeight.w900,
          ),
      subtitle: widget.appBarModel?.subtitle,
      subTitleTextStyle: widget.appBarModel?.subTitleTextStyle,
      leadingActions: widget.appBarModel?.leadingActions ??
          () {
            List<ChatUIKitAppBarAction> actions = [];
            actions.add(
              ChatUIKitAppBarAction(
                actionType: ChatUIKitActionType.avatar,
                child: ChatUIKitAvatar.current(
                  size: 32,
                  avatarUrl:
                      ChatUIKitProvider.instance.currentUserProfile?.avatarUrl,
                ),
              ),
            );
            return widget.appBarModel?.leadingActionsBuilder
                    ?.call(context, actions) ??
                actions;
          }(),
      trailingActions: widget.appBarModel?.trailingActions ??
          () {
            List<ChatUIKitAppBarAction> actions = [
              ChatUIKitAppBarAction(
                actionType: ChatUIKitActionType.more,
                onTap: (context) {
                  showMoreInfo();
                },
                child: Icon(
                  Icons.add_circle_outline,
                  size: 24,
                  color: theme.color.isDark
                      ? theme.color.neutralColor95
                      : theme.color.neutralColor3,
                ),
              ),
            ];
            return widget.appBarModel?.trailingActionsBuilder
                    ?.call(context, actions) ??
                actions;
          }(),
      showBackButton: widget.appBarModel?.showBackButton ?? false,
      onBackButtonPressed: widget.appBarModel?.onBackButtonPressed,
      centerTitle: widget.appBarModel?.centerTitle ?? true,
      systemOverlayStyle: widget.appBarModel?.systemOverlayStyle,
      backgroundColor: widget.appBarModel?.backgroundColor,
      bottomLine: widget.appBarModel?.bottomLine,
      bottomLineColor: widget.appBarModel?.bottomLineColor,
      flexibleSpace: widget.appBarModel?.flexibleSpace,
    );
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    updateAppBarModel(theme);
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: widget.enableAppBar ? ChatUIKitAppBar.model(appBarModel!) : null,
      body: SafeArea(
        child: ConversationListView(
          enablePinHighlight: widget.enablePinHighlight,
          enableSearchBar: widget.enableSearchBar,
          controller: controller,
          itemBuilder: widget.itemBuilder,
          beforeWidgets: widget.beforeWidgets,
          afterWidgets: widget.afterWidgets,
          searchBarHideText: widget.searchBarHideText,
          emptyBackground: widget.emptyBackground,
          onTap: widget.onItemTap ??
              (BuildContext context, ConversationItemModel info) {
                pushToMessagePage(info.profile);
              },
          onLongPress: (BuildContext context, ConversationItemModel info) {
            longPressed(info);
          },
          onSearchTap: widget.onSearchTap ?? onSearchTap,
        ),
      ),
    );

    content = Stack(
      children: [
        Container(
          color: theme.color.isDark
              ? theme.color.neutralColor1
              : theme.color.neutralColor98,
          child: widget.backgroundWidget,
        ),
        content,
      ],
    );

    return content;
  }

  void onSearchTap(List<ConversationItemModel> data) {
    List<NeedSearch> list = [];
    for (var item in data) {
      list.add(item);
    }

    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.searchView,
      SearchViewArguments(
          onTap: (ctx, profile) {
            Navigator.of(ctx).pop(profile);
          },
          searchHideText:
              ChatUIKitLocal.conversationsViewSearchHint.localString(context),
          searchData: list,
          attributes: widget.attributes),
    ).then((value) {
      if (value != null && value is ChatUIKitProfile) {
        pushToMessagePage(value);
      }
    });
  }

  void pushToMessagePage(ChatUIKitProfile profile) {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.messagesView,
      MessagesViewArguments(
        profile: profile,
        attributes: widget.attributes,
      ),
    ).then((value) {
      if (mounted && value != null) {
        controller.reload();
      }
    });
  }

  void longPressed(ConversationItemModel info) async {
    List<ChatUIKitEventAction>? list;
    if (widget.onItemLongPressHandler != null) {
      list = widget.onItemLongPressHandler
          ?.call(context, info, defaultLongPressActions(info));
    } else {
      list = defaultLongPressActions(info);
    }

    if (list?.isNotEmpty == true) {
      showChatUIKitBottomSheet(
        cancelLabel: ChatUIKitLocal.conversationListLongPressMenuCancel
            .localString(context),
        context: context,
        items: list!,
      );
    }
  }

  List<ChatUIKitEventAction> defaultLongPressActions(
      ConversationItemModel info) {
    return [
      ChatUIKitEventAction.normal(
        actionType: ChatUIKitActionType.mute,
        label: info.noDisturb
            ? ChatUIKitLocal.conversationListLongPressMenuUnmute
                .localString(context)
            : ChatUIKitLocal.conversationListLongPressMenuMute
                .localString(context),
        onTap: () async {
          final type = info.profile.type == ChatUIKitProfileType.group
              ? ConversationType.GroupChat
              : ConversationType.Chat;

          if (info.noDisturb) {
            ChatUIKit.instance.clearSilentMode(
              conversationId: info.profile.id,
              type: type,
            );
          } else {
            final param = ChatSilentModeParam.remindType(
              ChatPushRemindType.MENTION_ONLY,
            );
            ChatUIKit.instance.setSilentMode(
              param: param,
              conversationId: info.profile.id,
              type: type,
            );
          }

          Navigator.of(context).pop();
        },
      ),
      ChatUIKitEventAction.normal(
        actionType: ChatUIKitActionType.pinConversation,
        label: info.pinned
            ? ChatUIKitLocal.conversationListLongPressMenuUnPin
                .localString(context)
            : ChatUIKitLocal.conversationListLongPressMenuPin
                .localString(context),
        onTap: () async {
          ChatUIKit.instance.pinConversation(
            conversationId: info.profile.id,
            isPinned: !info.pinned,
          );
          Navigator.of(context).pop();
        },
      ),
      if (info.unreadCount > 0)
        ChatUIKitEventAction.normal(
          actionType: ChatUIKitActionType.read,
          label: ChatUIKitLocal.conversationListLongPressMenuRead
              .localString(context),
          onTap: () async {
            ChatUIKit.instance.markConversationAsRead(
              conversationId: info.profile.id,
            );
            Navigator.of(context).pop();
          },
        ),
      ChatUIKitEventAction.destructive(
        actionType: ChatUIKitActionType.delete,
        label: ChatUIKitLocal.conversationListLongPressMenuDelete
            .localString(context),
        onTap: () async {
          ChatUIKit.instance.deleteLocalConversation(
            conversationId: info.profile.id,
          );
          Navigator.of(context).pop();
        },
      ),
    ];
  }

  void showMoreInfo() {
    List<ChatUIKitEventAction> list = defaultItems();
    list = widget.moreActionsBuilder?.call(context, list) ?? list;
    showChatUIKitBottomSheet(
      cancelLabel:
          ChatUIKitLocal.conversationsViewMenuCancel.localString(context),
      context: context,
      items: list,
    );
  }

  List<ChatUIKitEventAction> defaultItems() {
    return [
      ChatUIKitEventAction.normal(
        actionType: ChatUIKitActionType.newChat,
        label: ChatUIKitLocal.conversationsViewMenuCreateNewChat
            .localString(context),
        icon: Icon(
          Icons.message,
          color: theme.color.isDark
              ? theme.color.primaryColor5
              : theme.color.primaryColor5,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          newConversations();
        },
      ),
      ChatUIKitEventAction.normal(
        actionType: ChatUIKitActionType.addContact,
        label:
            ChatUIKitLocal.conversationsViewMenuAddContact.localString(context),
        icon: Icon(
          Icons.person_add_alt_1,
          color: theme.color.isDark
              ? theme.color.primaryColor5
              : theme.color.primaryColor5,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          addContact();
        },
      ),
      ChatUIKitEventAction.normal(
        actionType: ChatUIKitActionType.create,
        label: ChatUIKitLocal.conversationsViewMenuCreateGroup
            .localString(context),
        icon: Icon(
          Icons.group,
          color: theme.color.isDark
              ? theme.color.primaryColor5
              : theme.color.primaryColor5,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          newGroup();
        },
      ),
    ];
  }

  void newConversations() async {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.selectContactsView,
      SelectContactViewArguments(
        appBarModel: ChatUIKitAppBarModel(
            title: ChatUIKitLocal.conversationsViewMenuCreateNewChat
                .localString(context)),
        attributes: widget.attributes,
      ),
    ).then((profile) {
      if (profile != null && profile is ChatUIKitProfile) {
        pushNewConversation(profile);
      }
    });
  }

  void addContact() async {
    String? userId = await showChatUIKitDialog(
      title: ChatUIKitLocal.addContactTitle.localString(context),
      content: ChatUIKitLocal.addContactSubTitle.localString(context),
      context: context,
      inputItems: [
        ChatUIKitDialogInputContentItem(
          hintText: ChatUIKitLocal.addContactInputHints.localString(context),
        ),
      ],
      actionItems: [
        ChatUIKitDialogAction.cancel(
          label: ChatUIKitLocal.addContactCancel.localString(context),
          onTap: () async {
            Navigator.of(context).pop();
          },
        ),
        ChatUIKitDialogAction.inputsConfirm(
          label: ChatUIKitLocal.addContactConfirm.localString(context),
          onInputsTap: (inputs) async {
            Navigator.of(context).pop(inputs.first);
          },
        ),
      ],
    );

    if (userId?.isNotEmpty == true) {
      try {
        await ChatUIKit.instance.sendContactRequest(userId: userId!);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  void newGroup() async {
    final group = await ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.createGroupView,
      CreateGroupViewArguments(
        attributes: widget.attributes,
      ),
    );

    if (group is Group) {
      pushNewConversation(ChatUIKitProfile.group(
        id: group.groupId,
        groupName: group.name,
      ));
    }
  }

  void pushNewConversation(ChatUIKitProfile profile) {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.messagesView,
      MessagesViewArguments(
        profile: profile,
        attributes: widget.attributes,
      ),
    ).then((value) {
      if (mounted && value != null) {
        controller.reload();
      }
    });
  }
}
