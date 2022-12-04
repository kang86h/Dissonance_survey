import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../getx/extension.dart';
import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import 'admin_page_model.dart';

class AdminPageController extends GetController<AdminPageModel> {
  AdminPageController({
    required AdminPageModel model,
  }) : super(model);
}