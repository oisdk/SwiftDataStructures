import XCTest
import Foundation
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
  
  func testCount() {
    
    let seq = 0..<Int(arc4random_uniform(30))
    
    let expectation = Array(seq)
    
    let reality = LazyList(seq)
    
    XCTAssert(expectation.count == reality.count)
    
    
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
  
  func testDropLast() {
    
    let seq = 0...Int(arc4random_uniform(30))

    let expectation = Array(seq).dropLast()
    
    let reality = LazyList(seq).dropLast()
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDropLastN() {
    
    let n = Int(arc4random_uniform(30))
    
    let seq = 0...n
    
    let drop = Int(arc4random_uniform(UInt32(n)))
    
    let expectation = Array(seq).dropLast(drop)
    
    let reality = LazyList(seq).dropLast(drop)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSuffixN() {
    
    let n = Int(arc4random_uniform(30))
    
    let seq = 0...n
    
    let drop = Int(arc4random_uniform(UInt32(n)))
    
    let expectation = Array(seq).suffix(drop)
    
    let reality = LazyList(seq).suffix(drop)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSplit() {
    
    let maxSplits = (0...20)
    let splitFuncs = (0...10).map {
      _ -> (Int -> Bool) in
      let n = Int(arc4random_uniform(5)) + 1
      return { $0 % n == 0 }
    }
    let allows = [true, false]
    let arrays = (0...10).map { (a: Int) -> [Int] in
      (0..<a).map { _ in Int(arc4random_uniform(100)) }
    }
    let lists = arrays.map{LazyList($0)}
    for (array, list) in zip(arrays, lists) {
      for maxSplit in maxSplits {
        for splitFunc in splitFuncs {
          for allow in allows {
            let listSplit = list.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            let araySplit = array.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            for (a, b) in zip(listSplit, araySplit) {
              XCTAssert(a.elementsEqual(b), a.debugDescription + " " + b.debugDescription)
            }
          }
        }
      }
    }
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