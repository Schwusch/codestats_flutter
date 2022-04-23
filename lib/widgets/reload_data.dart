import 'dart:async';

import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReloadData extends StatefulWidget {
  const ReloadData({Key? key}) : super(key: key);

  @override
  ReloadDataState createState() => ReloadDataState();
}

class ReloadDataState extends State<ReloadData> {
  StreamSubscription<String>? errorSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<UserBloc>();
    errorSubscription?.cancel();
    errorSubscription = bloc.errors.listen(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    errorSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();

    return StreamBuilder(
      stream: bloc.dataFetching,
      initialData: DataFetching.Done,
      builder: (context, snapshot) {
        if (snapshot.data == DataFetching.Loading) {
          return const Padding(
            padding: EdgeInsets.only(right: 16),
            child: RandomLoadingAnimation(
              color: Colors.white,
              size: 16,
            ),
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bloc.fetchAllUsers(),
          );
        }
      },
    );
  }
}
