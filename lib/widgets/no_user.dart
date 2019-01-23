import 'package:codestats_flutter/widgets/breathing_widget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NoUser extends StatelessWidget {
  const NoUser({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text("No user chosen"),
          ),
          BreathingWidget(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).pushNamed("/addUser");
                },
                icon: Icon(Icons.add),
                label: Text("Add user"),
              ),
            ),
          ),
          FloatingActionButton.extended(
            heroTag: null,
            icon: Icon(Icons.web),
            label: Text("Create profile"),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: Text('New profile'),
                        ),
                        body: WebView(
                          initialUrl: 'https://codestats.net/signup',
                          javascriptMode: JavascriptMode.unrestricted,
                        ),
                      ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}