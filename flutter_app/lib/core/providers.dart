import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_repository.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  throw UnimplementedError('AppRepository must be overridden at startup.');
});
