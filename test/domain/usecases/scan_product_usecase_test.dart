import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Adjust these paths depending on whether your domain logic is in lib/domain or lib/src/domain.
import 'package:app_comidas/domain/repositories/i_product_repository.dart';
import 'package:app_comidas/domain/usecases/scan_product_usecase.dart';
import 'package:app_comidas/domain/entities/product_entity.dart';

// Generates the mock repository file
@GenerateMocks([IProductRepository])
import 'scan_product_usecase_test.mocks.dart';

void main() {
  late MockIProductRepository mockRepository;
  late ScanProductUseCase useCase;

  setUp(() {
    mockRepository = MockIProductRepository();
    // Assuming constructor injection
    useCase = ScanProductUseCase(mockRepository);
  });

  group('ScanProductUseCase Tests', () {
    const testBarcode = '8410000000001';
    final testProduct = ProductEntity(
      barcode: testBarcode,
      name: 'Test Milk',
      brand: 'Dairy Brand',
      imageUrl: 'https://example.com/milk.png',
    );

    test('should confidently call getOrFetchProduct on repository with valid barcode', () async {
      // Arrange
      when(mockRepository.getOrFetchProduct(testBarcode))
          .thenAnswer((_) async => testProduct);

      // Act
      final result = await useCase.call(testBarcode);

      // Assert
      expect(result, equals(testProduct));
      verify(mockRepository.getOrFetchProduct(testBarcode)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
