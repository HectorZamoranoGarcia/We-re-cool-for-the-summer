import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/product_entity.dart';
import 'dto/product_dto.dart';
import 'remote_product_data_source.dart';

class OpenFoodFactsDataSource implements RemoteProductDataSource {
  final Dio _dio;

  const OpenFoodFactsDataSource(this._dio);

  @override
  Future<ProductEntity?> fetchProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        'api/v2/product/$barcode.json',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['status'] == 0 || data['status'] == 'product_not_found') {
          return null; // Product not found
        }
        final dto = ProductDto.fromJson(data);
        return dto.toEntity();
      }

      throw const ServerException('Invalid response format');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkTimeoutException();
      }
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException(e.message ?? 'Unknown Dio error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
