import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';
import 'package:rojgar/core/services/sensor/sensor_service.dart';
import 'package:rojgar/feature/splash/presentation/pages/buttom_screens/browse_screen.dart';


class MockApiClient extends Mock implements ApiClient {}

class MockSensorService extends Mock implements SensorService {
  @override
  Function()? onShake;

  @override
  Function()? onGyroUpdate;

  @override
  double get gyroX => 0.0;

  @override
  double get gyroY => 0.0;

  @override
  void start() {}

  @override
  void stop() {}
}

Map<String, dynamic> _mockJob({
  String id = '1',
  String title = 'Flutter Developer',
  String company = 'Test Corp',
  String location = 'Kathmandu, Nepal',
  String jobType = 'Full-Time',
  String experience = 'Junior',
  String category = 'Software Development',
}) {
  return {
    '_id': id,
    'jobTitle': title,
    'companyName': company,
    'location': location,
    'jobType': jobType,
    'experienceLevel': experience,
    'category': category,
    'description': 'Test description',
    'minSalary': 30000,
    'maxSalary': 60000,
    'requirements': ['Dart', 'Flutter'],
    'benefits': ['Health Insurance'],
    'companyLogoUrl': null,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

Response<dynamic> _mockJobsResponse(List<Map<String, dynamic>> jobs) {
  return Response(
    data: {'success': true, 'data': jobs},
    statusCode: 200,
    requestOptions: RequestOptions(path: ApiEndpoints.jobs),
  );
}

Response<dynamic> _mockEmptyResponse() {
  return Response(
    data: {'success': true, 'data': []},
    statusCode: 200,
    requestOptions: RequestOptions(path: ApiEndpoints.jobs),
  );
}

Widget _buildTestWidget(ApiClient mockApiClient) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(mockApiClient),
    ],
    child: const MaterialApp(
      home: BrowseScreen(),
    ),
  );
}

void main() {
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
  });

  group('BrowseScreen', () {
    testWidgets('shows loading indicator while fetching jobs', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockEmptyResponse());

      await tester.pumpWidget(_buildTestWidget(mockApiClient));

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('shows no jobs found when API returns empty list',
        (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockEmptyResponse());

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.text('No jobs found'), findsOneWidget);
    });

    testWidgets('shows job cards when API returns jobs', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(title: 'Flutter Developer'),
            _mockJob(id: '2', title: 'Backend Engineer', company: 'Acme Ltd'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('Backend Engineer'), findsOneWidget);
    });

    testWidgets('shows correct job count text', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(),
            _mockJob(id: '2', title: 'Backend Engineer'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.textContaining('Showing 2 of 2 jobs'), findsOneWidget);
    });

    testWidgets('shows error and retry button when API fails', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.jobs),
          type: DioExceptionType.connectionError,
          message: 'Connection failed',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button refetches jobs after error', (tester) async {
      var callCount = 0;
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.jobs),
            type: DioExceptionType.connectionError,
          );
        }
        return _mockJobsResponse([_mockJob(title: 'Flutter Developer')]);
      });

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Developer'), findsOneWidget);
    });

    testWidgets('search filters jobs by title', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(title: 'Flutter Developer'),
            _mockJob(id: '2', title: 'Backend Engineer'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Flutter');
      await tester.pump();

      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('Backend Engineer'), findsNothing);
      expect(find.textContaining('Showing 1 of 2'), findsOneWidget);
    });

    testWidgets('search filters jobs by company name', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(title: 'Flutter Developer', company: 'Google'),
            _mockJob(id: '2', title: 'Backend Engineer', company: 'Meta'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Google');
      await tester.pump();

      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('Backend Engineer'), findsNothing);
    });

    testWidgets('category filter shows only matching jobs', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(title: 'Flutter Developer', category: 'Software Development'),
            _mockJob(id: '2', title: 'Graphic Designer', category: 'Design & Creative'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Design & Creative').first);
      await tester.pump();

      expect(find.text('Graphic Designer'), findsOneWidget);
      expect(find.text('Flutter Developer'), findsNothing);
    });

    testWidgets('job type filter shows only matching jobs', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(title: 'Full Time Job', jobType: 'Full-Time'),
            _mockJob(id: '2', title: 'Part Time Job', jobType: 'Part-Time'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Part-Time').first);
      await tester.pump();

      expect(find.text('Part Time Job'), findsOneWidget);
      expect(find.text('Full Time Job'), findsNothing);
    });

    testWidgets('shows search bar with correct hint text', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockEmptyResponse());

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(
        find.text('Search by job title, company, or location...'),
        findsOneWidget,
      );
    });

    testWidgets('shows salary range correctly on job card', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([_mockJob()]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.textContaining('NPR 30k - 60k'), findsOneWidget);
    });

    testWidgets('shows Apply button on each job card', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([
            _mockJob(),
            _mockJob(id: '2', title: 'Backend Engineer'),
          ]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.text('Apply'), findsNWidgets(2));
    });

    testWidgets('save toggle works on job card', (tester) async {
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _mockJobsResponse([_mockJob()]));

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('pull to refresh refetches jobs', (tester) async {
      var callCount = 0;
      when(() => mockApiClient.get(
            ApiEndpoints.jobs,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async {
        callCount++;
        return _mockJobsResponse([_mockJob()]);
      });

      await tester.pumpWidget(_buildTestWidget(mockApiClient));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(callCount, greaterThan(1));
    });
  });
}