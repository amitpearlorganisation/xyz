import 'package:flutter/material.dart';



@immutable
abstract class SearchCategoryEvent {}



class SearcCategoryLoadEvent extends SearchCategoryEvent{
  final String? query;
  SearcCategoryLoadEvent({this.query});
}




