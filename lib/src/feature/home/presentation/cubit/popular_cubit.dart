import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:news_app_test/src/core/errors/failures.dart';
import 'package:news_app_test/src/core/loggers/logger.dart';
import 'package:news_app_test/src/core/network/network_info.dart';
import 'package:news_app_test/src/feature/home/data/model/popular_model/popular_model.dart';
import 'package:news_app_test/src/feature/home/domain/usecase/get_popular_news/get_popular_news.dart';
import 'package:news_app_test/src/utils/constants.dart';

import 'popular_state.dart';

class PopularNewsCubit extends Cubit<PopularNewsState> {
  final GetPopularNews _getPopularNews;
  final NetworkInfo _networkInfo;

  PopularNewsCubit({
    required GetPopularNews getPopularNews,
    required NetworkInfo networkInfo,
  }) : _getPopularNews = getPopularNews,
       _networkInfo = networkInfo,
       super(InitialPopularNewsState());
  final List<PopularNewsResult> _articleList = [];
  InternetStatus? _prevStatus;
  PaginationType? _pagination;
  bool get isPaginationNotOne =>
      _pagination != null &&
      (_pagination == PaginationType.thirty ||
          _pagination == PaginationType.end);
  bool get isPaginationLoading => state is LoadingPaginatedPopularNewsState;
  void loadPopularNewsData({bool? paginate}) async {
    if (paginate == null || paginate == false) {
      _pagination = null;
      _articleList.clear();
    }
    if (paginate == true && _pagination == PaginationType.end) {
      return;
    }
    await _mapLoadPopularNewsEventToState();
    if (await _networkInfo.isConnected) {
      _prevStatus = null;
    } else {
      if (_articleList.isNotEmpty) {
        emit(OfflineStatus(articleList: _articleList));
      }
    }
    _listenToNetworkConnection();
  }

  void _listenToNetworkConnection() {
    _networkInfo.isStreamConnected.listen((InternetStatus status) {
      if (status == InternetStatus.connected && _prevStatus != null) {
        if (_articleList.isNotEmpty) {
          emit(OnlineStatus(articleList: _articleList));
        }
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          showToast("Back Online", color: Colors.green);
        }
      }

      if (status == InternetStatus.disconnected) {
        if (_articleList.isNotEmpty) {
          emit(OfflineStatus(articleList: _articleList));
        }
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          showToast("You're Offline", color: Colors.red);
        }
      }
      _prevStatus = status;
    });
  }

  void _updatePagination() {
    switch (_pagination) {
      case null || PaginationType.one:
        _pagination = PaginationType.seven;
        break;
      case PaginationType.seven:
        _pagination = PaginationType.thirty;
        break;
      case PaginationType.thirty:
        _pagination = PaginationType.end;

        break;
      case PaginationType.end:
        {}
        break;
    }
  }

  void _updateListLogic(List<PopularNewsResult>? results) {
    if (_pagination == PaginationType.one) {
      _articleList.addAll(results ?? []);
    } else {
      for (var i in _articleList) {
        results?.removeWhere((e) => e.articleID == i.articleID);
      }
      _articleList.addAll(results ?? []);
    }
  }

  Future<void> _mapLoadPopularNewsEventToState() async {
    if (_pagination != null) {
      emit(LoadingPaginatedPopularNewsState(articleList: _articleList));
    } else {
      emit(LoadingPopularNewsState(articleList: _articleList));
    }
    Logger.logNormal("Before");
    Either<Failure, PopularNewsModel> response = await _getPopularNews(
      _pagination ?? PaginationType.one,
    );
    Logger.logNormal("After");
    emit(
      response.fold(
        (failure) {
          if (failure is ServerFailure) {
            return FailurePopularNewsState(errorMessage: failure.message);
          } else if (failure is OfflineFailure) {
            return FailurePopularNewsState(errorMessage: failure.message);
          }
          return FailurePopularNewsState(errorMessage: failure.toString());
        },
        (data) {
          _updateListLogic(data.results);
          _updatePagination();
          return LoadedPopularNewsState(articleList: _articleList);
        },
      ),
    );
  }
}
