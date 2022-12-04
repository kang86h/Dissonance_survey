import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../getx/get_rx_impl.dart';

import 'admin_page_controller.dart';

class AdminPage extends GetView<AdminPageController> {
  const AdminPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Colors.cyan,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Text('Save Json')]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
