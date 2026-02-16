import 'package:event_maker/data/models/service_model.dart';
import 'package:flutter/material.dart';

class AddServiceView extends StatelessWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddServiceView({
    super.key,
    this.service,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Service' : 'Add Service'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          isEdit
              ? 'Editing ${service?.title ?? 'Service'}'
              : 'Create a new service profile',
        ),
      ),
    );
  }
}
