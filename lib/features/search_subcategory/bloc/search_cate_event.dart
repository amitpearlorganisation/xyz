import 'package:flutter/material.dart';



@immutable
abstract class SearchSubCategoryEvent {}



class SearchSubCategoryLoadEvent extends SearchSubCategoryEvent{
  final String? query;
  final String? rootId;
  SearchSubCategoryLoadEvent({this.query, required this.rootId});
}




