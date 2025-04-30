import 'package:fpdart/fpdart.dart';
import 'package:news_app_test/src/utils/constants.dart';
import 'package:news_app_test/src/core/errors/failures.dart';
import 'package:news_app_test/src/feature/home/data/model/popular_model/popular_model.dart';
import 'package:news_app_test/src/feature/home/domain/repository/news/news_repository.dart';

class GetPopularNews {
  final NewsRepository newsRepository;

  const GetPopularNews({required this.newsRepository});

  Future<Either<Failure, PopularNewsModel>> call(PaginationType pagination) async =>
      await newsRepository.getPopularNews(pagination);
}
