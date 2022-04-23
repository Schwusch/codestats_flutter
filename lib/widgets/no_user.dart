import 'package:codestats_flutter/widgets/breathing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

ChromeSafariBrowser browser = ChromeSafariBrowser();

class NoUser extends StatelessWidget {
  const NoUser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text("No user chosen"),
          ),
          BreathingWidget(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).pushNamed("addUser");
                },
                icon: const Icon(Icons.add),
                label: const Text("Add user"),
              ),
            ),
          ),
          FloatingActionButton.extended(
            heroTag: null,
            icon: const Icon(Icons.web),
            label: const Text("Create profile"),
            onPressed: () async {
              browser.open(
                url: Uri.parse('https://codestats.net/signup'),
                options: ChromeSafariBrowserClassOptions(
                  android: AndroidChromeCustomTabsOptions(
                    addDefaultShareMenuItem: true,
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
