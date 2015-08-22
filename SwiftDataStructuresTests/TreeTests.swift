//import XCTest
//import Foundation
//@testable import SwiftDataStructures
//
//class TreeTests: XCTestCase {
//  
//  func testEmptyInit() {
//    
//    let empty = Tree<Int>()
//    
//    XCTAssert(empty.isEmpty)
//    
//    XCTAssert(empty.isBalanced)
//    
//  }
//  
//  func testSeqInit() {
//    
//    let seq = (0...100).map { _ in arc4random_uniform(100) }
//    
//    let set = Set(seq)
//    
//    let tree = Tree(seq)
//    
//    let setFromTree = Set(tree)
//    
//    XCTAssertEqual(set, setFromTree)
//    
//    XCTAssert(tree.isBalanced)
//    
//  }
//  
//  func testArrayLiteralInit() {
//    
//    let tree: Tree = [1, 3, 5, 6, 7, 8, 9]
//    
//    XCTAssert(tree.elementsEqual([1, 3, 5, 6, 7, 8, 9]))
//    
//    XCTAssert(tree.isBalanced)
//    
//  }
//  
//  func testDebugDescription() {
//    
//    let seq = (0...100).map { _ in arc4random_uniform(100) }
//    
//    let arr = Set(seq).sort()
//    
//    let tre = Tree(seq)
//    
//    XCTAssertEqual(arr.debugDescription, tre.debugDescription)
//    
//    XCTAssert(tre.isBalanced)
//    
//  }
//  
//  func testFirst() {
//    
//    let seq = (0...100).map { _ in arc4random_uniform(100) }
//    
//    let set = Set(seq)
//    
//    let tre = Tree(seq)
//    
//    XCTAssertEqual(set.minElement(), tre.first)
//    
//    XCTAssert(tre.isBalanced)
//    
//  }
//  
//  func testLast() {
//    
//    let seq = (0...100).map { _ in arc4random_uniform(100) }
//    
//    let set = Set(seq)
//    
//    let tre = Tree(seq)
//    
//    XCTAssertEqual(set.maxElement(), tre.last)
//    
//    XCTAssert(tre.isBalanced)
//    
//  }
//  
//  func testIsEmpty() {
//    
//    let seq = (0...10).map { _ in arc4random_uniform(100) }
//    
//    XCTAssertFalse(Tree(seq).isEmpty)
//    
//    XCTAssert(Tree(seq).isBalanced)
//    
//  }
//  
//  func testCount() {
//    
//    let seq = (0...1000).map { _ in arc4random_uniform(100) }
//    
//    let tre = Tree(seq)
//    
//    XCTAssertEqual(Set(seq).count, tre.count)
//    
//    XCTAssert(tre.isBalanced)
//    
//  }
//  
//  func testContains() {
//    
//    let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let set = Set(seq)
//    
//    let tre = Tree(seq)
//    
//    for i in 0...110 {
//      XCTAssertEqual(set.contains(i), tre.contains(i))
//      
//      XCTAssert(tre.isBalanced)
//    }
//  }
//  
//  func testRemoveMin() {
//    
//    let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var set = Set(seq)
//    
//    var tre = Tree(seq)
//    
//    for _ in 0...110 {
//      XCTAssertEqual(set.minElement().flatMap { set.remove($0) }, tre.removeMin())
//      
//      XCTAssert(tre.isBalanced)
//    }
//  }
//  
//  func testRemoveMax() {
//    
//    let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var set = Set(seq)
//    
//    var tre = Tree(seq)
//    
//    for _ in 0...110 {
//      
//      XCTAssertEqual(set.maxElement().flatMap { set.remove($0) }, tre.removeMax())
//      
//      XCTAssert(tre.isBalanced)
//    }
//  }
//  
//  func testRemove() {
//    
//    let seq = (0...100).map { _ in arc4random_uniform(100) }
//    
//    var set = Set(seq)
//    
//    var tre = Tree(seq)
//    
//    for _ in 0...10000 {
//      
//      let i = arc4random_uniform(110)
//      
//      XCTAssertEqual(set.remove(i), tre.remove(i))
//      
//      XCTAssert(tre.isBalanced)
//    }
//  }
//  
//  func testReverse() {
//    
//    let seq = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sorted = Set(seq).sort(>)
//    
//    let tree = Tree(seq)
//    
//    XCTAssert(sorted.elementsEqual(tree.reverse()))
//    
//  }
//  
//  func testExclusiveOr() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let set = Set(fst)
//    
//    let tre = Tree(fst)
//    
//    let treeOr = tre.exclusiveOr(sec)
//    
//    let setOr = set.exclusiveOr(sec).sort()
//    
//    XCTAssert(treeOr.isBalanced)
//    
//    XCTAssert(treeOr.elementsEqual(setOr))
//    
//  }
//  
//  func testExclusiveOrInPlace() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var set = Set(fst)
//    
//    var tre = Tree(fst)
//    
//    tre.exclusiveOrInPlace(sec)
//    
//    set.exclusiveOrInPlace(sec)
//    
//    let setOr = set.sort()
//    
//    XCTAssert(tre.isBalanced)
//    
//    XCTAssert(tre.elementsEqual(setOr))
//    
//  }
//  
//  func testIntersect() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let set = Set(fst)
//    
//    let tre = Tree(fst)
//    
//    let treeIn = tre.intersect(sec)
//    
//    let setIn = set.intersect(sec).sort()
//    
//    XCTAssert(treeIn.isBalanced)
//    
//    XCTAssert(treeIn.elementsEqual(setIn))
//  
//  }
//  
//  func testIntersectInPlace() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var set = Set(fst)
//    
//    var tre = Tree(fst)
//    
//    tre.intersectInPlace(sec)
//    
//    set.intersectInPlace(sec)
//    
//    let setOr = set.sort()
//    
//    XCTAssert(tre.isBalanced)
//    
//    XCTAssert(tre.elementsEqual(setOr))
//    
//  }
//  
//  func testDisjoint() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let withoutSec = Set(fst).subtract(sec)
//    
//    let tree = Tree(withoutSec)
//    
//    XCTAssert(tree.isDisjointWith(sec))
//    
//    XCTAssert(tree.isBalanced)
//    
//  }
//  
//  func testSuperset() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let with = Set(fst).union(sec)
//    
//    let tree = Tree(with)
//    
//    XCTAssert(tree.isSupersetOf(sec))
//    
//    XCTAssert(tree.isBalanced)
//    
//  }
//  
//  func testSubset() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let with = Set(fst).union(sec)
//    
//    let tree = Tree(fst)
//    
//    XCTAssert(tree.isSubsetOf(with))
//    
//    XCTAssert(tree.isBalanced)
//    
//  }
//  
//  func testSubtract() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let withoutSec = Set(fst).subtract(sec)
//    
//    let withoutTre = Tree(fst).subtract(sec)
//    
//    XCTAssert(withoutSec.sort().elementsEqual(withoutTre))
//    
//    XCTAssert(withoutTre.isBalanced)
//
//  }
//  
//  func testSubtractInPlace() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var withoutSec = Set(fst)
//    
//    withoutSec.subtractInPlace(sec)
//    
//    var withoutTre = Tree(fst)
//    
//    withoutTre.subtractInPlace(sec)
//    
//    XCTAssert(withoutSec.sort().elementsEqual(withoutTre))
//    
//    XCTAssert(withoutTre.isBalanced)
//    
//  }
//  
//  func testUnion() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let unionSet = Set(fst).union(sec)
//    
//    let unionTre = Tree(fst).union(sec)
//    
//    XCTAssert(unionSet.sort().elementsEqual(unionTre))
//    
//    XCTAssert(unionTre.isBalanced)
//  }
//  
//  func testUnionInPlace() {
//    
//    let fst = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    let sec = (0...100).map { _ in Int(arc4random_uniform(100)) }
//    
//    var unionSet = Set(fst)
//    
//    unionSet.unionInPlace(sec)
//    
//    var unionTre = Tree(fst)
//    
//    unionTre.unionInPlace(sec)
//    
//    XCTAssert(unionSet.sort().elementsEqual(unionTre))
//    
//    XCTAssert(unionTre.isBalanced)
//  }
//  
//}
