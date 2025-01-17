import 'package:shengwang_chat_uikit/chat_uikit.dart';
import 'package:example/welcome_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DebugLoginPage extends StatefulWidget {
  const DebugLoginPage({super.key});

  @override
  State<DebugLoginPage> createState() => _DebugLoginPageState();
}

class _DebugLoginPageState extends State<DebugLoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text('APPID:'),
                Expanded(
                  child: TextField(
                    enabled: !hasInited,
                    decoration: const InputDecoration(
                      hintText: 'appId',
                    ),
                    onChanged: (value) {
                      setState(() {
                        appId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(context);
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: hasInited ? changeInfo : null,
              child: const Text('ChangAppInfo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDialog(BuildContext context) async {
    List<ChatUIKitDialogAction> list = [];
    list.add(
      ChatUIKitDialogAction.cancel(
        label: 'Cancel',
        onTap: () async {
          Navigator.of(context).pop();
        },
      ),
    );
    list.add(
      ChatUIKitDialogAction.inputsConfirm(
        label: 'Confirm',
        onInputsTap: (List<String> inputs) async {
          Navigator.of(context).pop(inputs);
        },
      ),
    );

    dynamic ret = await showChatUIKitDialog(
      context: context,
      inputItems: [
        ChatUIKitDialogInputContentItem(
          hintText: 'UserId',
        ),
        ChatUIKitDialogInputContentItem(
          hintText: 'Password',
        ),
      ],
      actionItems: list,
    );

    if (ret != null) {
      await initSDK();
      login((ret as List<String>).first, ret.last);
    }
  }

  // 初始化聊天 UI 套件
  Future<void> initSDK() async {
    await ChatUIKit.instance
        .init(options: Options.withAppId(appId, autoLogin: false));
    hasInited = true;
  }

  void login(String userId, String password) async {
    EasyLoading.show(status: 'Loading...');
    ChatUIKit.instance
        .loginWithPassword(userId: userId, password: password)
        .then((value) {
      toSampleDemo();
    }).catchError((e) {
      EasyLoading.showError(e.toString());
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  Future<void> changeInfo() async {
    String? inputs = await showChatUIKitDialog(
      context: context,
      inputItems: [
        ChatUIKitDialogInputContentItem(hintText: 'appId'),
      ],
      actionItems: [
        ChatUIKitDialogAction.cancel(
          label: '取消',
        ),
        ChatUIKitDialogAction.inputsConfirm(
            label: '确定',
            onInputsTap: (List<String> inputs) async {
              Navigator.of(context).pop(inputs.first);
            }),
      ],
    );
    if (inputs?.isNotEmpty == true) {
      try {
        ChatUIKit.instance.changeAppId(inputs!);
        appId = inputs;
      } catch (e) {
        EasyLoading.showError(e.toString());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toSampleDemo() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/sample_demo', (Route<dynamic> route) => false);
  }
}
