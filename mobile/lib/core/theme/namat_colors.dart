import 'package:flutter/material.dart';

/// The NAMAT palette.
///
/// These are the same values as the web app's CSS custom properties, kept
/// deliberately as plain constants rather than derived from a Material seed:
/// `ColorScheme.fromSeed` would invent its own tones and the brand would drift
/// between the two products for reasons nobody chose.
///
/// The deep green is a surface colour, not an accent. Against the `ink` text
/// it is only a few steps away and reads as a printing error when used for
/// emphasis — [accent] exists for that, opened up until it is unmistakably
/// green while still clearing 4.5:1 on [canvas].
abstract final class NamatColors {
  // --- Brand ---------------------------------------------------------------
  static const deep = Color(0xFF2F4F4A);
  static const deeper = Color(0xFF233C38);
  static const accent = Color(0xFF46795C);
  static const greenSoft = Color(0xFFE7EFE6);
  static const sage = Color(0xFF7DA27D);
  static const sageLight = Color(0xFFA8C699);
  static const sageSoft = Color(0xFFEFF4EA);

  // --- Ground --------------------------------------------------------------
  static const canvas = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const warm = Color(0xFFF2E9D8);
  static const warmSoft = Color(0xFFF7F1E6);

  // --- Ink -----------------------------------------------------------------
  static const ink = Color(0xFF333333);
  static const inkSoft = Color(0xFF6E7370);
  static const line = Color(0xFFE6E2D8);

  // --- Signal --------------------------------------------------------------
  static const gold = Color(0xFFC79A5B);
  static const goldSoft = Color(0xFFF8F0E2);
  static const danger = Color(0xFFB4483F);

  // --- Ecosystem hues ------------------------------------------------------
  // One per field. Each is tuned to clear 4.5:1 against its own soft tint,
  // because that pairing carries 12sp chip labels; picked by eye, five of
  // these sat under 3.5:1 — legible on a designer's monitor and not in Omani
  // daylight.
  static const food = Color(0xFF9F5C34);
  static const foodSoft = Color(0xFFFAEFE6);
  static const nutrition = Color(0xFF3C7772);
  static const nutritionSoft = Color(0xFFE8F2F1);
  static const gym = Color(0xFF4C5E80);
  static const gymSoft = Color(0xFFECEFF5);
  static const fitness = Color(0xFFB24D39);
  static const fitnessSoft = Color(0xFFFBECE8);
  static const pilates = Color(0xFF885F80);
  static const pilatesSoft = Color(0xFFF4ECF3);
  static const wellness = Color(0xFF557752);
  static const wellnessSoft = Color(0xFFEDF4EC);
  static const products = Color(0xFF8A692F);
  static const productsSoft = Color(0xFFF8F1E1);
}

/// Spacing, radii and motion, so no widget invents its own.
abstract final class NamatSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const section = 36.0;

  /// The screen gutter. Every full-width surface starts here.
  static const gutter = 20.0;
}

abstract final class NamatRadius {
  static const xs = 12.0;
  static const sm = 16.0;
  static const md = 20.0;
  static const lg = 24.0;
  static const xl = 28.0;
  static const organic = 34.0;
}

abstract final class NamatMotion {
  /// A press, a chip, anything under the finger.
  static const fast = Duration(milliseconds: 180);

  /// The default: card entry, sheet, progress.
  static const base = Duration(milliseconds: 260);

  /// Page transitions and hero flights.
  static const slow = Duration(milliseconds: 380);

  /// Progress rings and counters filling from zero.
  static const reveal = Duration(milliseconds: 900);

  /// Deliberately not a bounce. The brand is calm; overshoot reads as playful,
  /// which is the wrong register for a health product.
  static const curve = Curves.easeOutCubic;
  static const enter = Cubic(0.22, 0.61, 0.36, 1);
}
