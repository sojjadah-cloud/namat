import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/store.dart';
import 'duel.dart';

/// The member's own challenges.
///
/// Empty until they start one. There used to be a fixture duel here — خالد on
/// 8,420 steps against أحمد on 7,950 — which meant a brand-new account opened
/// onto a competition against a stranger it had never met. Sample data is
/// harmless on a screen nobody reads and corrosive on the first screen a new
/// member sees, because they cannot tell which parts of the app are real.

/// One challenge the member is in.
class ActiveDuel {
  const ActiveDuel({
    required this.id,
    required this.opponent,
    required this.metric,
    required this.target,
    required this.startedAt,
    required this.days,
    this.myScore = 0,
    this.theirScore = 0,
    this.accepted = false,
  });

  final String id;
  final String opponent;
  final DuelMetric metric;
  final int target;
  final DateTime startedAt;
  final int days;

  /// Both start at zero. A duel that opens with a score is a duel the member
  /// did not take part in.
  final int myScore;
  final int theirScore;

  /// A challenge does not start until the other person agrees. Counting
  /// progress before that would score somebody who has not opted in.
  final bool accepted;

  DateTime get endsAt => startedAt.add(Duration(days: days));

  int get dayOf {
    final elapsed = DateTime.now().difference(startedAt).inDays + 1;
    return elapsed.clamp(1, days);
  }

  bool get isOver => DateTime.now().isAfter(endsAt);

  ActiveDuel copyWith({int? myScore, int? theirScore, bool? accepted}) =>
      ActiveDuel(
        id: id,
        opponent: opponent,
        metric: metric,
        target: target,
        startedAt: startedAt,
        days: days,
        myScore: myScore ?? this.myScore,
        theirScore: theirScore ?? this.theirScore,
        accepted: accepted ?? this.accepted,
      );
}

class DuelsNotifier extends StateNotifier<List<ActiveDuel>>
    with Persisted<List<ActiveDuel>> {
  DuelsNotifier([this.store]) : super(const []) {
    restore();
  }

  @override
  final NamatStore? store;

  @override
  String get storageKey => StorageKey.duels;

  @override
  Object encode(List<ActiveDuel> value) => [
        for (final d in value)
          {
            'id': d.id,
            'opponent': d.opponent,
            'metric': d.metric.name,
            'target': d.target,
            'startedAt': d.startedAt.toIso8601String(),
            'days': d.days,
            'myScore': d.myScore,
            'theirScore': d.theirScore,
            'accepted': d.accepted,
          },
      ];

  @override
  List<ActiveDuel> decode(Object raw) => [
        for (final d in raw as List)
          ActiveDuel(
            id: (d as Map)['id'] as String,
            opponent: d['opponent'] as String,
            metric:
                DuelMetric.values.firstWhere((m) => m.name == d['metric']),
            target: d['target'] as int,
            startedAt: DateTime.parse(d['startedAt'] as String),
            days: d['days'] as int,
            myScore: d['myScore'] as int? ?? 0,
            theirScore: d['theirScore'] as int? ?? 0,
            accepted: d['accepted'] as bool? ?? false,
          ),
      ];

  void send({
    required String opponent,
    required DuelMetric metric,
    required int target,
    required int days,
  }) {
    state = [
      ActiveDuel(
        id: '$opponent-${DateTime.now().microsecondsSinceEpoch}',
        opponent: opponent,
        metric: metric,
        target: target,
        startedAt: DateTime.now(),
        days: days,
      ),
      ...state,
    ];
  }

  void log(String id, int amount) => state = [
        for (final d in state)
          if (d.id == id) d.copyWith(myScore: d.myScore + amount) else d,
      ];

  void remove(String id) => state = [for (final d in state) if (d.id != id) d];
}

final duelsProvider = StateNotifierProvider<DuelsNotifier, List<ActiveDuel>>(
  (ref) => DuelsNotifier(ref.watch(storeProvider)),
);

/// The one to show on the challenges screen: the newest still running.
final currentDuelProvider = Provider<ActiveDuel?>((ref) {
  final duels = ref.watch(duelsProvider);
  return duels.where((d) => !d.isOver).firstOrNull;
});
