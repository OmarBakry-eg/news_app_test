import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:news_app_test/src/core/loggers/logger.dart';
import 'package:news_app_test/src/feature/home/presentation/cubit/popular_cubit.dart';
import 'package:news_app_test/src/feature/home/presentation/cubit/popular_state.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/failure_widget.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/gradient_container.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/network_icon_widget.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/news_article_list.dart';
import 'package:news_app_test/src/feature/home/presentation/widgets/pull_to_ref_widget.dart';
import 'package:news_app_test/src/feature/setting/presentation/screen/setting_page.dart';
import 'package:news_app_test/src/utils/my_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late final PopularNewsCubit _popularNewsCubit;

  @override
  void initState() {
    _popularNewsCubit = context.read<PopularNewsCubit>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _popularNewsCubit.loadPopularNewsData();
    _setupScrollController();
    super.didChangeDependencies();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_popularNewsCubit.isPaginationLoading) {
          _popularNewsCubit.loadPopularNewsData(paginate: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PopularNewsCubit, PopularNewsState>(
          listener: (ctx, state) => Logger.logInfo("current state is $state"),
          builder: (context, state) {
            if (state is LoadingPopularNewsState) {
              return Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: MyTheme.gradientColors[1],
                  size: 100,
                ),
              );
            } else if (state is FailurePopularNewsState) {
              return FailureWidget(errorMessage: state.errorMessage);
            } else if (state is LoadedPopularNewsState ||
                (state is OnlineStatus &&
                    state.articleList != null &&
                    state.articleList!.isNotEmpty) ||
                (state is OfflineStatus &&
                    state.articleList != null &&
                    state.articleList!.isNotEmpty) ||
                state is LoadingPaginatedPopularNewsState) {
              return Padding(
                padding: const EdgeInsets.all(22),
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    _popularNewsCubit.loadPopularNewsData();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        state is OnlineStatus
                            ? const PullToRefreshWidget()
                            : const SizedBox.shrink(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Discover",
                                      style: MyTheme.displayLarge,
                                    ),
                                    const SizedBox(width: 15),
                                    const NetworkIconWidget(),
                                  ],
                                ),
                                const Text(
                                  "Read your favourite news in one click",
                                  style: MyTheme.displaySmall,
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsPage(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.settings, size: 25),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const GradientContainer(),
                            const SizedBox(height: 25),
                            const Text(
                              "Popular News",
                              style: MyTheme.labelMedium,
                            ),
                            NewsArticleList(state: state),
                            if (_popularNewsCubit.isPaginationLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: LoadingAnimationWidget.inkDrop(
                                    color: MyTheme.gradientColors[1],
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale();
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
