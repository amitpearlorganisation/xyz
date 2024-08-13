import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/promt/data/model/promt_model.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../flow_screen/start_flow_screen.dart';
import 'bloc/promt_bloc.dart';
import 'data/model/flow_model.dart';

enum Prompt { fromResource, fromCategory, fromFlow }

class PromtsScreen extends StatefulWidget {
  final String? mediaType;
  final String promtId;
  final String? content;
  final Prompt fromType;
  String? ResTitle;

   PromtsScreen({
    Key? key,
    required this.promtId,
    this.mediaType,
    this.content,
    required this.fromType,
    required this.ResTitle
  }) : super(key: key);

  @override
  State<PromtsScreen> createState() => _PromtsScreenState();
}

class _PromtsScreenState extends State<PromtsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _promtModelLength = 0;
  ChewieController? _chewieController;

  late final ColorScheme colorScheme;
  FlickManager? flickManager;

  void _disposeFlickManager() {
    flickManager?.flickVideoManager?.videoPlayerController?.dispose();
    flickManager?.dispose();
    flickManager = null;
  }

  @override
  void initState() {
    BlocProvider.of<PromtBloc>(context).add(
      LoadPromtEvent(promtId: widget.promtId, fromType: widget.fromType),
    );
    super.initState();
  }

  final List<int> _items = List<int>.generate(50, (int index) => index);

  @override
  void dispose() {
    _pageController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Widget buildSliderIndicator(int index) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPage ? Colors.blue : Colors.grey,
      ),
    );
  }

  bool isLastPage() {
    return _currentPage == _promtModelLength - 1;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return Scaffold(
      floatingActionButton: SizedBox(
        height: context.screenHeight * 0.1,
        child: FittedBox(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return StartFlowScreen(
                      Restitle: widget.ResTitle,
                      content: widget.content,
                      mediaType: widget.mediaType,
                      promtId: widget.promtId,
                    );
                  },
                ),
              ).then((value) {
                setState(() {
                  _disposeFlickManager();
                  BlocProvider.of<PromtBloc>(context).add(
                    LoadPromtEvent(
                      promtId: widget.promtId,
                      fromType: widget.fromType,
                    ),
                  );
                });
              });
            },
            child: const Row(
              children: [
                Text(
                  'Start Flow',
                  style: TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Prompts'),
      ),
      body: BlocConsumer<PromtBloc, PromtState>(
        listener: (context, state) {
          if (state is PromtLoaded) {
            if (state.apiState == ApiState.Success) {
              Navigator.pop(context);
              context.showSnackBar(
                const SnackBar(content: Text('Flow added')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is PromtLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PromtError) {
            return Center(
              child: Text(state.error ?? 'An error occurred'),
            );
          } else if (state is PromtLoaded) {
            final flow = state.addFlowModel?.flow;
            if (flow == null || flow.isEmpty) {
              return const Center(
                child: Text('No prompts found'),
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ReorderableListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      children: [
                        for (int index = 0; index < flow.length; index++)
                          ListTile(
                            leading: CircleAvatar(
                              maxRadius: 17,
                              backgroundColor: generateRandomColor(),
                              foregroundColor: Colors.white,
                              child: Text(
                                extractFirstLetter(flow[index].name ?? ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            trailing: const Icon(Icons.menu),
                            key: Key('$index'),
                            tileColor: index.isOdd
                                ? oddItemColor
                                : evenItemColor,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(flow[index].name ?? ''),
                              ],
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = flow.removeAt(oldIndex);
                          flow.insert(newIndex, item);

                          final model = state.promtModel?.removeAt(oldIndex);
                          if (model != null) {
                            state.promtModel?.insert(newIndex, model);
                          }
                        });
                      },
                    ),
                  ),
                ],
              );
            }
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color generateRandomColor() {
    final Random random = Random();
    Color color;

    do {
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    } while (_isBright(color) || color == Colors.white);

    return color;
  }

  bool _isBright(Color color) {
    double luminance = 0.299 * color.red +
        0.587 * color.green +
        0.114 * color.blue;
    return luminance > 180;
  }

  String extractFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.substring(0, 1).toUpperCase();
  }
}
