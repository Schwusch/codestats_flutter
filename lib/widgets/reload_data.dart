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
  StreamSubscription errorSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var bloc = BlocProvider.of<UserBloc>(context);
    errorSubscription?.cancel();
    errorSubscription = bloc.errors.listen(
      (error) => Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
            ),
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    errorSubscription.cancel();
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
