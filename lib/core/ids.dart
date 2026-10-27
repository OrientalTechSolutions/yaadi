import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Makes a new id for an item or a completion.
typedef IdGenerator = String Function();

/// UUIDv7: made offline and sorted by creation time (ARCHITECTURE.md section
/// 4). Tests replace it with a counter.
final idGeneratorProvider = Provider<IdGenerator>((ref) => const Uuid().v7);
