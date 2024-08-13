import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:self_learning_app/features/category/bloc/category_bloc.dart';
import 'package:self_learning_app/features/category/bloc/category_state.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../features/add_category/bloc/add_category_bloc.dart';

class CustomColorPicker with ChangeNotifier{

  Color? pickedColor;

  static pickColor({required BuildContext context}){
    context.showNewDialog(
      AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
       portraitOnly: true,
          pickerColor: Colors.green,
          onColorChanged: (value) {

           // context.read<AddCategoryBloc>().add(CategoryColorChangedEvent(categoryColor: value));
          },
        ),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: pickerColor,
        //   onColorChanged: changeColor,
        //   showLabel: true, // only on portrait mode
        // ),
        //
        // Use Block color picker:
        //
        // child: BlockPicker(
        //   pickerColor: currentColor,
        //   onColorChanged: changeColor,
        // ),
        //
        // child: MultipleChoiceBlockPicker(
        //   pickerColors: currentColors,
        //   onColorsChanged: changeColors,
        // ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Got it'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),);
  }

}