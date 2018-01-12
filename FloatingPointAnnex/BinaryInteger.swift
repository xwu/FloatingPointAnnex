//
//  BinaryInteger.swift
//  FloatingPointAnnex
//
//  Created by Xiaodi Wu on 1/6/18.
//  Copyright © 2018 Xiaodi Wu. All rights reserved.
//

extension BinaryInteger {
  @_inlineable
  public func _binaryLogarithm() -> Self {
    _precondition(self > (0 as Self))

    var (quotient, remainder) =
      (bitWidth &- 1).quotientAndRemainder(dividingBy: UInt.bitWidth)
    remainder = remainder &+ 1
    var word = UInt(truncatingIfNeeded: self >> (bitWidth &- remainder))
    // If, internally, a variable-width binary integer uses digits of greater
    // bit width than that of Magnitude.Words.Element (i.e., UInt), then it is
    // possible that `word` could be zero. Additionally, a signed variable-width
    // binary integer may have a leading word that is zero to store a clear sign
    // bit.
    while word == 0 {
      quotient = quotient &- 1
      remainder = remainder &+ UInt.bitWidth
      word = UInt(truncatingIfNeeded: self >> (bitWidth &- remainder))
    }
    // Note that the order of operations below is important to guarantee that
    // we won't overflow.
    return Self(
      UInt.bitWidth &* quotient &+
        (UInt.bitWidth &- (word.leadingZeroBitCount &+ 1)))
  }
}

extension FixedWidthInteger {
  @_inlineable
  public func _binaryLogarithm() -> Self {
    _precondition(self > (0 as Self))
    return Self(Self.bitWidth &- (leadingZeroBitCount &+ 1))
  }
}
