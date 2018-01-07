//
//  BinaryInteger.swift
//  FloatingPointAnnex
//
//  Created by Xiaodi Wu on 1/6/18.
//  Copyright © 2018 Xiaodi Wu. All rights reserved.
//

extension BinaryInteger {
#if swift(>=4.1)
  @_inlineable
  public func _binaryLogarithm() -> Self {
    _precondition(self > 0)
    let wordBitWidth = Magnitude.Words.Element.bitWidth
    let reversedWords = magnitude.words.reversed()
    // If, internally, a variable-width binary integer uses digits of greater
    // bit width than that of Magnitude.Words.Element (i.e., UInt), then it is
    // possible that more than one element of Magnitude.Words could be entirely
    // zero.
    let reversedWordsLeadingZeroBitCount =
      zip(0..., reversedWords)
        .first { $0.1 != 0 }
        .map { $0.0 &* wordBitWidth &+ $0.1.leadingZeroBitCount }!
    let logarithm =
      reversedWords.count &* wordBitWidth &-
        (reversedWordsLeadingZeroBitCount &+ 1)
    return Self(logarithm)
  }
#endif
}

extension FixedWidthInteger where Magnitude : FixedWidthInteger {
  @_inlineable
  public func _binaryLogarithm() -> Self {
    _precondition(self > 0)
    return Self(Magnitude.bitWidth &- (magnitude.leadingZeroBitCount &+ 1))
  }
}
