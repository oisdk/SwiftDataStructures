import XCTest
@testable import SwiftDataStructures

class LazyListTests: XCTestCase {
  
  func testDebugDescription() {
    
    let expectation = "[1, 2, 3]"
    
    let reality =
    LazyList.Cons(1, {LazyList.Cons(2, {LazyList.Cons(3, {LazyList.Nil})})})
      .debugDescription
    
    XCTAssert(expectation == reality)
    
  }
  
  func testOperator() {
    
    let expectation = LazyList.Cons(1, {LazyList.Cons(2, {LazyList.Cons(3, {LazyList.Nil})})})
    
    let reality: LazyList = 1 |> 2 |> 3 |> .Nil
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSeqInit() {
    
    let expectation = LazyList.Cons(1, {LazyList.Cons(2, {LazyList.Cons(3, {LazyList.Nil})})})

    
    let reality = LazyList([1, 2, 3])
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmptySeqInit() {
    
    let expectation: LazyList<Int> = .Nil
    
    let reality = LazyList<Int>([])
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = LazyList.Cons(1, {LazyList.Cons(2, {LazyList.Cons(3, {LazyList.Nil})})})
    
    let reality: LazyList = [1, 2, 3]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmptyArrayLiteralConvertible() {
    
    let expectation: LazyList<Int> = .Nil
    
    let reality: LazyList<Int> = []
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSequenceType() {
    
    let expectation = [1, 2, 3]
    
    let reality = Array(LazyList([1, 2, 3]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }  
  
  func testAppended() {
    
    let expectation = [1, 2, 3, 0]
    
    let reality = LazyList([1, 2, 3]).appended(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testExtended() {
    
    let expectation = [1, 2, 3, 0, 1]
    
    let reality = LazyList([1, 2, 3]).extended(Array([0, 1]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDrop() {
    
    let expectation = [3, 4, 5]
    
    let reality = LazyList([1, 2, 3, 4, 5]).dropFirst(2)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDropAll() {
    
    let expectation: [Int] = []
    
    let reality = LazyList([1, 2, 3, 4, 5]).dropFirst(5)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTake() {
    
    let expectation = [1, 2, 3]
    
    let reality = LazyList([1, 2, 3, 4, 5]).prefix(3)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTakeAll() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality = LazyList([1, 2, 3, 4, 5]).prefix(7)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmpty() {
    
    let empty: LazyList<Int> = []
    
    let nonEmpty: LazyList = [1, 2, 3]
    
    XCTAssert(empty.isEmpty)
    XCTAssert(!nonEmpty.isEmpty)
    
  }
  
  func testFirst() {
    
    let expectation = 1
    
    let reality = LazyList([1, 2, 3]).first
    
    XCTAssert(expectation == reality)
    
  }
  
  func testLast() {
    
    let expectation = 3
    
    let reality = LazyList([1, 2, 3]).last
    
    XCTAssert(expectation == reality)
    
  }
  
  func testMap() {
    
    let expectation = [2, 4, 6]
    
    let reality = LazyList([1, 2, 3]).map { $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMap() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let before: LazyList = [1, 2, 3]
    
    let reality = before.flatMap { Array([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMapLazyList() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let reality = LazyList([1, 2, 3]).flatMap { LazyList([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMapOpt() {
    
    let expectation = [1, 3]
    
    let reality = LazyList([1, 2, 3]).flatMap { $0 % 2 == 0 ? nil : $0 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTail() {
    
    let expectation = [2, 3]
    
    let reality = LazyList([1, 2, 3]).dropFirst()
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testRemoveFirst() {
    
    let expectation = [2, 3]
    
    var reality = LazyList([1, 2, 3])
    
    XCTAssert(reality.removeFirst() == 1)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFilter() {
    
    let expectation = [2, 4, 6, 8]
    
    let reality = LazyList(1..<9).filter { $0 % 2 == 0 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testReverse() {
    
    let expectation = [5, 4, 3, 2, 1]
    
    let reality = LazyList(1...5).reverse()
    
    XCTAssert(expectation.elementsEqual(reality))
  }
}