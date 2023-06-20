import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haruhabit_app/src/blocs/health_bloc.dart';
import 'package:haruhabit_app/src/blocs/health_event.dart';
import 'package:haruhabit_app/src/blocs/health_state.dart';
import 'package:haruhabit_app/src/utils/add_health.dart';
import 'package:haruhabit_app/src/utils/card_dialog.dart';
import 'package:haruhabit_app/src/utils/gridcard_util.dart';
import 'package:intl/date_time_patterns.dart';

class Health extends StatelessWidget {
  const Health({super.key});

  @override
  Widget build(BuildContext context) {
    // healthBloc.on((event, emit) => )
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health"),
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
                return Container(
                    child: Column(
                  children: [
                    GridcardUtil(
                      content: Container(
                        height: MediaQuery.of(context).size.height / 8,
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Text(state.model.steps.toString()),
                      ),
                    ),
                  ],
                ));
              case HealthStatus.initial:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //-
          Navigator.of(context).push(CardDialog(builder: (context) {
            return AddHealth();
          }));
          // print(DateTime.now().subtract(Duration(minutes: 20)));
        },
      ),
    );
  }

  // Widget
}
