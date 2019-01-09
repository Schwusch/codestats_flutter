import 'package:codestats_flutter/widgets/expandable_user.dart';
import 'package:flutter/material.dart';

class ExpandableUserList extends StatefulWidget {
  final List<String> users;

  const ExpandableUserList({Key key, this.users}) : super(key: key);

  @override
  _ExpandableUserListState createState() => _ExpandableUserListState();
}

class _ExpandableUserListState extends State<ExpandableUserList> {
  List<ExpandableUser> expandableUsers;

  @override
  void initState() {
    super.initState();
    expandableUsers = widget.users
        .map((user) => ExpandableUser(
              user: user,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.blueGrey[500],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: ExpansionPanelList(
          children: expandableUsers
              .map(
                (expUser) => ExpansionPanel(
                      isExpanded: expUser.isExpanded,
                      headerBuilder: expUser.headerBuilder,
                      body: expUser.build(context),
                    ),
              )
              .toList(),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              expandableUsers[index].isExpanded = !isExpanded;
            });
          },
        ),
      ),
    );
  }
}
