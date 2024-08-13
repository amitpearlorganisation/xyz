import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/schedule/scheduleFlowsbook/scheduleFlowsBook.dart';

import '../features/create_flow/data/model/flow_model.dart';
import '../widgets/dateTimePicker.dart';
import '../widgets/scheduleflowScreenwidget.dart';
import 'cubit/scheduleflow_cubit.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  DateTime? currentDate;
  TimeOfDay? currentTime;
  List<FlowModel> filteredList = [];
  TextEditingController _searchFlowController = TextEditingController();

// Inside your State class

  @override
  void initState() {
    super.initState();

    currentDate = DateTime.now();
    currentTime = TimeOfDay.now();
    context.read<ScheduleflowCubit>().getFlow();
  }


  Widget build(BuildContext context) {
    return 
      Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300,width: 1.5),
                  borderRadius: BorderRadius.circular(10)
              ),
              child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _searchFlowController,
                    onChanged: (value) {
                      print("Text changed: $value");
                      context.read<ScheduleflowCubit>().getFlow(queary: value);

                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search flow...',
                    ),
                  )
              ),
            ),
            Expanded(child: ScheduleflowScreenWidget())

          ],
        )
      );
  }

}
