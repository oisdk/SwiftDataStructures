//import XCTest
//import Foundation
//@testable import SwiftDataStructures
//
//internal func makeDequeSliceTuple<S : SequenceType>(from: S) -> (S, DequeSlice<S.Generator.Element>) {
//  return (from, DequeSlice(from))
//}
//
//internal func makeDequeSliceTuple<T>(from: [T]) -> ([T], DequeSlice<T>) {
//  return (from, DequeSlice(array: from))
//}
//
//class DequeSliceTests: XCTestCase {
//  
//  func testDebugDesciption() {
//    
//    let expectation = "[1, 2 | 3, 4, 5]"
//    
//    let reality = DequeSlice([1, 2, 3, 4, 5]).debugDescription
//    
//    XCTAssertEqual(expectation, reality)
//  }
//  
//  func testBalance() {
//    
//    var frontEmpty = DequeSlice(
//      balancedF: [],
//      balancedB: [1, 2, 3]
//    )
//    
//    XCTAssertTrue(frontEmpty.balance == .FrontEmpty)
//    frontEmpty.check()
//    XCTAssertTrue(frontEmpty.isBalanced)
//    
//    var backEmpty = DequeSlice(
//      balancedF: [1, 2, 3],
//      balancedB: []
//    )
//    
//    XCTAssertTrue(backEmpty.balance == .BackEmpty)
//    backEmpty.check()
//    XCTAssertTrue(backEmpty.isBalanced)
//    
//    let bothEmpty = DequeSlice<Int>(
//      balancedF: [],
//      balancedB: []
//    )
//    
//    XCTAssertTrue(bothEmpty.isBalanced)
//    
//    let oneBackEmpty = DequeSlice(
//      balancedF: [1],
//      balancedB: []
//    )
//    
//    XCTAssertTrue(oneBackEmpty.isBalanced)
//    
//    let oneFrontEmpty = DequeSlice(
//      balancedF: [],
//      balancedB: [1]
//    )
//    
//    XCTAssertTrue(oneFrontEmpty.isBalanced)
//    
//    let selfBalanceBack  = DequeSlice([1, 2, 3], [])
//    
//    XCTAssertTrue(selfBalanceBack.isBalanced)
//    
//    let selfBalanceFront = DequeSlice([], [1, 2, 3])
//    
//    XCTAssertTrue(selfBalanceFront.isBalanced)
//    
//  }
//  
//  func testArrayLiteralConvertible() {
//    
//    let expectation = [2, 3, 4, 5, 6]
//    
//    let reality: DequeSlice = [2, 3, 4, 5, 6]
//    
//    XCTAssertTrue(expectation.elementsEqual(reality))
//    
//  }
//  
//  func testArrayInit() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//    
//  }
//  
//  func testContigSliceInit() {
//    (0...10)
//      .map(randomArray)
//      .map(Deque.init)
//      .map(makeDequeSliceTuple)
//      .forEach {
//        (a, b) in
//        XCTAssertTrue(a.front.elementsEqual(b.front))
//        XCTAssertTrue(a.back.elementsEqual(b.back))
//        XCTAssertTrue(a.isBalanced)
//    }
//  }
//  
//  func testDropFirst() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .map{ (ar, de) in (ar.dropFirst(), de.dropFirst()) }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//    
//  }
//  
//  func testDropFirstN() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in (0...20).map { (ar.dropFirst($0), de.dropFirst($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testDropLast() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .map { ($0.0.dropLast(), $0.1.dropLast()) }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testDropLastN() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in (0...20).map { (ar.dropLast($0), de.dropLast($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testPrefix() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in (0...20).map { (ar.prefix($0), de.prefix($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testPrefixUpTo() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in ar.indices.map { (ar.prefixUpTo($0), de.prefixUpTo($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testPrefixThrough() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in
//        ar.indices
//          .dropLast()
//          .map { (ar.prefixThrough($0), de.prefixThrough($0)) }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  
//  func testSuffix() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in (0...20).map { (ar.suffix($0), de.suffix($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testSuffixFrom() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in ar.indices.map { (ar.suffixFrom($0), de.suffixFrom($0)) } }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testSplit() {
//    
//    let maxSplits = (0...20)
//    let splitFuncs = (1...10).map { n -> (Int -> Bool) in { $0 % n == 0 } }
//    let allows = [true, false]
//    let arrays = (0...10).map { (a: Int) -> [Int] in
//      (0..<a).map { _ in Int(arc4random_uniform(100)) }
//    }
//    let deques = arrays.map{DequeSlice($0)}
//    for (array, deque) in zip(arrays, deques) {
//      for maxSplit in maxSplits {
//        for splitFunc in splitFuncs {
//          for allow in allows {
//            let dequeSplit = deque.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
//            let araySplit = array.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
//            for (a, b) in zip(dequeSplit, araySplit) {
//              XCTAssertTrue(a.elementsEqual(b), a.debugDescription + " " + b.debugDescription)
//            }
//          }
//        }
//      }
//    }
//  }
//  
//  func testIndexing() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertEqual(ar.startIndex, de.startIndex)
//        XCTAssertEqual(ar.endIndex, de.endIndex)
//        ar.indices
//          .forEach { i in
//            XCTAssertTrue(ar[i] == de[i])
//            var (array, deque) = (ar, de)
//            let n = Int(arc4random_uniform(10000))
//            (array[i], deque[i]) = (n, n)
//            XCTAssertTrue(array.elementsEqual(deque))
//        }
//    }
//  }
//  
//  func testCount() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertEqual(ar.count, de.count)
//    }
//  }
//  
//  func testFirst() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.first == de.first)
//    }
//  }
//  
//  func testLast() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.last == de.last)
//    }
//  }
//  
//  func testIsEmpty() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertEqual(ar.isEmpty, de.isEmpty)
//    }
//  }
//  
//  func testPopLast() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (var ar, var de) in
//        while let deqEl = de.popLast() {
//          XCTAssertTrue(ar.popLast() == deqEl)
//          XCTAssertTrue(ar.elementsEqual(de))
//          XCTAssertTrue(de.isBalanced)
//        }
//    }
//  }
//  
//  func testPopFirst() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (var ar, var de) in
//        while let deqEl = de.popFirst() {
//          XCTAssertTrue(ar.popFirst() == deqEl)
//          XCTAssertTrue(ar.elementsEqual(de))
//          XCTAssertTrue(de.isBalanced)
//        }
//    }
//  }
//  
//  func testReverse() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .map { (ar, de) in (ar.reverse(), de.reverse()) }
//      .forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testIndsRange() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in
//        ar.indices.flatMap { start in
//          (start...ar.endIndex).map { end in
//            (ar[start..<end], de[start..<end])
//          }
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testIndsRangeSet() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        ar.indices.forEach { start in
//          (start...ar.endIndex).forEach { end in
//            var array: [Int] = ar
//            var deque: DequeSlice<Int> = de
//            let replacement = randomArray(end - start)
//            array[start..<end] = ArraySlice(replacement)
//            deque[start..<end] = DequeSlice(replacement)
//            XCTAssertTrue(array.elementsEqual(deque))
//            XCTAssertTrue(deque.isBalanced)
//          }
//        }
//    }
//  }
//  
//  func testEmptyInit() {
//    
//    XCTAssertTrue(DequeSlice<Int>().isEmpty)
//    
//  }
//  
//  func testAppend() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in
//        (0...10).map { (n: Int) -> ([Int], DequeSlice<Int>) in
//          var (array, deque) = (ar, de)
//          for _ in 0..<n {
//            let x = Int(arc4random_uniform(UInt32.max))
//            array.append(x)
//            deque.append(x)
//          }
//          return (array, deque)
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testExtend() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar, de) in
//        (0...10).map { (n: Int) -> ([Int], DequeSlice<Int>) in
//          var (array, deque) = (ar, de)
//          for _ in 0..<n {
//            let x = randomArray(Int(arc4random_uniform(8)))
//            array.extend(x)
//            deque.extend(x)
//          }
//          return (array, deque)
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testInsert() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar: [Int], de: DequeSlice<Int>) in
//        (0...ar.endIndex).map { (i: Int) -> ([Int], DequeSlice<Int>) in
//          var array: [Int] = ar
//          var deque: DequeSlice<Int> = de
//          let x = Int(arc4random_uniform(UInt32.max))
//          array.insert(x, atIndex: i)
//          deque.insert(x, atIndex: i)
//          return (array, deque)
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testPrepend() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar: [Int], de: DequeSlice<Int>) in
//        (0...10).map { (n: Int) -> ([Int], DequeSlice<Int>) in
//          var (array, deque) = (ar, de)
//          for _ in 0..<n {
//            let x = Int(arc4random_uniform(UInt32.max))
//            array = [x] + array
//            deque.prepend(x)
//          }
//          return (array, deque)
//        }
//      }.forEach { (ar: [Int], de: DequeSlice<Int>) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testPrextend() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar: [Int], de: DequeSlice<Int>) in
//        (0...10).map { i in
//          var (array, deque) = (ar, de)
//          let x = randomArray(i)
//          array = x + array
//          deque.prextend(x)
//          return (array, deque)
//        }
//      }.forEach { (ar: [Int], de: DequeSlice<Int>) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testRemoveAll() {
//    var deque = DequeSlice(randomArray(8))
//    deque.removeAll()
//    XCTAssertTrue(deque.isEmpty)
//  }
//  
//  func testRemove() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        XCTAssertEqual(ar.startIndex, de.startIndex)
//        XCTAssertEqual(ar.endIndex, de.endIndex)
//        ar.indices
//          .forEach { i in
//            var (array, deque) = (ar, de)
//            XCTAssertEqual(array.removeAtIndex(i), deque.removeAtIndex(i))
//            XCTAssertTrue(array.elementsEqual(deque))
//            XCTAssertTrue(deque.isBalanced)
//        }
//    }
//  }
//  
//  func testRemoveFirst() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (var ar, var de) in
//        while !de.isEmpty {
//          XCTAssertEqual(ar.removeFirst(), de.removeFirst())
//          XCTAssertTrue(ar.elementsEqual(de))
//          XCTAssertTrue(de.isBalanced)
//        }
//    }
//  }
//  
//  func testRemoveLast() {
//    
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (var ar, var de) in
//        while !de.isEmpty {
//          XCTAssertEqual(ar.removeLast(), de.removeLast())
//          XCTAssertTrue(ar.elementsEqual(de))
//          XCTAssertTrue(de.isBalanced)
//        }
//    }
//  }
//  
//  func testRemoveFirstN() {
//    
//    (1...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar: [Int], de: DequeSlice<Int>) in
//        (0...ar.endIndex).map { (n: Int) -> ([Int], DequeSlice<Int>) in
//          var (array, deque) = (ar, de)
//          array.removeFirst(n)
//          deque.removeFirst(n)
//          return (array, deque)
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de))
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testRemoveLastN() {
//    
//    (1...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .flatMap { (ar: [Int], de: DequeSlice<Int>) in
//        (0...ar.endIndex).map { (n: Int) -> ([Int], DequeSlice<Int>) in
//          var (array, deque) = (ar, de)
//          array.removeRange((ar.endIndex - n)..<ar.endIndex)
//          deque.removeLast(n)
//          return (array, deque)
//        }
//      }.forEach { (ar, de) in
//        XCTAssertTrue(ar.elementsEqual(de), ar.debugDescription + " != " + de.debugDescription)
//        XCTAssertTrue(de.isBalanced)
//    }
//  }
//  
//  func testRemoveRange() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        ar.indices.forEach { start in
//          (start...ar.endIndex).forEach { end in
//            var array: [Int] = ar
//            var deque: DequeSlice<Int> = de
//            array.removeRange(start..<end)
//            deque.removeRange(start..<end)
//            XCTAssertTrue(array.elementsEqual(deque), array.debugDescription + " != " + deque.debugDescription)
//            XCTAssertTrue(deque.isBalanced)
//          }
//        }
//    }
//  }
//  
//  func testReplaceRange() {
//    (0...10)
//      .map(randomArray)
//      .map(makeDequeSliceTuple)
//      .forEach { (ar, de) in
//        ar.indices.forEach { start in
//          (start...ar.endIndex).forEach { end in
//            var array: [Int] = ar
//            var deque: DequeSlice<Int> = de
//            let replacement = randomArray(Int(arc4random_uniform(20)))
//            array.replaceRange(start..<end, with: replacement)
//            deque.replaceRange(start..<end, with: replacement)
//            XCTAssertTrue(array.elementsEqual(deque), array.debugDescription + " != " + deque.debugDescription)
//            XCTAssertTrue(deque.isBalanced)
//          }
//        }
//    }
//  }
//  
//  func testReserveCapacity() {
//    var d = DequeSlice<Int>()
//    d.reserveCapacity(20)
//  }
//}
