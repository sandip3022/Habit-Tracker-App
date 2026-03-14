import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('coming_soon').tr(),
      ),
      body:  Center(
        child: Text(
          'this_feature_is_coming_soon'.tr(),
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}