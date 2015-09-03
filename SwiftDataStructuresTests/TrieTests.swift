import XCTest
import Foundation
@testable import SwiftDataStructures

extension String {
  private var trimSort: [String] {
    let nums = Set("0123456789".characters)
    return characters
      .split { !nums.contains($0) }
      .map(String.init)
      .sort()
  }
}

private func randAr(n: Int = 10) -> [Int] {
  return (0..<n).map { _ in Int(arc4random_uniform(100)) }
}

class TrieTests: XCTestCase {
  func testDebugString() {
    
    let ars = randArs()
    
    let expectation = Set(ars.map {$0.map(String.init).joinWithSeparator("")}).debugDescription.trimSort

    let reality = Trie(ars).debugDescription.trimSort
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testEquatable() {
    
    let first  = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let second = Trie([[3, 4, 5], [2, 3, 4], [1, 2, 3]])
    
    XCTAssertEqual(first, second)
    
    let third = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4, 5]])
    let fourth = Trie([[3, 4, 5], [2, 3, 4, 5]])
    
    XCTAssertNotEqual(first, third)
    XCTAssertNotEqual(first, fourth)
    
  }
  
  func testInsert() {
    
    let expectation = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    
    var reality = Trie([[3, 4, 5], [2, 3, 4]])
    
    reality.insert([1, 2, 3])
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testCompletions() {
    
    let trie = Trie([[1, 2, 3], [1, 2, 3, 4], [1, 2, 5, 6], [3, 4, 5]])
    
    let expectation = [[3], [3, 4], [5, 6]].sort { $0.last < $1.last }
    
    let reality = trie.completions([1, 2]).sort { $0.last < $1.last }
    
    XCTAssertEqual(expectation, reality)
  }
  
  func testRemove() {
    
    let expectation = Trie([[3, 4, 5], [2, 3, 4]])
    
    var reality = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    
    XCTAssert(reality.remove([1, 2, 3])?.elementsEqual([1, 2, 3]) == true)
    
    XCTAssertNil(reality.remove([3, 4, 5, 6]))
    
    XCTAssertNil(reality.remove([4, 2, 1]))
    
    XCTAssertEqual(expectation, reality)
  }
  
  func testContains() {
    
    let trie = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    
    XCTAssertTrue(trie.contains([1, 2, 3]))
    XCTAssertFalse(trie.contains([2, 2, 3]))
    
  }
  
  func testExclusiveOr() {
    
    let frst = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let scnd = Trie([[1, 2, 3], [3, 4, 6], [2, 3, 4]])
    
    let expectation = Trie([[3, 4, 5], [3, 4, 6]])

    XCTAssertEqual(frst.exclusiveOr(scnd), expectation)
  }
  
  func testIntersect() {
    let frst = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let scnd = Trie([[1, 2, 3], [3, 4, 6], [2, 3, 4]])
    
    let expectation = Trie([[1, 2, 3], [2, 3, 4]])
    
    XCTAssertEqual(frst.intersect(scnd), expectation)
  }
  
  func testIsDisjointWith() {
    
    let frst = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let disJoint = Trie([[24, 5, 2], [2, 5, 6], [1, 3, 5]])
    let notDisJoint = Trie([[24, 5, 2], [2, 5, 6], [1, 2, 3]])
    
    XCTAssertTrue(frst.isDisjointWith(disJoint))
    
    XCTAssertFalse(frst.isDisjointWith(notDisJoint))
    
  }
  
  func testIsSupersetOf() {
    
    let under = Trie([[1, 2, 3], [3, 4, 5]])
    
    let isSuper = Trie([[1, 2, 3], [3, 4, 5], [4, 5, 6]])
    let isNotSuper = Trie([[1, 2, 3], [4, 5, 6]])
    
    XCTAssertTrue(isSuper.isSupersetOf(under))
    XCTAssertFalse(isNotSuper.isSupersetOf(under))
    
  }
  
  func testIsSubsetOf() {
    
    let over = Trie([[1, 2, 3], [3, 4, 5]])
    
    XCTAssertTrue(over.isSubsetOf([[1, 2, 3], [3, 4, 5], [4, 5, 6]]))
    XCTAssertFalse(over.isSubsetOf([[1, 4, 3], [3, 4, 5], [4, 5, 6]]))
    
  }
  
  func testUnion() {
    
    let frst = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let scnd = Trie([[1, 2, 3], [3, 4, 6], [2, 3, 4]])
    
    let expectation = Trie([[1, 2, 3], [2, 3, 4], [3, 4, 5], [3, 4, 6]])
    
    XCTAssertEqual(frst.union(scnd), expectation)
    
  }
  
  func testSubtract() {
    
    let expectation = Trie([[1, 2, 3], [3, 4, 5]])
    
    let reality = Trie([[1, 2, 3], [2, 3, 4], [3, 4, 5], [3, 4, 6]]).subtract([[2, 3, 4], [3, 4, 6]])
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testMap() {
    
    let expectation = Trie([[2, 4, 6], [6, 8, 10], [4, 6, 8]])
    let reality = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]]).map { $0.map { $0 * 2 } }
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testFlatMap() {
    
    let expectation = Trie([[1, 2, 3], [2, 3, 4], [3, 4, 5]])
    
    let reality = Trie([[1, 2, 3], [2, 3, 4]]).flatMap {
      seq in Trie([0, 1].map { num in seq.map { $0 + num } })
    }
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  let isOdd: Int -> Bool = { $0 % 2 == 1 }

  func testFlatMapOpt() {
    
    let expectation = Trie([[2, 4, 6], [6, 8, 10]])
    
    let reality = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]]).flatMap {
      $0.first.map(isOdd) == true ? $0.map { $0 * 2 } : nil
    }
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testFilter() {
    
    let expectation = Trie([[1, 2, 3], [3, 4, 5]])
    
    let reality = Trie([[1, 2, 3], [2, 3, 4], [3, 4, 5]]).filter {
      $0.first.map(isOdd) == true
    }
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testCount() {
    
    let expectation = 3
    
    let reality = Trie([[1, 2, 3], [2, 3, 4], [3, 4, 5]]).count
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testSeqType() {
    
    let seqs = (1...10).map { n in (0..<n).map { _ in Int(arc4random_uniform(1000)) } }
    
    let expectation = Set(seqs.map { $0.debugDescription })
    
    let reality = Set(Trie(seqs).map { $0.debugDescription })
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  
}