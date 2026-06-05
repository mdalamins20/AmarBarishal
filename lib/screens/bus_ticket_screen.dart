import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/auto_translated_text.dart';

class BusTicketScreen extends StatefulWidget {
  final String providerName;
  final String url;
  final String fromCity;

  const BusTicketScreen({
    super.key,
    required this.providerName,
    required this.url,
    required this.fromCity,
  });

  @override
  State<BusTicketScreen> createState() => _BusTicketScreenState();
}

class _BusTicketScreenState extends State<BusTicketScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            final todayStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());
            final jsCode = _getInjectionScript(widget.providerName, widget.fromCity, todayStr);
            _controller.runJavaScript(jsCode);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation within the webview
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String _getInjectionScript(String provider, String fromCity, String todayStr) {
    if (provider == 'Shohoz' || provider == 'bdtickets' || provider == 'Shyamoli') {
      return """
        setTimeout(function() {
          try {
            var fromInput = document.getElementById('dest_from') || document.querySelector('input[name="dest_from"]') || document.querySelector('input[placeholder*="From" i]') || document.querySelector('input[name*="from" i]');
            var toInput = document.getElementById('dest_to') || document.querySelector('input[name="dest_to"]') || document.querySelector('input[placeholder*="To" i]') || document.querySelector('input[name*="to" i]');
            var dateInput = document.getElementById('doj') || document.querySelector('input[name="doj"]') || document.querySelector('input[placeholder*="date" i]') || document.querySelector('input[name*="date" i]');
            
            if (fromInput) {
              fromInput.value = '$fromCity';
              fromInput.dispatchEvent(new Event('input', { bubbles: true }));
              fromInput.dispatchEvent(new Event('change', { bubbles: true }));
            }
            
            if (toInput) {
              toInput.value = 'Barisal';
              toInput.dispatchEvent(new Event('input', { bubbles: true }));
              toInput.dispatchEvent(new Event('change', { bubbles: true }));
            }

            if (dateInput) {
              dateInput.removeAttribute('readonly');
              // Both formats just in case
              if ('$provider' === 'Shyamoli') {
                 dateInput.value = '${DateFormat('dd-MM-yyyy').format(DateTime.now())}';
              } else {
                 dateInput.value = '$todayStr';
              }
              dateInput.dispatchEvent(new Event('input', { bubbles: true }));
              dateInput.dispatchEvent(new Event('change', { bubbles: true }));
              dateInput.dispatchEvent(new Event('blur', { bubbles: true }));
            }
            
            setTimeout(function() {
              var btns = document.querySelectorAll('button');
              for (var i=0; i<btns.length; i++) {
                if (btns[i].innerText.toLowerCase().includes('search')) {
                  btns[i].click();
                  break;
                }
              }
            }, 500);
          } catch(e) {}
        }, 1000);
      """;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: AutoTranslatedText(widget.providerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
