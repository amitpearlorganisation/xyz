import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/add_category/data/model/add_cate_model.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cat_bloc.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_event.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_state.dart';
import 'package:self_learning_app/features/search_category/data/search_cate_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../utilities/colors.dart';
import '../subcategory/sub_cate_screen.dart';

class CustomSearchDelegate extends SearchDelegate
{

  @override
  List<Widget> buildActions(BuildContext context) {

    return[
      IconButton(
          onPressed: (){
            print(query);
            query = '';
      }, icon: const Icon(Icons.clear))
    ];


  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(onPressed: () {
      close(context, SearchCategoryModel());
    }, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query.isNotEmpty) {
      context.read<SearchCategoryBloc>().add(SearcCategoryLoadEvent(query: query));
    }
    return BlocBuilder<SearchCategoryBloc, SearchCategoryState>(
      builder: (context, state) {
        if (state is SearchCategoryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchCategoryLoaded) {
          if (state.cateList.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        // padding: EdgeInsets.all(15),
                        itemCount: state.cateList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: context.screenHeight * 0.15,
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              width: context.screenWidth / 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,

                                border: Border.all(color: Colors.blueAccent,width: 3),),
                              child: Center(
                                child: Text(state.cateList[index].name.toString(),style: const TextStyle(
                                    color: primaryColor
                                )),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return SubCategoryScreen(
                                    tags: state.cateList[index].keywords,
                                    color: Color(
                                      int.parse(
                                          state.cateList[index].styles![1].value!),
                                    ),
                                    rootId: state.cateList[index].sId,
                                    categoryName: state.cateList[index].name,
                                  );
                                },
                              ));
                              print(state.cateList[index].userId);
                            },
                          );
                        },
                      ))
                ],
              ),
            );
          } else {
            return const Text('No Category Found');
          }
        } else {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isNotEmpty){
      context.read<SearchCategoryBloc>().add(SearcCategoryLoadEvent(query: query));
    }
    return BlocBuilder<SearchCategoryBloc, SearchCategoryState>(
      builder: (context, state) {
        if(state is SearchCategoryInitial){
          return Align(
            alignment: Alignment.center,
            child: Text('Search Category here......',style: TextStyle(
              fontWeight: FontWeight.bold
            )),
          );
        }
        else if (state is SearchCategoryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchCategoryLoaded) {
          if (state.cateList.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        // padding: EdgeInsets.all(15),
                        itemCount: state.cateList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: context.screenHeight * 0.15,
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              width: context.screenWidth / 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,

                                border: Border.all(
                                    color: Colors.blueAccent, width: 3),),
                              child: Center(
                                child: Text(
                                    state.cateList[index].name.toString(),
                                    style: TextStyle(
                                        color: primaryColor
                                    )),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return  SubCategoryScreen(
                                    tags: state.cateList[index].keywords,
                                    color: Color(
                                      int.parse(
                                          state.cateList[index].styles![1].value!),
                                    ),
                                    rootId: state.cateList[index].sId,
                                    categoryName: state.cateList[index].name,
                                  );
                                },
                              ));
                              print(state.cateList[index].userId);
                            },
                          );
                        },
                      ))
                ],
              ),
            );
          } else {
            return Align(
              child:  Text('No Categories Found.',style: TextStyle(
                  fontWeight: FontWeight.bold
              ),),
            );
          }
        } else {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
      },
    );
  }
  }