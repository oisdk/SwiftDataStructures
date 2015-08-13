import XCTest
import Foundation
@testable import SwiftDataStructures

internal func makeDequeSliceTuple<S : SequenceType>(from: S) -> (S, ContiguousDequeSlice<S.Generator.Element>) {
  return (from, ContiguousDequeSlice(from))
}

internal func makeDequeSliceTuple<T>(from: [T]) -> ([T], ContiguousDequeSlice<T>) {
  return (from, ContiguousDequeSlice(array: from))
}

class ContiguousDequeSliceTests: XCTestCase {
  
  func testDebugDesciption() {
    
    let expectation = "[1, 2 | 3, 4, 5]"
    
    let reality = ContiguousDequeSlice([1, 2, 3, 4, 5]).debugDescription
    
    XCTAssert(expectation == reality)
    
  }
  
  func testBalance() {
    
    var frontEmpty = ContiguousDequeSlice(
      balancedF: [],
      balancedB: [1, 2, 3]
    )
    
    XCTAssert(frontEmpty.balance == .FrontEmpty)
    frontEmpty.check()
    XCTAssert(frontEmpty.isBalanced)
    
    var backEmpty = ContiguousDequeSlice(
      balancedF: [1, 2, 3],
      balancedB: []
    )
    
    XCTAssert(backEmpty.balance == .BackEmpty)
    backEmpty.check()
    XCTAssert(backEmpty.isBalanced)
    
    let bothEmpty = ContiguousDequeSlice<Int>(
      balancedF: [],
      balancedB: []
    )
    
    XCTAssert(bothEmpty.isBalanced)
    
    let oneBackEmpty = ContiguousDequeSlice(
      balancedF: [1],
      balancedB: []
    )
    
    XCTAssert(oneBackEmpty.isBalanced)
    
    let oneFrontEmpty = ContiguousDequeSlice(
      balancedF: [],
      balancedB: [1]
    )
    
    XCTAssert(oneFrontEmpty.isBalanced)
    
    let selfBalanceBack  = ContiguousDequeSlice([1, 2, 3], [])
    
    XCTAssert(selfBalanceBack.isBalanced)
    
    let selfBalanceFront = ContiguousDequeSlice([], [1, 2, 3])
    
    XCTAssert(selfBalanceFront.isBalanced)
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [2, 3, 4, 5, 6]
    
    let reality: ContiguousDequeSlice = [2, 3, 4, 5, 6]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testArrayInit() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
    
  }
  
  func testContigSliceInit() {
    (0...10)
      .map(randomArray)
      .map(ContiguousDeque.init)
      .map(makeDequeSliceTuple)
      .forEach {
        (a, b) in
        XCTAssert(a.front.elementsEqual(b.front))
        XCTAssert(a.back.elementsEqual(b.back))
        XCTAssert(a.isBalanced)
    }
  }
  
  func testDropFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .map{ (ar, de) in (ar.dropFirst(), de.dropFirst()) }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
    
  }
  
  func testDropFirstN() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.dropFirst($0), de.dropFirst($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testDropLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .map { ($0.0.dropLast(), $0.1.dropLast()) }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testDropLastN() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.dropLast($0), de.dropLast($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testPrefix() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.prefix($0), de.prefix($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testPrefixUpTo() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in ar.indices.map { (ar.prefixUpTo($0), de.prefixUpTo($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testPrefixThrough() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in
        ar.indices
          .dropLast()
          .map { (ar.prefixThrough($0), de.prefixThrough($0)) }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  
  func testSuffix() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in (0...20).map { (ar.suffix($0), de.suffix($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testSuffixFrom() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in ar.indices.map { (ar.suffixFrom($0), de.suffixFrom($0)) } }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
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
    let deques = arrays.map{ContiguousDequeSlice($0)}
    for (array, deque) in zip(arrays, deques) {
      for maxSplit in maxSplits {
        for splitFunc in splitFuncs {
          for allow in allows {
            let dequeSplit = deque.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            let araySplit = array.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            for (a, b) in zip(dequeSplit, araySplit) {
              XCTAssert(a.elementsEqual(b), a.debugDescription + " " + b.debugDescription)
            }
          }
        }
      }
    }
  }
  
  func testIndexing() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.startIndex == de.startIndex)
        XCTAssert(ar.endIndex == de.endIndex)
        ar.indices
          .forEach { i in
            XCTAssert(ar[i] == de[i])
            var (array, deque) = (ar, de)
            let n = Int(arc4random_uniform(10000))
            (array[i], deque[i]) = (n, n)
            XCTAssert(array.elementsEqual(deque))
        }
    }
  }
  
  func testCount() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.count == de.count)
    }
  }
  
  func testFirst() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.first == de.first)
    }
  }
  
  func testLast() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.last == de.last)
    }
  }
  
  func testIsEmpty() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.isEmpty == de.isEmpty)
    }
  }
  
  func testPopLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (var ar, var de) in
        while let deqEl = de.popLast() {
          XCTAssert(ar.popLast() == deqEl)
          XCTAssert(ar.elementsEqual(de))
          XCTAssert(de.isBalanced)
        }
    }
  }
  
  func testPopFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (var ar, var de) in
        while let deqEl = de.popFirst() {
          XCTAssert(ar.popFirst() == deqEl)
          XCTAssert(ar.elementsEqual(de))
          XCTAssert(de.isBalanced)
        }
    }
  }
  
  func testReverse() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .map { (ar, de) in (ar.reverse(), de.reverse()) }
      .forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testIndsRange() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in
        ar.indices.flatMap { start in
          (start...ar.endIndex).map { end in
            (ar[start..<end], de[start..<end])
          }
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testIndsRangeSet() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var deque: ContiguousDequeSlice<Int> = de
            let replacement = randomArray(end - start)
            array[start..<end] = ArraySlice(replacement)
            deque[start..<end] = ContiguousDequeSlice(replacement)
            XCTAssert(array.elementsEqual(deque))
            XCTAssert(deque.isBalanced)
          }
        }
    }
  }
  
  func testEmptyInit() {
    
    XCTAssert(ContiguousDequeSlice<Int>().isEmpty)
    
  }
  
  func testAppend() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in
        (0...10).map { (n: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var (array, deque) = (ar, de)
          for _ in 0..<n {
            let x = Int(arc4random_uniform(UInt32.max))
            array.append(x)
            deque.append(x)
          }
          return (array, deque)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testExtend() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar, de) in
        (0...10).map { (n: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var (array, deque) = (ar, de)
          for _ in 0..<n {
            let x = randomArray(Int(arc4random_uniform(8)))
            array.extend(x)
            deque.extend(x)
          }
          return (array, deque)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testInsert() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        (0...ar.endIndex).map { (i: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var array: [Int] = ar
          var deque: ContiguousDequeSlice<Int> = de
          let x = Int(arc4random_uniform(UInt32.max))
          array.insert(x, atIndex: i)
          deque.insert(x, atIndex: i)
          return (array, deque)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testPrepend() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        (0...10).map { (n: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var (array, deque) = (ar, de)
          for _ in 0..<n {
            let x = Int(arc4random_uniform(UInt32.max))
            array = [x] + array
            deque.prepend(x)
          }
          return (array, deque)
        }
      }.forEach { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testPrextend() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        (0...10).map { i in
          var (array, deque) = (ar, de)
          let x = randomArray(i)
          array = x + array
          deque.prextend(x)
          return (array, deque)
        }
      }.forEach { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testRemoveAll() {
    var deque = ContiguousDequeSlice(randomArray(8))
    deque.removeAll()
    XCTAssert(deque.isEmpty)
  }
  
  func testRemove() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        XCTAssert(ar.startIndex == de.startIndex)
        XCTAssert(ar.endIndex == de.endIndex)
        ar.indices
          .forEach { i in
            var (array, deque) = (ar, de)
            XCTAssert(array.removeAtIndex(i) == deque.removeAtIndex(i))
            XCTAssert(array.elementsEqual(deque))
            XCTAssert(deque.isBalanced)
        }
    }
  }
  
  func testRemoveFirst() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (var ar, var de) in
        while !de.isEmpty {
          XCTAssert(ar.removeFirst() == de.removeFirst())
          XCTAssert(ar.elementsEqual(de))
          XCTAssert(de.isBalanced)
        }
    }
  }
  
  func testRemoveLast() {
    
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (var ar, var de) in
        while !de.isEmpty {
          XCTAssert(ar.removeLast() == de.removeLast())
          XCTAssert(ar.elementsEqual(de))
          XCTAssert(de.isBalanced)
        }
    }
  }
  
  func testRemoveFirstN() {
    
    (1...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        (0...ar.endIndex).map { (n: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var (array, deque) = (ar, de)
          array.removeFirst(n)
          deque.removeFirst(n)
          return (array, deque)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de))
        XCTAssert(de.isBalanced)
    }
  }
  
  func testRemoveLastN() {
    
    (1...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .flatMap { (ar: [Int], de: ContiguousDequeSlice<Int>) in
        (0...ar.endIndex).map { (n: Int) -> ([Int], ContiguousDequeSlice<Int>) in
          var (array, deque) = (ar, de)
          array.removeRange((ar.endIndex - n)..<ar.endIndex)
          deque.removeLast(n)
          return (array, deque)
        }
      }.forEach { (ar, de) in
        XCTAssert(ar.elementsEqual(de), ar.debugDescription + " != " + de.debugDescription)
        XCTAssert(de.isBalanced)
    }
  }
  
  func testRemoveRange() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var deque: ContiguousDequeSlice<Int> = de
            array.removeRange(start..<end)
            deque.removeRange(start..<end)
            XCTAssert(array.elementsEqual(deque), array.debugDescription + " != " + deque.debugDescription)
            XCTAssert(deque.isBalanced)
          }
        }
    }
  }
  
  func testReplaceRange() {
    (0...10)
      .map(randomArray)
      .map(makeDequeSliceTuple)
      .forEach { (ar, de) in
        ar.indices.forEach { start in
          (start...ar.endIndex).forEach { end in
            var array: [Int] = ar
            var deque: ContiguousDequeSlice<Int> = de
            let replacement = randomArray(Int(arc4random_uniform(20)))
            array.replaceRange(start..<end, with: replacement)
            deque.replaceRange(start..<end, with: replacement)
            XCTAssert(array.elementsEqual(deque), array.debugDescription + " != " + deque.debugDescription)
            XCTAssert(deque.isBalanced)
          }
        }
    }
  }
  
  func testReserveCapacity() {
    var d = ContiguousDequeSlice<Int>()
    d.reserveCapacity(20)
  }
}
