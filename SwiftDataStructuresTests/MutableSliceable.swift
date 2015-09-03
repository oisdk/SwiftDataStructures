import Foundation
import XCTest

extension MutableSliceable where
  Self : SameOrder,
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
  }
  static internal func testMutIndexSlicing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        for (jA, jS) in zip(iA..<randAr.endIndex, iS..<seq.endIndex) {
          var mutAr = randAr
          var mutSe = seq
          let replacement = (iA...jA).map { _ in Int(arc4random_uniform(10000)) }
          mutAr[iA...jA] = ArraySlice(replacement)
          mutSe[iS...jS] = SubSequence(replacement)
          XCTAssert(mutAr.elementsEqual(mutSe), "Range subscript replacement did not produce expected result.\nInitialized from array: \(randAr)\nTried to replace range: \(iA...jA) with \(replacement)\nExpected: \(mutAr)\nReceived: \(Array(mutSe))")
          XCTAssert(mutSe.invariantPassed, "Invariant broken: \(Array(mutSe))")
        }
      }
    }
  }
}