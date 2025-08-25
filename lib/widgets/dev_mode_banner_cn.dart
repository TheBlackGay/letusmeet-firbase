import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_config.dart';

class DevModeBanner extends StatelessWidget {
  final Widget child;

  const DevModeBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDevelopmentMode) {
      return child;
    }

    return Stack(
      children: [
        child,
        // Development mode banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.developer_mode, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '开发模式',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(delay: 2000.ms, duration: 1000.ms),
        ),
        // Quick dev actions
        if (AppConfig.showDevPanel)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: "dev_panel",
              onPressed: () => _showDevPanel(context),
              backgroundColor: Colors.orange,
              child: Icon(Icons.settings, color: Colors.white),
            ).animate().scale(delay: 1000.ms),
          ),
      ],
    );
  }

  void _showDevPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '开发者面板',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.data_usage),
              title: Text('模拟数据: ${AppConfig.useMockData ? "开启" : "关闭"}'),
              subtitle: Text('使用${AppConfig.useMockData ? "虚拟" : "真实"}数据'),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('身份验证: ${AppConfig.skipAuthentication ? "跳过" : "必需"}'),
              subtitle: Text('身份验证${AppConfig.skipAuthentication ? "已绕过" : "已启用"}'),
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('调试功能: ${AppConfig.enableDebugFeatures ? "开启" : "关闭"}'),
              subtitle: Text('额外的调试工具可用'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('要更改设置，请修改 AppConfig.isDevelopmentMode'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}