import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_test/src/feature/home/presentation/cubit/popular_cubit.dart';
import 'package:news_app_test/src/feature/home/presentation/cubit/popular_state.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/news_article_tile.dart';

class NewsArticleList extends StatelessWidget {
  final PopularNewsState state;
  const NewsArticleList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final PopularNewsCubit popularNewsCubit = context.read<PopularNewsCubit>();
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.articleList!.length,
      itemBuilder:
          (context, index) =>
              popularNewsCubit.isPaginationNotOne
                  ? NewsArticleTile(result: state.articleList![index])
                  : NewsArticleTile(
                    result: state.articleList![index],
                  ).animate().slideX(
                    begin: -10,
                    end: 0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    delay: Duration(milliseconds: 100 * index),
                  ),
    );
  }
}
