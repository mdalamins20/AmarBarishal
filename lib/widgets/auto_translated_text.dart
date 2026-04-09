import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AutoTranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AutoTranslatedText> createState() => _AutoTranslatedTextState();
}

class _AutoTranslatedTextState extends State<AutoTranslatedText> {
  String? _translatedText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translate();
  }

  @override
  void didUpdateWidget(covariant AutoTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translatedText = null;
      _translate();
    }
  }

  void _translate() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    
    // If not English, reset to default text 
    if (!lang.isEnglish) {
      if (_translatedText != null && mounted) {
        setState(() => _translatedText = null);
      }
      return;
    }
    
    // Attempt async translation using the central LanguageProvider
    lang.translateDynamic(widget.text).then((translated) {
      if (mounted && translated != _translatedText) {
        setState(() => _translatedText = translated);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEng = Provider.of<LanguageProvider>(context).isEnglish;
    
    // Display the translated text if it's English and translation is ready, otherwise show original
    String displayText = widget.text;
    if (isEng && _translatedText != null) {
      displayText = _translatedText!;
    }
    
    return Text(
      displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
