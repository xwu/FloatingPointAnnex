//
//  FloatingPoint.swift
//  FloatingPointAnnex
//
//  Created by Xiaodi Wu on 1/6/18.
//  Copyright © 2018 Xiaodi Wu. All rights reserved.
//

extension BinaryFloatingPoint {
  @_inlineable
  @inline(__always)
  public // @testable
  static func _convert<Source : BinaryInteger> (
    from source: Source
  ) -> (value: Self, exact: Bool) where Source.Magnitude : BinaryInteger {
    guard _fastPath(source != 0) else { return (0, true) }

    let magnitude = source.magnitude

    let exponent = Int(magnitude._binaryLogarithm())
    let exemplar = Self.greatestFiniteMagnitude
    guard _fastPath(exponent <= exemplar.exponent) else {
      return Source.isSigned && source < 0
        ? (-.infinity, false)
        : (.infinity, false)
    }
    let exponentBitPattern =
      (1 as Self).exponentBitPattern /* (i.e., bias) */
        + Self.RawExponent(exponent)

    let maxSignificandWidth = exemplar.significandWidth
    let shift = maxSignificandWidth &- exponent
    let significandBitPattern = shift >= 0
      ? Self.RawSignificand(magnitude) << shift & exemplar.significandBitPattern
      : Self.RawSignificand(
        magnitude >> -shift & Source.Magnitude(exemplar.significandBitPattern))

    let value = Self(
      sign: Source.isSigned && source < 0 ? .minus : .plus,
      exponentBitPattern: exponentBitPattern,
      significandBitPattern: significandBitPattern)

    if exponent &- magnitude.trailingZeroBitCount <= maxSignificandWidth {
      return (value, true)
    }
    // We promise to round to the closest representation, and if two
    // representable values are equally close, the value with more trailing
    // zeros in its significand bit pattern. Therefore, we must take a look at
    // the bits that we've just truncated.
    let ulp = (1 as Source.Magnitude) << -shift
    let truncatedBits = magnitude & (ulp - 1)
    if truncatedBits < ulp / 2 {
      return (value, false)
    }
    let rounded = Source.isSigned && source < 0 ? value.nextDown : value.nextUp
    guard _fastPath(
      truncatedBits != ulp / 2 ||
        exponentBitPattern.trailingZeroBitCount <
        rounded.exponentBitPattern.trailingZeroBitCount) else {
          return (value, false)
    }
    return (rounded, false)
  }

  @_inlineable // FIXME(sil-serialize-all)
  public init<Source : BinaryInteger>(_ value: Source) where Source.Magnitude : BinaryInteger {
    self = Self._convert(from: value).value
  }

  @_inlineable // FIXME(sil-serialize-all)
  public init?<Source : BinaryInteger>(exactly value: Source) where Source.Magnitude : BinaryInteger {
    let (value_, exact) = Self._convert(from: value)
    guard exact else { return nil }
    self = value_
  }

  @_inlineable
  @inline(__always)
  public // @testable
  static func _convert<Source : BinaryFloatingPoint>(
    from source: Source
  ) -> (value: Self, exact: Bool) {
    guard _fastPath(!source.isZero) else {
      return (source.sign == .minus ? -0.0 : 0, true)
    }

    guard _fastPath(source.isFinite) else {
      if source.isInfinite {
        return (source.sign == .minus ? -.infinity : .infinity, true)
      }
      // IEEE 754 requires that any NaN payload be propagated, if possible.
      let payload_ =
        source.significandBitPattern &
          ~(Source.nan.significandBitPattern |
            Source.signalingNaN.significandBitPattern)
      let mask =
        Self.greatestFiniteMagnitude.significandBitPattern &
          ~(Self.nan.significandBitPattern |
            Self.signalingNaN.significandBitPattern)
      let payload = Self.RawSignificand(truncatingIfNeeded: payload_) & mask
      // Although .signalingNaN.exponentBitPattern == .nan.exponentBitPattern,
      // we do not *need* to rely on this relation, and therefore we do not.
      let value = source.isSignalingNaN
        ? Self(
          sign: source.sign,
          exponentBitPattern: Self.signalingNaN.exponentBitPattern,
          significandBitPattern: payload |
            Self.signalingNaN.significandBitPattern)
        : Self(
          sign: source.sign,
          exponentBitPattern: Self.nan.exponentBitPattern,
          significandBitPattern: payload | Self.nan.significandBitPattern)
      return payload_ == payload ? (value, true) : (value, false)
    }

    let exponent = source.exponent
    var exemplar = Self.leastNormalMagnitude
    let exponentBitPattern: Self.RawExponent
    let leadingBitIndex: Int
    let shift: Int
    let significandBitPattern: Self.RawSignificand

    if exponent < exemplar.exponent {
      // The floating-point result is either zero or subnormal.
      exemplar = Self.leastNonzeroMagnitude
      let minExponent = exemplar.exponent
      if exponent + 1 < minExponent {
        return (source.sign == .minus ? -0.0 : 0, false)
      }
      if _slowPath(exponent + 1 == minExponent) {
        // Although the most significant bit (MSB) of a subnormal source
        // significand is explicit, Swift BinaryFloatingPoint APIs actually
        // omit any explicit MSB from the count represented in
        // significandWidth. For instance:
        //
        //   Double.leastNonzeroMagnitude.significandWidth == 0
        //
        // Therefore, we do not need to adjust our work here for a subnormal
        // source.
        return source.significandWidth == 0
          ? (source.sign == .minus ? -0.0 : 0, false)
          : (source.sign == .minus ? -exemplar : exemplar, false)
      }

      exponentBitPattern = 0 as Self.RawExponent
      leadingBitIndex = Int(Self.Exponent(exponent) - minExponent)
      shift =
        leadingBitIndex &-
        (source.significandWidth &+
          source.significandBitPattern.trailingZeroBitCount)
      let leadingBit = source.isNormal
        ? (1 as Self.RawSignificand) << leadingBitIndex
        : 0
      significandBitPattern = leadingBit | (shift >= 0
        ? Self.RawSignificand(source.significandBitPattern) << shift
        : Self.RawSignificand(source.significandBitPattern >> -shift))
    } else {
      // The floating-point result is either normal or infinite.
      exemplar = Self.greatestFiniteMagnitude
      if exponent > exemplar.exponent {
        return (source.sign == .minus ? -.infinity : .infinity, false)
      }

      exponentBitPattern = exponent < 0
        ? (1 as Self).exponentBitPattern - Self.RawExponent(-exponent)
        : (1 as Self).exponentBitPattern + Self.RawExponent(exponent)
      leadingBitIndex = exemplar.significandWidth
      shift =
        leadingBitIndex &-
          (source.significandWidth &+
            source.significandBitPattern.trailingZeroBitCount)
      let sourceLeadingBit = source.isSubnormal
        ? (1 as Source.RawSignificand) <<
          (source.significandWidth &+
            source.significandBitPattern.trailingZeroBitCount)
        : 0
      significandBitPattern = shift >= 0
        ? Self.RawSignificand(
          sourceLeadingBit ^ source.significandBitPattern) << shift
        : Self.RawSignificand(
          (sourceLeadingBit ^ source.significandBitPattern) >> -shift)
    }

    let value = Self(
      sign: source.sign,
      exponentBitPattern: exponentBitPattern,
      significandBitPattern: significandBitPattern)

    if source.significandWidth <= leadingBitIndex {
      return (value, true)
    }
    // We promise to round to the closest representation, and if two
    // representable values are equally close, the value with more trailing
    // zeros in its significand bit pattern. Therefore, we must take a look at
    // the bits that we've just truncated.
    let ulp = (1 as Source.RawSignificand) << -shift
    let truncatedBits = source.significandBitPattern & (ulp - 1)
    if truncatedBits < ulp / 2 {
      return (value, false)
    }
    let rounded = source.sign == .minus ? value.nextDown : value.nextUp
    guard _fastPath(
      truncatedBits != ulp / 2 ||
        exponentBitPattern.trailingZeroBitCount <
          rounded.exponentBitPattern.trailingZeroBitCount) else {
      return (value, false)
    }
    return (rounded, false)
  }

  @_inlineable // FIXME(sil-serialize-all)
  public init<Source : BinaryFloatingPoint>(_ value: Source) {
    self = Self._convert(from: value).value
  }

  @_inlineable // FIXME(sil-serialize-all)
  public init?<Source : BinaryFloatingPoint>(exactly value: Source) {
    let (value_, exact) = Self._convert(from: value)
    guard exact else { return nil }
    self = value_
  }
}
