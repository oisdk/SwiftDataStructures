import Foundation
import XCTest

extension MutableCollectionType where
  Self : SameOrder,
  Generator.Element == Int,
  SubSequence.Generator.Element == Int {
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
  }
  static internal func testMutIndexing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        var mutAr = randAr
        var mutSe = seq
        let n = Int(arc4random_uniform(10000))
        mutAr[iA] = n
        mutSe[iS] = n
        XCTAssert(mutAr.elementsEqual(mutSe), "Mutating index setter did not work as expected.\nExpected: \(mutAr)\nRecerived: \(Array(mutSe))")
        XCTAssert(mutSe.invariantPassed, "Invariant broken: \(Array(mutSe))")
      }
    }
  }
}