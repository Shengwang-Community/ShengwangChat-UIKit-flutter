import '../../chat_uikit.dart';

import 'package:flutter/material.dart';

class CreateGroupView extends StatefulWidget {
  CreateGroupView.arguments(
    CreateGroupViewArguments arguments, {
    super.key,
  })  : itemBuilder = arguments.itemBuilder,
        onSearchTap = arguments.onSearchTap,
        searchBarHideText = arguments.searchBarHideText,
        listViewBackground = arguments.listViewBackground,
        onItemTap = arguments.onItemTap,
        onItemLongPress = arguments.onItemLongPress,
        appBarModel = arguments.appBarModel,
        enableAppBar = arguments.enableAppBar,
        createHandler = arguments.createGroupHandler,
        createGroupInfo = arguments.createGroupInfo,
        controller = arguments.controller,
        viewObserver = arguments.viewObserver,
        attributes = arguments.attributes;

  const CreateGroupView({
    this.itemBuilder,
    this.onSearchTap,
    this.createGroupInfo,
    this.searchBarHideText,
    this.listViewBackground,
    this.onItemTap,
    this.onItemLongPress,
    this.appBarModel,
    this.controller,
    this.enableAppBar = true,
    this.createHandler,
    this.attributes,
    this.viewObserver,
    super.key,
  });

  final ContactListViewController? controller;
  final ChatUIKitAppBarModel? appBarModel;
  final void Function(List<ContactItemModel> data)? onSearchTap;
  final CreateGroupInfo? createGroupInfo;

  final ChatUIKitContactItemBuilder? itemBuilder;
  final void Function(ContactItemModel model)? onItemTap;
  final void Function(ContactItemModel model)? onItemLongPress;
  final String? searchBarHideText;
  final Widget? listViewBackground;
  final bool enableAppBar;
  final CreateGroupHandler? createHandler;
  final String? attributes;

  /// 用于刷新页面的Observer
  final ChatUIKitViewObserver? viewObserver;

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView>
    with ChatUIKitThemeMixin {
  late final ContactListViewController controller;
  List<ChatUIKitProfile> selectedProfiles = [];
  ChatUIKitAppBarModel? appBarModel;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ContactListViewController();
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
      title: widget.appBarModel?.title ??
          ChatUIKitLocal.createGroupViewTitle.localString(context),
      centerWidget: widget.appBarModel?.centerWidget,
      titleTextStyle: widget.appBarModel?.titleTextStyle,
      subtitle: widget.appBarModel?.subtitle,
      subTitleTextStyle: widget.appBarModel?.subTitleTextStyle,
      leadingActions: widget.appBarModel?.leadingActions ??
          widget.appBarModel?.leadingActionsBuilder?.call(context, null),
      trailingActions: widget.appBarModel?.trailingActions ??
          () {
            List<ChatUIKitAppBarAction> actions = [
              ChatUIKitAppBarAction(
                actionType: ChatUIKitActionType.create,
                onTap: (context) {
                  if (selectedProfiles.isEmpty) {
                    return;
                  }
                  createGroup();
                },
                child: Text(
                  selectedProfiles.isEmpty
                      ? ChatUIKitLocal.createGroupViewCreate
                          .localString(context)
                      : '${ChatUIKitLocal.createGroupViewCreate.localString(context)}(${selectedProfiles.length})',
                  textScaler: TextScaler.noScaling,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.color.isDark
                        ? theme.color.primaryColor6
                        : theme.color.primaryColor5,
                    fontWeight: theme.font.labelMedium.fontWeight,
                    fontSize: theme.font.labelMedium.fontSize,
                  ),
                ),
              ),
            ];
            return widget.appBarModel?.trailingActionsBuilder
                    ?.call(context, actions) ??
                actions;
          }(),
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
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.color.isDark
          ? theme.color.neutralColor1
          : theme.color.neutralColor98,
      appBar: widget.enableAppBar ? ChatUIKitAppBar.model(appBarModel!) : null,
      body: ContactListView(
        controller: controller,
        itemBuilder: widget.itemBuilder ??
            (context, model) {
              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  tapContactInfo(model.profile);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 19.5, right: 15.5),
                  child: Row(
                    children: [
                      selectedProfiles.contains(model.profile)
                          ? Icon(
                              Icons.check_box,
                              size: 28,
                              color: theme.color.isDark
                                  ? theme.color.primaryColor6
                                  : theme.color.primaryColor5,
                            )
                          : Icon(
                              Icons.check_box_outline_blank,
                              size: 28,
                              color: theme.color.isDark
                                  ? theme.color.neutralColor4
                                  : theme.color.neutralColor7,
                            ),
                      Expanded(child: ChatUIKitContactListViewItem(model))
                    ],
                  ),
                ),
              );
            },
        searchBarHideText: widget.searchBarHideText,
        emptyBackground: widget.listViewBackground,
        onSearchTap: widget.onSearchTap ?? onSearchTap,
      ),
    );

    return content;
  }

  void onSearchTap(List<ContactItemModel> data) async {
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
                canChangeSelected: selectedProfiles,
                searchHideText: ChatUIKitLocal.createGroupViewSearchContact
                    .localString(context),
                searchData: list,
                enableMulti: true,
                attributes: widget.attributes))
        .then(
      (value) {
        if (value is List<ChatUIKitProfile>) {
          selectedProfiles = [...value];
          setState(() {});
        }
      },
    );
  }

  void tapContactInfo(ChatUIKitProfile profile) {
    List<ChatUIKitProfile> list = selectedProfiles;
    if (list.contains(profile)) {
      list.remove(profile);
    } else {
      list.add(profile);
    }

    selectedProfiles = [...list];
    setState(() {});
  }

  void createGroup() async {
    CreateGroupInfo? info;
    if (widget.createHandler != null) {
      info = await widget.createHandler!(
        context,
        selectedProfiles,
      );
      if (info == null) {
        return;
      }
    }
    List<ChatUIKitProfile> inviteMembers =
        info?.inviteMembers ?? selectedProfiles;
    List<String> userIds = inviteMembers.map((e) => e.id).toList();
    ChatUIKit.instance
        .createGroup(
      groupName: widget.createGroupInfo?.groupName ??
          info?.groupName ??
          [
            ...inviteMembers +
                [
                  ChatUIKitProvider.instance.currentUserProfile ??
                      ChatUIKitProfile.contact(
                          id: ChatUIKit.instance.currentUserId!)
                ]
          ].map((e) => e.contactShowName).join(','),
      desc: info?.groupDesc ?? widget.createGroupInfo?.groupDesc,
      options: GroupOptions(
        maxCount: info?.maxCount ?? widget.createGroupInfo?.maxCount ?? 1000,
        style: info?.style ??
            widget.createGroupInfo?.style ??
            GroupStyle.PrivateMemberCanInvite,
        inviteNeedConfirm: info?.inviteNeedConfirm ??
            widget.createGroupInfo?.inviteNeedConfirm ??
            false,
        ext: info?.ext ?? widget.createGroupInfo?.ext,
      ),
      inviteMembers: userIds,
    )
        .then((value) {
      if (info?.onGroupCreateCallback != null) {
        info?.onGroupCreateCallback?.call(value, null);
      } else {
        if (mounted) {
          Navigator.of(context).pop(value);
        }
      }
    }).catchError((e) {
      info?.onGroupCreateCallback?.call(null, e);
    });
  }
}

class CreateGroupInfo {
  CreateGroupInfo({
    required this.groupName,
    this.groupDesc,
    this.groupAvatar,
    this.onGroupCreateCallback,
    this.inviteMembers,
    this.maxCount = 1000,
    this.style = GroupStyle.PrivateMemberCanInvite,
    this.inviteNeedConfirm = false,
    this.ext,
  });

  final String groupName;
  final String? groupDesc;
  final String? groupAvatar;
  final GroupCreateCallback? onGroupCreateCallback;
  final List<ChatUIKitProfile>? inviteMembers;
  final GroupStyle style;
  final int maxCount;
  final bool inviteNeedConfirm;
  final String? ext;
}
