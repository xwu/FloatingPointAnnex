//
//  FloatingPointAnnexTests.swift
//  FloatingPointAnnexTests
//
//  Created by Xiaodi Wu on 1/6/18.
//  Copyright © 2018 Xiaodi Wu. All rights reserved.
//

import XCTest
import FloatingPointAnnex

class FloatingPointAnnexTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here.
  }

  override func tearDown() {
    // Put teardown code here.
    super.tearDown()
  }

  func testIntegerConversion() {
    XCTAssert(Double._convert(from: 0) == (value: 0, exact: true))
    
    XCTAssert(Double._convert(from: 1) == (value: 1, exact: true))
    XCTAssert(Double._convert(from: -1) == (value: -1, exact: true))

    XCTAssert(Double._convert(from: 42) == (value: 42, exact: true))
    XCTAssert(Double._convert(from: -42) == (value: -42, exact: true))

    XCTAssert(Double._convert(from: 100) == (value: 100, exact: true))
    XCTAssert(Double._convert(from: -100) == (value: -100, exact: true))

    XCTAssert(Double._convert(from: Int64.max).value == Double(Int64.max))
    XCTAssert(Double._convert(from: Int64.min).value == Double(Int64.min))

    var x = ((Int64.max >> 11) + 1) << 11
    XCTAssert(Double._convert(from: x).value == Double(x))
    x = (Int64.max >> 12) << 12 + 1
    XCTAssert(Double._convert(from: x).value == Double(x))
    x = Int64.min + 1
    XCTAssert(Double._convert(from: x).value == Double(x))

    XCTAssert(Float._convert(from: Int64.max).value == Float(Int64.max))
    XCTAssert(Float._convert(from: Int64.min).value == Float(Int64.min))

#if swift(>=4.1)
    XCTAssert(Float._convert(from: DoubleWidth<UInt64>.max).value == .infinity)
    XCTAssert(
      Float._convert(from: DoubleWidth<DoubleWidth<Int64>>.max).value ==
        .infinity)
    XCTAssert(
      Float._convert(from: DoubleWidth<DoubleWidth<Int64>>.min).value ==
        -.infinity)
#endif
  }

  func testIntegerConversion2() {
    XCTAssertTrue(Double._convert(from: 0) == (value: 0, exact: true))

    XCTAssertTrue(Double._convert(from: 1) == (value: 1, exact: true))
    XCTAssertTrue(Double._convert(from: -1) == (value: -1, exact: true))

    XCTAssertTrue(Double._convert(from: 42) == (value: 42, exact: true))
    XCTAssertTrue(Double._convert(from: -42) == (value: -42, exact: true))

    XCTAssertTrue(Double._convert(from: 100) == (value: 100, exact: true))
    XCTAssertTrue(Double._convert(from: -100) == (value: -100, exact: true))

    XCTAssertEqual(Double._convert(from: Int64.max).value, Double(Int64.max))
    XCTAssertEqual(Double._convert(from: Int64.min).value, Double(Int64.min))

    var x = ((Int64.max >> 11) + 1) << 11
    XCTAssertEqual(Double._convert(from: x).value, Double(x))
    x = (Int64.max >> 12) << 12 + 1
    XCTAssertEqual(Double._convert(from: x).value, Double(x))
    x = Int64.min + 1
    XCTAssertEqual(Double._convert(from: x).value, Double(x))

    XCTAssertEqual(Float._convert(from: Int64.max).value, Float(Int64.max))
    XCTAssertEqual(Float._convert(from: Int64.min).value, Float(Int64.min))

#if swift(>=4.1)
    XCTAssertEqual(Float._convert(from: DoubleWidth<UInt64>.max).value, .infinity)
    XCTAssertEqual(
      Float._convert(from: DoubleWidth<DoubleWidth<Int64>>.max).value, .infinity)
    XCTAssertEqual(
      Float._convert(from: DoubleWidth<DoubleWidth<Int64>>.min).value, -.infinity)
#endif
  }

  func testFloatingPointConversion() {
    XCTAssert(Double._convert(from: 0 as Float) == (value: 0, exact: true))
    XCTAssert(
      Double._convert(from: -0.0 as Float) == (value: -0.0, exact: true))
    XCTAssert(Double._convert(from: 1 as Float) == (value: 1, exact: true))
    XCTAssert(Double._convert(from: -1 as Float) == (value: -1, exact: true))
    XCTAssert(
      Double._convert(from: Float.infinity) == (value: .infinity, exact: true))
    XCTAssert(
      Double._convert(from: -Float.infinity) ==
        (value: -.infinity, exact: true))
    XCTAssert(Double._convert(from: Float.nan).value.isNaN)
    XCTAssert(Float._convert(from: Double.nan).value.isNaN)
    XCTAssert(!Double._convert(from: Float.nan).value.isSignalingNaN)
    XCTAssert(!Float._convert(from: Double.nan).value.isSignalingNaN)
    XCTAssert(Double._convert(from: Float.signalingNaN).value.isNaN)
    XCTAssert(Float._convert(from: Double.signalingNaN).value.isNaN)

    let x = Float(bitPattern: Float.nan.bitPattern | 0xf)
    XCTAssert(
      Float._convert(from: Double._convert(from: x).value).value.bitPattern ==
        x.bitPattern)
    let a = Float(bitPattern: Float.signalingNaN.bitPattern | 0xf)
    XCTAssert(
      Float._convert(from: Double._convert(from: a).value).value.bitPattern ==
        a.bitPattern ||
        Float._convert(from: Double._convert(from: a).value).value.bitPattern ==
          x.bitPattern)
    var y = Double(bitPattern: Double.nan.bitPattern | 0xf)
    XCTAssert(
      Double._convert(from: Float._convert(from: y).value).value.bitPattern ==
        y.bitPattern)
    let b = Double(bitPattern: Double.signalingNaN.bitPattern | 0xf)
    XCTAssert(
      Double._convert(from: Float._convert(from: b).value).value.bitPattern ==
        b.bitPattern ||
        Double._convert(from: Float._convert(from: b).value).value.bitPattern ==
          y.bitPattern)
    y = Double(bitPattern: Double.nan.bitPattern | (1 << 32 - 1))
    XCTAssert(
      Double._convert(from: Float._convert(from: y).value).value.bitPattern !=
        y.bitPattern)
    XCTAssert(Float._convert(from: y).value.isNaN)
    XCTAssertFalse(Float._convert(from: y).exact)

    XCTAssert(
      Float._convert(from: Double.leastNonzeroMagnitude) ==
        (value: 0, exact: false))
    XCTAssert(
      Float._convert(from: -Double.leastNonzeroMagnitude) ==
        (value: -0.0, exact: false))
    XCTAssert(
      Double._convert(from: Double.leastNonzeroMagnitude) ==
        (value: .leastNonzeroMagnitude, exact: true))
    XCTAssert(
      Double._convert(from: -Double.leastNonzeroMagnitude) ==
        (value: -.leastNonzeroMagnitude, exact: true))

    y = Double._convert(from: Float.leastNonzeroMagnitude).value / 2
    XCTAssert(Float._convert(from: y) == (value: 0, exact: false))
    y.negate()
    XCTAssert(Float._convert(from: y) == (value: -0.0, exact: false))
    y.negate()
    y = y.nextUp
    XCTAssert(
      Float._convert(from: y) == (value: .leastNonzeroMagnitude, exact: false))
    y.negate()
    XCTAssert(
      Float._convert(from: y) == (value: -.leastNonzeroMagnitude, exact: false))

    XCTAssert(
      Float._convert(from: Double.leastNormalMagnitude).value ==
        Float(Double.leastNormalMagnitude))
    XCTAssert(
      Float._convert(from: -Double.leastNormalMagnitude).value ==
        Float(-Double.leastNormalMagnitude))

    XCTAssert(
      Float._convert(from: Double.pi).value == 3.14159265)

    y =
      Double._convert(from: Float._convert(from: Double.pi).value).value.nextUp
    XCTAssert(
      Float._convert(from: y).value == 3.14159265)
    y.negate()
    XCTAssert(
      Float._convert(from: y).value == -3.14159265)

    XCTAssert(
      Float._convert(from: Double.greatestFiniteMagnitude) ==
        (value: .infinity, exact: false))
    XCTAssert(
      Float._convert(from: -Double.greatestFiniteMagnitude) ==
        (value: -.infinity, exact: false))
    XCTAssert(
      Double._convert(from: Double.greatestFiniteMagnitude) ==
        (value: .greatestFiniteMagnitude, exact: true))
    XCTAssert(
      Double._convert(from: -Double.greatestFiniteMagnitude) ==
        (value: -.greatestFiniteMagnitude, exact: true))
    
    XCTAssert(
      Float._convert(
        from: Double._convert(
          from: Float.greatestFiniteMagnitude).value).value ==
        Float.greatestFiniteMagnitude)
    XCTAssert(
      Float._convert(
        from: Double._convert(
          from: Float.leastNonzeroMagnitude).value).value ==
        Float.leastNonzeroMagnitude)
  }

  func testFloatingPointConversion2() {
    XCTAssertTrue(Double._convert(from: 0 as Float) == (value: 0, exact: true))
    XCTAssertTrue(Double._convert(from: -0.0 as Float) == (value: -0.0, exact: true))
    XCTAssertTrue(Double._convert(from: 1 as Float) == (value: 1, exact: true))
    XCTAssertTrue(Double._convert(from: -1 as Float) == (value: -1, exact: true))
    XCTAssertTrue(
      Double._convert(from: Float.infinity) == (value: .infinity, exact: true))
    XCTAssertTrue(
      Double._convert(from: -Float.infinity) == (value: -.infinity, exact: true))
    XCTAssertTrue(Double._convert(from: Float.nan).value.isNaN)
    XCTAssertTrue(Float._convert(from: Double.nan).value.isNaN)
    XCTAssertFalse(Double._convert(from: Float.nan).value.isSignalingNaN)
    XCTAssertFalse(Float._convert(from: Double.nan).value.isSignalingNaN)
    XCTAssertTrue(Double._convert(from: Float.signalingNaN).value.isNaN)
    XCTAssertTrue(Float._convert(from: Double.signalingNaN).value.isNaN)

    let x = Float(bitPattern: Float.nan.bitPattern | 0xf)
    XCTAssertEqual(
      Float._convert(from: Double._convert(from: x).value).value.bitPattern,
      x.bitPattern)
    let a = Float(bitPattern: Float.signalingNaN.bitPattern | 0xf)
    XCTAssertTrue(
      Float._convert(from: Double._convert(from: a).value).value.bitPattern ==
        a.bitPattern ||
        Float._convert(from: Double._convert(from: a).value).value.bitPattern ==
          x.bitPattern)
    var y = Double(bitPattern: Double.nan.bitPattern | 0xf)
    XCTAssertEqual(
      Double._convert(from: Float._convert(from: y).value).value.bitPattern,
      y.bitPattern)
    let b = Double(bitPattern: Double.signalingNaN.bitPattern | 0xf)
    XCTAssertTrue(
      Double._convert(from: Float._convert(from: b).value).value.bitPattern ==
        b.bitPattern ||
        Double._convert(from: Float._convert(from: b).value).value.bitPattern ==
          y.bitPattern)
    y = Double(bitPattern: Double.nan.bitPattern | (1 << 32 - 1))
    XCTAssertNotEqual(
      Double._convert(from: Float._convert(from: y).value).value.bitPattern,
      y.bitPattern)
    XCTAssertTrue(Float._convert(from: y).value.isNaN)
    XCTAssertFalse(Float._convert(from: y).exact)

    XCTAssertTrue(
      Float._convert(from: Double.leastNonzeroMagnitude) ==
        (value: 0, exact: false))
    XCTAssertTrue(
      Float._convert(from: -Double.leastNonzeroMagnitude) ==
        (value: -0.0, exact: false))
    XCTAssertTrue(
      Double._convert(from: Double.leastNonzeroMagnitude) ==
        (value: .leastNonzeroMagnitude, exact: true))
    XCTAssertTrue(
      Double._convert(from: -Double.leastNonzeroMagnitude) ==
        (value: -.leastNonzeroMagnitude, exact: true))

    y = Double._convert(from: Float.leastNonzeroMagnitude).value / 2
    XCTAssertTrue(Float._convert(from: y) == (value: 0, exact: false))
    y.negate()
    XCTAssertTrue(Float._convert(from: y) == (value: -0.0, exact: false))
    y.negate()
    y = y.nextUp
    XCTAssertTrue(
      Float._convert(from: y) == (value: .leastNonzeroMagnitude, exact: false))
    y.negate()
    XCTAssertTrue(
      Float._convert(from: y) == (value: -.leastNonzeroMagnitude, exact: false))

    XCTAssertEqual(
      Float._convert(from: Double.leastNormalMagnitude).value,
      Float(Double.leastNormalMagnitude))
    XCTAssertEqual(
      Float._convert(from: -Double.leastNormalMagnitude).value,
      Float(-Double.leastNormalMagnitude))

    XCTAssertEqual(Float._convert(from: Double.pi).value, 3.14159265)

    y = Double._convert(from: Float._convert(from: Double.pi).value).value.nextUp
    XCTAssertEqual(Float._convert(from: y).value, 3.14159265)
    y.negate()
    XCTAssertEqual(Float._convert(from: y).value, -3.14159265)

    XCTAssertTrue(
      Float._convert(from: Double.greatestFiniteMagnitude) ==
        (value: .infinity, exact: false))
    XCTAssertTrue(
      Float._convert(from: -Double.greatestFiniteMagnitude) ==
        (value: -.infinity, exact: false))
    XCTAssertTrue(
      Double._convert(from: Double.greatestFiniteMagnitude) ==
        (value: .greatestFiniteMagnitude, exact: true))
    XCTAssertTrue(
      Double._convert(from: -Double.greatestFiniteMagnitude) ==
        (value: -.greatestFiniteMagnitude, exact: true))

    XCTAssertEqual(
      Float._convert(
        from: Double._convert(from: Float.greatestFiniteMagnitude).value).value,
      Float.greatestFiniteMagnitude)
    XCTAssertEqual(
      Float._convert(
        from: Double._convert(from: Float.leastNonzeroMagnitude).value).value,
      Float.leastNonzeroMagnitude)
  }

  func testPerformanceGenericConversionFromInt() {
    var x = [Double]()
    self.measure {
      for i in 0..<1000 {
        x.append(Double._convert(from: i).value)
      }
    }
    print(x[Int(arc4random_uniform(999))])
  }

  func testPerformanceConcreteConversionFromInt() {
    var x = [Double]()
    self.measure {
      for i in 0..<1000 {
        x.append(Double(i))
      }
    }
    print(x[Int(arc4random_uniform(999))])
  }

  func testPerformanceGenericConversionFromFloat() {
    var x = [Double]()
    self.measure {
      for i in 0..<1000 {
        x.append(Double._convert(from: Float(i)).value)
      }
    }
    print(x[Int(arc4random_uniform(999))])
  }

  func testPerformanceConcreteConversionFromFloat() {
    var x = [Double]()
    self.measure {
      for i in 0..<1000 {
        x.append(Double(Float(i)))
      }
    }
    print(x[Int(arc4random_uniform(999))])
  }
}
