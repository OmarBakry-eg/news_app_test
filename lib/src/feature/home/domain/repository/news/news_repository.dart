import 'package:fpdart/fpdart.dart';
import 'package:news_app_test/src/utils/constants.dart';
import 'package:news_app_test/src/core/errors/failures.dart';
import 'package:news_app_test/src/feature/home/data/model/popular_model/popular_model.dart';

abstract class NewsRepository {
  Future<Either<Failure, PopularNewsModel>> getPopularNews(PaginationType pagination);
}
