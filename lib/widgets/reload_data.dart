import 'dart:async';

import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';

class ReloadData extends StatefulWidget {
  @override
  ReloadDataState createState() => ReloadDataState();
}

class ReloadDataState extends State<ReloadData> {
  StreamSubscription subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription?.cancel();
    subscription = BlocProvider.of<UserBloc>(context).dataFetching.listen(
      (DataFetching data) {
        if (data == DataFetching.Error) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong when fetching data :('),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.dataFetching,
      initialData: DataFetching.Done,
      builder: (context, snapshot) {
        if (snapshot.data == DataFetching.Loading) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RandomLoadingAnimation(
              color: Colors.white,
              size: 16,
            ),
          );
        } else {
          return IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => bloc.fetchAllUsers(),
          );
        }
      },
    );
  }
}
