/// Conforming CollectionTypes can be initialized from a SequenceType

protocol FlexibleInitable : CollectionType {
  init<S : SequenceType where S.Generator.Element == Generator.Element>(_ s: S)
  var invariantPassed: Bool { get }
}

extension FlexibleInitable {
  var invariantPassed: Bool { return true }
}

extension Array           : FlexibleInitable {}
extension ArraySlice      : FlexibleInitable {}
extension ContiguousArray : FlexibleInitable {}
extension Set             : FlexibleInitable {}
extension Dictionary      : FlexibleInitable {
  init<S : SequenceType where S.Generator.Element == Generator.Element>(_ s: S) {
    var result: [Key:Value] = [:]
    for (k, v) in s { result[k] = v }
    self = result
  }
}

import XCTest
import Foundation

internal func randArs() -> [[Int]] {
  return (0..<10).map { n in
    (0..<n).map { _ in Int(arc4random_uniform(100000)) }
  }
}

extension FlexibleInitable where Generator.Element == Int {
  static func test() {
    testMultiPass()
  }
  static internal func testMultiPass() {
    for randAr in randArs() {
      let seq = Self(randAr)
      let first = Array(seq)
      let secnd = Array(seq)
      XCTAssert(first.elementsEqual(secnd), "\nFirst pass over self did not equal second pass over self\nFirst pass: \(first)\nSecond pass: \(secnd)")
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
}

/// Conforming CollectionTypes have the same number of unique elements as the sequence
/// they were initialized from.

protocol SameNumberUniques : FlexibleInitable {}

extension Array           : SameNumberUniques {}
extension ArraySlice      : SameNumberUniques {}
extension ContiguousArray : SameNumberUniques {}
extension Set             : SameNumberUniques {}
extension Dictionary      : SameNumberUniques {}

extension SameNumberUniques where Generator.Element == Int {
  static func test() {
    testMultiPass()
    testCount()
    testSeqInit()
  }
  static internal func testCount() {
    for randSet in randArs().map(Set.init) {
      let seq = Self(randSet)
      XCTAssertEqual(randSet.count, Array(seq).count, "Did not contain the same number of elements as the unique collection of elements self was initialized to.\nUnique elements: \(randSet)\nSelf: \(Array(seq))")
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
  static internal func testSeqInit() {
    for randSet in randArs().map(Set.init) {
      let seq = Self(randSet)
      let expectation = randSet.sort()
      let reality     = seq.sort()
      XCTAssert(expectation.elementsEqual(reality), "Self did not contain the same elements as the set it was initialized from.\nSet: \(expectation)\nSelf: \(reality)")
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
}

/// Confomring CollectionTypes have the same elements, in the same order, as the
/// SequenceType they were initialized from.

protocol SameOrder : SameNumberUniques {}

extension Array           : SameOrder {}
extension ArraySlice      : SameOrder {}
extension ContiguousArray : SameOrder {}

extension SameOrder where Generator.Element == Int, SubSequence.Generator.Element == Int {
  static func test() {
    testMultiPass()
    testCount()
    testSeqInit()
    testSameEls()
    testIndexing()
    testFirst()
    testRangeIndexing()
    testSplit()
  }
  static internal func testSameEls() {
    for randAr in randArs() {
      let seq = Self(randAr)
      XCTAssert(randAr.elementsEqual(seq), "Did not contain the same elements as the array self was initialized from.\nArray: \(randAr)\nSelf: \(seq)")
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
  static internal func testIndexing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        XCTAssertEqual(randAr[iA], seq[iS], "Did not have correct element at index. \nExpected: \(randAr[iA])\nFound: \(seq[iS])\nFrom array: \(randAr)")
      }
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
  static internal func testFirst() {
    for randAr in randArs() {
      let seq = Self(randAr)
      XCTAssert(seq.first == randAr.first, "first property did non return as expected.\nExpected: \(randAr.first)\nReceived: \(seq.first)\nFrom array: \(randAr)")
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
    }
  }
  static internal func testRangeIndexing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        for (jA, jS) in zip(iA..<randAr.endIndex, iS..<seq.endIndex) {
          let arSlice  = randAr[iA...jA]
          let seqSlice = seq[iS...jS]
          XCTAssert(arSlice.elementsEqual(seqSlice), "Slice did not match corresponding array slice.\nExpected: \(arSlice)\nReceived: \(seqSlice)\nFrom array: \(randAr)")
          XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
        }
      }
    }
  }
  static internal func testSplit() {
    for randAr in randArs() {
      let seq = Self(randAr)
      XCTAssert(seq.invariantPassed, "Invariant broken: \(Array(seq))")
      for maxSplit in randAr.indices {
        for allow in [true, false] {
          let splitFuncs: [Int -> Bool] = (0..<5).map { _ in
            let n = Int(arc4random_uniform(10) + 1)
            let splitFunc: Int -> Bool = { i in i % n == 0 }
            return splitFunc
          }
          for splitFunc in splitFuncs {
            let splittedAr = randAr.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            let splittedSeq = seq.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            XCTAssertEqual(splittedAr.count, splittedSeq.count, "Different number of splits returned.\nExpected: \(splittedAr)\nReceived: \(splittedSeq.map(Array.init))")
            for (arSl, seqSl) in zip(splittedAr, splittedSeq) {
              XCTAssert(arSl.elementsEqual(seqSl), "Slices did not match.\nExpected: \(arSl)\nReceived: \(seqSl)")
            }
          }
        }
      }
    }
  }
}
