import 'package:budget/colors.dart';
import 'package:flutter/material.dart';

class TableEntry extends StatelessWidget {
  final List<String> headers;
  final List<String> firstEntry;
  final EdgeInsets padding;

  const TableEntry({
    Key? key,
    required this.headers,
    required this.firstEntry,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Table(
          defaultColumnWidth: IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              decoration: BoxDecoration(
                color: dynamicPastel(
                    context, Theme.of(context).colorScheme.primary,
                    amount: 0.3, inverse: false),
              ),
              children: <Widget>[
                for (String header in headers)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 11.0, right: 11, top: 6, bottom: 3),
                    child: Text(
                      header,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: dynamicPastel(
                            context, Theme.of(context).colorScheme.onPrimary,
                            amount: 0.3, inverse: false),
                      ),
                    ),
                  )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              children: <Widget>[
                for (String entry in firstEntry)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 11.0, right: 11, top: 6, bottom: 3),
                    child: Text(
                      entry,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
