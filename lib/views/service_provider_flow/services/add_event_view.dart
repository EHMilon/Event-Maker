import 'package:event_maker/data/models/service_model.dart';
import 'package:flutter/material.dart';

class AddEventView extends StatelessWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddEventView({
    super.key,
    this.service,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Event' : 'Add Event'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          isEdit
              ? 'Editing ${service?.title ?? 'Event'}'
              : 'Create a new event',
        ),
      ),
    );
  }
}
