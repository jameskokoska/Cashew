import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/services/auto_tagging_service.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/tagIcon.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class TagSelectionModal extends StatefulWidget {
  final String transactionPk;

  const TagSelectionModal({Key? key, required this.transactionPk}) : super(key: key);

  @override
  _TagSelectionModalState createState() => _TagSelectionModalState();
}

class _TagSelectionModalState extends State<TagSelectionModal> {
  List<Tag> allTags = [];
  List<String> selectedTagPks = [];
  final AutoTaggingService _autoTaggingService = AutoTaggingService();
  String? transactionName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tags = await database.getAllTags();
    final transactionTags = await database.getTransactionTags(widget.transactionPk).first;
    final transaction = await database.getTransactionFromPk(widget.transactionPk);
    
    if (mounted) {
      setState(() {
        allTags = tags;
        selectedTagPks = transactionTags.map((e) => e.tag.tagPk).toList();
        transactionName = transaction.name;
      });
    }
  }

  Future<void> _toggleTag(Tag tag) async {
    if (selectedTagPks.contains(tag.tagPk)) {
      final transactionTags = await database.getTransactionTags(widget.transactionPk).first;
      final toDelete = transactionTags.firstWhere((element) => element.tag.tagPk == tag.tagPk);
      await database.deleteTransactionTag(toDelete.transactionTag.transactionTagPk);
      
      setState(() {
        selectedTagPks.remove(tag.tagPk);
      });
    } else {
      await database.createOrUpdateTransactionTag(
        TransactionTag(
          transactionTagPk: uuid.v4(),
          transactionFk: widget.transactionPk,
          tagFk: tag.tagPk,
          dateCreated: DateTime.now(),
        )
      );
      setState(() {
        selectedTagPks.add(tag.tagPk);
      });
    }
  }

  void _showAutoTagDialog() {
    TextEditingController _controller = TextEditingController(text: transactionName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextFont(text: "Auto-tag Rules"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFont(text: "Automatically assign selected tags when description contains:", maxLines: 3),
              SizedBox(height: 10),
              TextInput(
                labelText: "Keyword",
                controller: _controller,
              ),
              SizedBox(height: 20),
              TextFont(text: "Tags to assign:"),
              Wrap(
                spacing: 5,
                children: allTags.where((t) => selectedTagPks.contains(t.tagPk)).map((t) {
                  return Chip(
                    label: TextFont(text: t.name, fontSize: 12),
                    backgroundColor: HexColor(t.color).withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            Button(
              label: "Cancel",
              onTap: () => Navigator.pop(context),
            ),
            Button(
              label: "Save Rule",
              onTap: () async {
                if (_controller.text.isNotEmpty && selectedTagPks.isNotEmpty) {
                  for (String tagPk in selectedTagPks) {
                    await _autoTaggingService.addRule(_controller.text, tagPk);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rule saved!")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFont(
                text: "Select Tags",
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                icon: Icon(Icons.auto_fix_high, color: Theme.of(context).colorScheme.primary),
                onPressed: _showAutoTagDialog,
                tooltip: "Create Auto-tag Rule",
              ),
            ],
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: allTags.map((tag) {
              final isSelected = selectedTagPks.contains(tag.tagPk);
              return GestureDetector(
                onTap: () => _toggleTag(tag),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TagIcon(tag: tag, size: 18),
                      SizedBox(width: 8),
                      TextFont(text: tag.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
