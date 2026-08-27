/// The facts about a service that decide whether someone books it.
///
/// Split out of [Offering] because these are the parts a member reads before
/// committing — what is included, whether there is room, when it runs, what
/// happens if they cancel — and because most of them are answerable only for
/// services NAMAT operates itself. A third-party business has not told us its
/// cancellation policy, and inventing one would be a promise made on their
/// behalf that they never agreed to.
library;

/// Whether a service happens in a room or over a call.
enum ServiceFormat { inPerson, remote, either }

/// How hard a class is.
///
/// `any` is a real answer, not a missing one: a beginners-welcome class is
/// different from a class whose level we do not know.
enum FitnessLevel { any, beginner, intermediate, advanced }

/// What happens when someone cancels.
///
/// An enum rather than free text so it translates, and so two partners cannot
/// express the same policy in two ways that a member has to compare by
/// reading. Null means the partner has not told us — which is shown as
/// unknown, never as "free".
enum CancellationPolicy { free24h, free2h, nonRefundable }

/// One recurring time in a week.
class SessionTime {
  const SessionTime(this.weekday, this.hour, [this.minute = 0]);

  /// `DateTime.monday` … `DateTime.sunday`.
  final int weekday;
  final int hour;
  final int minute;

  /// The next occurrence at or after [from].
  ///
  /// Computed rather than stored, so the times stay correct as days pass
  /// instead of drifting into the past the way a fixed list would.
  DateTime nextAfter(DateTime from) {
    var days = (weekday - from.weekday) % 7;
    if (days < 0) days += 7;
    var candidate = DateTime(
      from.year,
      from.month,
      from.day + days,
      hour,
      minute,
    );
    // Today's slot has already passed; take next week's.
    if (!candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }
}

/// When a service runs, and how many places are left.
class Availability {
  const Availability({
    this.times = const [],
    this.spotsLeft,
    this.capacity,
  });

  /// Empty means the service has no fixed timetable — a consultation booked
  /// into whatever hour suits, rather than a class at six on a Tuesday.
  final List<SessionTime> times;

  /// Null means places are not counted for this service. Zero means full, and
  /// the two are deliberately different: a dish that nobody counts must not
  /// render as sold out.
  final int? spotsLeft;
  final int? capacity;

  bool get isFull => spotsLeft != null && spotsLeft! <= 0;

  /// Worth drawing attention to. Above this the number is noise; below it, it
  /// is the reason someone books now rather than later.
  bool get isNearlyFull =>
      spotsLeft != null && spotsLeft! > 0 && spotsLeft! <= 3;

  /// The next [count] occurrences, soonest first.
  List<DateTime> upcoming(DateTime from, {int count = 6}) {
    if (times.isEmpty) return const [];
    final all = [for (final t in times) t.nextAfter(from)]..sort();
    // A weekly timetable repeats, so a service running twice a week fills six
    // slots from three weeks rather than showing only two.
    final out = <DateTime>[];
    for (var week = 0; out.length < count; week++) {
      for (final d in all) {
        out.add(d.add(Duration(days: 7 * week)));
        if (out.length == count) break;
      }
      if (week > 8) break;
    }
    return out;
  }
}

/// When a place is open.
///
/// Only ever set for services NAMAT runs. A real partner's hours are theirs to
/// publish, and a wrong closing time sends a member to a locked door.
class OpeningHours {
  const OpeningHours({
    required this.opensAt,
    required this.closesAt,
    this.closedOn = const [],
  });

  /// Minutes from midnight. Local Oman time, which has no daylight saving, so
  /// there is no shifting to account for.
  final int opensAt;
  final int closesAt;

  /// `DateTime.friday` and friends.
  final List<int> closedOn;

  bool isOpenAt(DateTime when) {
    if (closedOn.contains(when.weekday)) return false;
    final minutes = when.hour * 60 + when.minute;
    return minutes >= opensAt && minutes < closesAt;
  }

  /// Formatted as "6:00" / "22:00" for the caller to localise the digits of.
  static String format(int minutes) {
    final h = (minutes ~/ 60).toString();
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
