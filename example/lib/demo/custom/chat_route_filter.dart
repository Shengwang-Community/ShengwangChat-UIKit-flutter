import 'package:shengwang_chat_uikit/chat_uikit.dart';
import 'package:example/demo/demo_localizations.dart';

import 'package:example/demo/pages/help/download_page.dart';
import 'package:example/demo/tool/user_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChatRouteFilter {
  static RouteSettings chatRouteSettings(RouteSettings settings) {
    // 拦截 ChatUIKitRouteNames.messagesView, 之后对要跳转的页面的 `RouteSettings` 进行自定义，之后返回。
    if (settings.name == ChatUIKitRouteNames.messagesView) {
      return messagesView(settings);
    } else if (settings.name == ChatUIKitRouteNames.createGroupView) {
      return createGroupView(settings);
    } else if (settings.name == ChatUIKitRouteNames.contactDetailsView) {
      return contactDetails(settings);
    } else if (settings.name == ChatUIKitRouteNames.groupDetailsView) {
      return groupDetails(settings);
    }
    return settings;
  }

  static RouteSettings groupDetails(RouteSettings settings) {
    ChatUIKitViewObserver? viewObserver = ChatUIKitViewObserver();
    GroupDetailsViewArguments arguments =
        settings.arguments as GroupDetailsViewArguments;

    arguments = arguments.copyWith(
      viewObserver: viewObserver,
    );
    Future(() async {
      Group group = await ChatUIKit.instance
          .fetchGroupInfo(groupId: arguments.profile.id);
      ChatUIKitProfile profile = arguments.profile
          .copyWith(showName: group.name, avatarUrl: group.extension);
      ChatUIKitProvider.instance.addProfiles([profile]);
      UserDataStore().saveUserData(profile);
    }).then((value) {
      // 刷新ui
      viewObserver.refresh();
    }).catchError((e) {
      debugPrint('fetch group info error');
    });
    return RouteSettings(name: settings.name, arguments: arguments);
  }

  // 自定义 contact detail view
  static RouteSettings contactDetails(RouteSettings settings) {
    ChatUIKitViewObserver? viewObserver = ChatUIKitViewObserver();
    ContactDetailsViewArguments arguments =
        settings.arguments as ContactDetailsViewArguments;

    arguments = arguments.copyWith(
      viewObserver: viewObserver,

      // 添加 remark 实现
      itemsBuilder: (context, profile, models) {
        return [
          ChatUIKitDetailsListViewItemModel(
            title: DemoLocalizations.contactRemark.localString(context),
            trailing: Text(
              ChatUIKitProvider.instance.getProfile(arguments.profile).remark ??
                  '',
              textScaler: TextScaler.noScaling,
            ),
            onTap: () async {
              String errStr =
                  DemoLocalizations.contactRemarkFailed.localString(context);
              String? remark = await showChatUIKitDialog(
                context: context,
                title: DemoLocalizations.contactRemark.localString(context),
                inputItems: [
                  ChatUIKitDialogInputContentItem(
                    hintText: DemoLocalizations.contactRemarkDesc
                        .localString(context),
                    maxLength: 32,
                  )
                ],
                actionItems: [
                  ChatUIKitDialogAction.inputsConfirm(
                    label: DemoLocalizations.contactRemarkConfirm
                        .localString(context),
                    onInputsTap: (inputs) async {
                      Navigator.of(context).pop(inputs.first);
                    },
                  ),
                  ChatUIKitDialogAction.cancel(
                      label: DemoLocalizations.contactRemarkCancel
                          .localString(context)),
                ],
              );

              if (remark?.isNotEmpty == true) {
                ChatUIKit.instance
                    .updateContactRemark(arguments.profile.id, remark!)
                    .then((value) {
                  ChatUIKitProfile profile =
                      arguments.profile.copyWith(remark: remark);
                  // 更新数据，并设置到provider中
                  UserDataStore().saveUserData(profile);
                  ChatUIKitProvider.instance.addProfiles([profile]);
                }).catchError((e) {
                  EasyLoading.showError(errStr);
                });
              }
            },
          ),
          ...models,
        ];
      },
    );

    // 异步更新用户信息
    Future(() async {
      String userId = arguments.profile.id;
      try {
        Map<String, UserInfo> map =
            await ChatUIKit.instance.fetchUserInfoByIds([userId]);
        UserInfo? userInfo = map[userId];
        Contact? contact = await ChatUIKit.instance.getContact(userId);
        if (contact != null) {
          ChatUIKitProfile profile = ChatUIKitProfile.contact(
            id: contact.userId,
            nickname: userInfo?.nickName,
            avatarUrl: userInfo?.avatarUrl,
            remark: contact.remark,
          );
          // 更新数据，并设置到provider中
          UserDataStore().saveUserData(profile);
          ChatUIKitProvider.instance.addProfiles([profile]);
        }
      } catch (e) {
        debugPrint('fetch user info error');
      }
    }).then((value) {
      viewObserver.refresh();
    }).catchError((e) {});

    return RouteSettings(name: settings.name, arguments: arguments);
  }

  // 为 MessagesView 添加文件点击下载
  static RouteSettings messagesView(RouteSettings settings) {
    MessagesViewArguments arguments =
        settings.arguments as MessagesViewArguments;
    ChatUIKitViewObserver viewObserver = ChatUIKitViewObserver();

    arguments = arguments.copyWith(
      viewObserver: viewObserver,
      showMessageItemNickname: (model) {
        // 只有群组消息并且不是自己发的消息显示昵称
        return (arguments.profile.type == ChatUIKitProfileType.group) &&
            model.message.from != ChatUIKit.instance.currentUserId;
      },
      bubbleContentBuilder: (context, model) {
        if (model.message.bodyType == MessageType.TXT) {
          return ChatUIKitTextBubbleWidget(
            model: model,
            onExpTap: (expStr) {
              debugPrint('expStr: $expStr');
            },
          );
        }
        return null;
      },
      onItemTap: (ctx, messageModel, rect) {
        if (messageModel.message.bodyType == MessageType.FILE) {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (context) => DownloadFileWidget(
                message: messageModel.message,
                key: ValueKey(messageModel.message.localTime),
              ),
            ),
          );
          return true;
        }
        return false;
      },
    );

    return RouteSettings(name: settings.name, arguments: arguments);
  }

  // 添加创建群组拦截，并添加设置群名称功能
  static RouteSettings createGroupView(RouteSettings settings) {
    CreateGroupViewArguments arguments =
        settings.arguments as CreateGroupViewArguments;
    arguments = arguments.copyWith(
      createGroupHandler: (context, selectedProfiles) async {
        String? groupName = await showChatUIKitDialog(
          context: context,
          title: DemoLocalizations.createGroupName.localString(context),
          inputItems: [
            ChatUIKitDialogInputContentItem(
              hintText: DemoLocalizations.createGroupDesc.localString(context),
              maxLength: 32,
            )
          ],
          actionItems: [
            ChatUIKitDialogAction.cancel(
              label: DemoLocalizations.createGroupCancel.localString(context),
            ),
            ChatUIKitDialogAction.inputsConfirm(
              label: DemoLocalizations.createGroupConfirm.localString(context),
              onInputsTap: (inputs) async {
                Navigator.of(context).pop(inputs.first);
              },
            ),
          ],
        );

        if (groupName != null) {
          return CreateGroupInfo(
            inviteMembers: [selectedProfiles.first],
            groupName: groupName,
            onGroupCreateCallback: (group, error) {
              if (error != null) {
                showChatUIKitDialog(
                  context: context,
                  title:
                      DemoLocalizations.createGroupFailed.localString(context),
                  content: error.description,
                  actionItems: [
                    ChatUIKitDialogAction.confirm(
                        label: DemoLocalizations.createGroupConfirm
                            .localString(context)),
                  ],
                );
              } else {
                Navigator.of(context).pop();

                if (group != null) {
                  ChatUIKitRoute.pushOrPushNamed(
                    context,
                    ChatUIKitRouteNames.messagesView,
                    MessagesViewArguments(
                      profile: ChatUIKitProfile.group(
                        id: group.groupId,
                        groupName: group.name,
                      ),
                    ),
                  );
                }
              }
            },
          );
        } else {
          return null;
        }
      },
    );

    return RouteSettings(name: settings.name, arguments: arguments);
  }
}
