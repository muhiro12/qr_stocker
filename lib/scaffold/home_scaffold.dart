import 'package:coduck/entity/code.dart';
import 'package:coduck/model/database.dart';
import 'package:coduck/model/scanner.dart';
import 'package:coduck/scaffold/detail_scaffold.dart';
import 'package:coduck/scaffold/settings_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeScaffold extends StatelessWidget {
  HomeScaffold(this._title);

  final String _title;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Database.listenable(),
      builder: (context, Box<Code> box, __) {
        final List<Code> codes = box.values.toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _title,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => _presentSettings(context),
              )
            ],
          ),
          body: SafeArea(
            child: ListView(
              children: codes
                  .map(
                    (code) => Card(
                      child: ListTile(
                        title: Text(
                          code.title,
                        ),
                        trailing: Card(
                          color: Colors.white,
                          child: QrImage(
                            data: code.data,
                          ),
                        ),
                        onTap: () => pushDetail(
                          context,
                          codes.indexOf(code),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _scan(context),
            tooltip: 'Scan',
            child: Icon(Icons.camera),
          ),
        );
      },
    );
  }

  void _scan(BuildContext context) async {
    final result = await Scanner.scan();

    if (result == null) {
      return;
    }

    Database.save(result).then(
      (success) {
        if (success) {
          return;
        }
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Sorry, the limit is 5 cards.'),
          ),
        );
      },
    );
  }

  void pushDetail(
    BuildContext context,
    int index,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScaffold(index),
      ),
    );
  }

  void _presentSettings(BuildContext context) {
    SettingsScaffold.present(context);
  }
}
