import 'package:flutter/material.dart';

class DropdownSelectorScreen extends StatefulWidget {
  final List<String> options;
  final Function(String) onSelected;

  const DropdownSelectorScreen({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<DropdownSelectorScreen> createState() => _DropdownSelectorScreenState();
}

class _DropdownSelectorScreenState extends State<DropdownSelectorScreen> {
  late List<String> _validOptions = widget.options;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _validOptions = widget.options
            .where(
              (option) => option.toLowerCase().contains(
                _textEditingController.text.toLowerCase(),
              ),
            )
            .toList();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Search or type new option',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        
                        // GestureDetector(
                        //   onTap: () {
                        //     widget.onSelected(_textEditingController.text);
                        //     Navigator.of(context).pop();
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //     decoration: BoxDecoration(
                        //       color: Theme.of(context).primaryColor,
                        //       borderRadius: BorderRadius.circular(6),
                        //     ),
                        //     child: const Text(
                        //       'Add +',
                        //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: _validOptions.map((option) {
                        return GestureDetector(
                          onTap: () {
                            widget.onSelected(option);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            child: Text(option),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
