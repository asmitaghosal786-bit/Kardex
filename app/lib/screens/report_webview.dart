import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportWebView extends StatefulWidget {
  const ReportWebView({required this.path, required this.code, super.key});

  final String path;
  final String code;

  @override
  State<ReportWebView> createState() => _ReportWebViewState();
}

class _ReportWebViewState extends State<ReportWebView> {
  late final WebViewController _controller;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    const webUrl = String.fromEnvironment(
      'GUARDIAN_WEB_URL',
      defaultValue: 'http://10.0.2.2:5173',
    );
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _loadError = 'Could not load the report: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          '$webUrl/#${widget.path}?code=${Uri.encodeQueryComponent(widget.code)}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kardex')),
      body: _loadError == null
          ? WebViewWidget(controller: _controller)
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_loadError!, textAlign: TextAlign.center),
              ),
            ),
    );
  }
}
