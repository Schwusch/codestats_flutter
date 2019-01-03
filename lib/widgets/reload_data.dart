import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/random_loading_animation.dart';
import 'package:flutter/material.dart';

class ReloadData extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);

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
            padding: const EdgeInsets.only(right: 16),
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
