import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haruhabit_app/src/blocs/health_bloc.dart';
import 'package:haruhabit_app/src/blocs/health_event.dart';
import 'package:haruhabit_app/src/blocs/health_state.dart';

class Health extends StatelessWidget {
  const Health({super.key});

  @override
  Widget build(BuildContext context) {
    // healthBloc.on((event, emit) => )
    return Scaffold(
      appBar: AppBar(
        title: const Text("steps"),
      ),
      body: BlocProvider(
        create: (_) => HealthBloc()..add(HealthFetched()),
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            switch (state.status) {
              case HealthStatus.failure:
                return const Center(
                  child: Text(
                    'failed to fetch posts',
                  ),
                );
              case HealthStatus.success:
                if (state.props.isEmpty) {
                  return const Center(
                    child: Text(
                      'no data',
                    ),
                  );
                }
                // return ListView.builder(
                //   itemBuilder: (BuildContext context, int index) {
                //     return index >= state.posts.length
                //         ? const BottomLoader()
                //         : PostListItem(post: state.posts[index]);
                //   },
                //   itemCount: state.hasReachedMax
                //       ? state.posts.length
                //       : state.posts.length + 1,
                //   controller: _scrollController,
                // );
                return Text(state.model.steps.toString());
              case HealthStatus.initial:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}