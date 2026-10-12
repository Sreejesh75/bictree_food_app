import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/core/errors/failures.dart';
import 'package:bictree_food_app/features/home/widgets/offline_banner.dart';
import 'package:bictree_food_app/features/home/widgets/friendly_error_view.dart';
import 'package:bictree_food_app/features/home/widgets/friendly_empty_view.dart';

void main() {
  group('Typed Failure Model Tests', () {
    test('Maps SocketException to NetworkFailure with proper error code', () {
      final rawError = const SocketException('Failed host lookup');
      final failure = mapExceptionToFailure(rawError);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'NETWORK_OFFLINE');
      expect(failure.message, contains('No internet connection'));
    });

    test('Maps ServerFailure with HTTP status code', () {
      const failure = ServerFailure(
        statusCode: 500,
        message: 'Server error 500',
      );

      expect(failure.code, 'SERVER_ERROR');
      expect(failure.statusCode, 500);
      expect(failure.toString(), contains('SERVER_ERROR'));
    });

    test('Maps CacheFailure with code CACHE_ERROR', () {
      const failure = CacheFailure(message: 'Cache read failed');
      expect(failure.code, 'CACHE_ERROR');
    });

    test('Maps FormatException to ServerFailure', () {
      final rawError = const FormatException('Unexpected character');
      final failure = mapExceptionToFailure(rawError);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('Invalid data format'));
    });
  });

  group('OfflineBanner Widget Tests', () {
    testWidgets('Renders offline indicator, item count, and triggers retry', (
      tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineBanner(
              cachedItemsCount: 10,
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.text('CACHED'), findsOneWidget);
      expect(
        find.textContaining('Displaying 10 cached dishes'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });
  });

  group('FriendlyErrorView Widget Tests', () {
    testWidgets('Renders friendly network error screen and handles retry tap', (
      tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendlyErrorView(
              failure: const NetworkFailure(),
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('Renders friendly server error screen for ServerFailure', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendlyErrorView(
              failure: const ServerFailure(statusCode: 503),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kitchen Servers Are Busy'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('FriendlyEmptyView Widget Tests', () {
    testWidgets('Renders friendly search empty state with suggestions', (
      tester,
    ) async {
      String? tappedSuggestion;
      bool clearSearchCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendlyEmptyView(
              searchQuery: 'xyz123',
              onClearSearch: () => clearSearchCalled = true,
              onSuggestionTap: (s) => tappedSuggestion = s,
            ),
          ),
        ),
      );

      expect(find.text('No Dishes Found'), findsOneWidget);
      expect(find.textContaining('xyz123'), findsOneWidget);
      expect(find.text('POPULAR SEARCHES'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);

      await tester.tap(find.text('Pizza'));
      await tester.pump();
      expect(tappedSuggestion, 'Pizza');

      await tester.tap(find.text('Clear Search'));
      await tester.pump();
      expect(clearSearchCalled, isTrue);
    });
  });
}
