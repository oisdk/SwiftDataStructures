import XCTest
import Foundation

extension RangeReplaceableCollectionType where
  Self : SameOrder,
  Self : MutableSliceable,
  Generator.Element == Int,
  SubSequence.Generator.Element == Int,
  SubSequence : FlexibleInitable {
  static func test() {
    testMultiPass()
    testCount()
    testSeqInit()
    testSameEls()
    testIndexing()
    testFirst()
    testRangeIndexing()
    testSplit()
    testMutIndexing()
    testMutIndexSlicing()
    testEmptyInit()
    testReplaceRange()
  }
  static internal func testEmptyInit() {
    let empty = Self()
    XCTAssert(empty.isEmpty, "Empty initializer did not yield empty self.\nReceived: \(Array(empty))")
  }
  static internal func testReplaceRange() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        for (jA, jS) in zip(iA..<randAr.endIndex, iS..<seq.endIndex) {
          var mutAr = randAr
          var mutSe = seq
          let replacement = (0..<arc4random_uniform(10)).map { _ in Int(arc4random_uniform(10000)) }
          mutAr.replaceRange(iA...jA, with: replacement)
          mutSe.replaceRange(iS...jS, with: replacement)
          XCTAssert(mutAr.elementsEqual(mutSe), "Range subscript replacement did not produce expected result.\nInitialized from array: \(randAr)\nTried to replace range: \(iA...jA) with \(replacement)\nExpected: \(mutAr)\nReceived: \(Array(mutSe))")
          XCTAssert(mutSe.invariantPassed, "Invariant broken: \(Array(mutSe))")
        }
      }
    }
  }
}