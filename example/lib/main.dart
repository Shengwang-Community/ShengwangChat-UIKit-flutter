import 'package:shengwang_chat_uikit/chat_uikit.dart';
import 'package:example/demo/debug_login_page.dart';
import 'package:example/demo/demo_localizations.dart';
import 'package:example/demo/home_page.dart';

import 'package:example/demo/custom/chat_route_filter.dart';
import 'package:example/demo/pages/me/settings/advanced_page.dart';
import 'package:example/demo/pages/me/settings/general_page.dart';
import 'package:example/demo/pages/me/settings/language_page.dart';
import 'package:example/demo/pages/me/settings/translate_page.dart';
import 'package:example/demo/tool/settings_data_store.dart';
import 'package:example/welcome_page.dart';
import 'package:example/sample_demo/custom_home_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

// 主函数：初始化设置并启动应用
void main() async {
  SettingsDataStore().init();
  // 设置应用只支持竖屏模式
  return SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 创建本地化实例
  final ChatUIKitLocalizations _localization = ChatUIKitLocalizations();

  @override
  void initState() {
    super.initState();

    // 设置默认语言配置（中文和英文）
    _localization.defaultLocale = [
      ChatLocal(
        'zh',
        Map.from(ChatUIKitLocal.zh)..addAll(DemoLocalizations.zh),
      ),
      ChatLocal(
        'en',
        Map.from(ChatUIKitLocal.en)..addAll(DemoLocalizations.en),
      )
    ];
    // 重置本地化配置
    _localization.resetLocales();
    // 设置输入栏圆角
    ChatUIKitSettings.inputBarRadius = CornerRadius.medium;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 配置本地化支持
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
      localeResolutionCallback: _localization.localeResolutionCallback,
      locale: _localization.currentLocale,

      // 主题配置
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),

      // 加载动画构建器
      builder: EasyLoading.init(),
      // 初始页面
      home: const WelcomePage(), // 欢迎页面

      // 路由生成器：处理应用内的页面导航
      onGenerateRoute: (settings) {
        // 使用自定义路由过滤器处理聊天相关路由
        RouteSettings newSettings = ChatRouteFilter.chatRouteSettings(settings);
        return ChatUIKitRoute().generateRoute(newSettings) ??
            MaterialPageRoute(
              builder: (context) {
                // 根据路由名称返回对应页面
                if (settings.name == '/sample_demo') {
                  return const CustomHomePage();
                } else if (settings.name == '/home') {
                  return const HomePage();
                } else if (settings.name == '/login') {
                  return const DebugLoginPage();
                } else if (settings.name == '/debug_login') {
                  return const DebugLoginPage();
                } else if (settings.name == '/general_page') {
                  return const GeneralPage();
                } else if (settings.name == '/language_page') {
                  return const LanguagePage();
                } else if (settings.name == '/translate_page') {
                  return const TranslatePage();
                } else if (settings.name == '/advanced_page') {
                  return const AdvancedPage();
                } else {
                  return const SizedBox();
                }
              },
            );
      },
    );
  }
}
