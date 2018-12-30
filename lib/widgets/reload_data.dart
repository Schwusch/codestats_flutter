import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';

class ReloadData extends StatelessWidget {
  const ReloadData({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  final UserBloc bloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.dataFetching,
      initialData: DataFetching.Done,
      builder: (context, snapshot) {
        if (snapshot.data == DataFetching.Done ||
            snapshot.data == DataFetching.Error) {
          return IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => bloc.fetchAllUsers(),
          );
        } else if (snapshot.data == DataFetching.Loading) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: RandomLoadingAnimation(
              color: Colors.white,
              size: 16,
            ),
          );
        }
        return Container();
      },
    );
  }
}
