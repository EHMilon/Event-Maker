import 'package:event_maker/data/models/service_model.dart';
import 'package:flutter/material.dart';

class AddTrainingView extends StatelessWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddTrainingView({
    super.key,
    this.service,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Training' : 'Add Training'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          isEdit
              ? 'Editing ${service?.title ?? 'Training'}'
              : 'Create a new training course',
        ),
      ),
    );
  }
}
