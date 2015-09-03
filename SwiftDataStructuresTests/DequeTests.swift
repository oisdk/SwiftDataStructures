import XCTest
@testable import SwiftDataStructures
import Foundation

extension Deque : SameOrder {}
extension DequeSlice : SameOrder {}
extension ContiguousDeque : SameOrder {}

extension Deque {
  var invariantPassed: Bool { return isBalanced }
}
extension DequeSlice {
  var invariantPassed: Bool { return isBalanced }
}
extension ContiguousDeque {
  var invariantPassed: Bool { return isBalanced }
}
class DequeTests: XCTestCase {
  
  func testProtocols() {
    Deque<Int>.test()
    DequeSlice<Int>.test()
    ContiguousDeque<Int>.test()
  }
  
  func testArrayLiteralConvertible() {
    
    let de: Deque = [1, 2, 3, 4, 5, 6]
    
    let ar = [1, 2, 3, 4, 5, 6]
    
    XCTAssert(de.elementsEqual(ar))
    
  }
  
  func testDebugDesc() {
    
    let expectation = "[1, 2, 3 | 4, 5, 6, 7]"
    
    let reality = Deque([1, 2, 3, 4, 5, 6, 7]).debugDescription
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testPopLast() {
    for var ar in randArs() {
      var de = Deque(ar)
      while let el = de.popLast() {
        XCTAssertEqual(el, ar.removeLast())
      }
    }
  }
  
  func testPopFirst() {
    for var ar in randArs() {
      var de = Deque(ar)
      while let el = de.popFirst() {
        XCTAssertEqual(el, ar.removeFirst())
        XCTAssert(de.isBalanced)
      }
      XCTAssert(de.isBalanced)
    }
  }
  
  func testReverse() {
    for ar in randArs() {
      let de = Deque(ar)
      XCTAssert(de.reverse().elementsEqual(ar.reverse()))
    }
  }
  
  func testRotateRight() {
    
    for ar in randArs() {
      
      var de = Deque(ar)
      
      de.rotateRight()
      
      XCTAssert(de.elementsEqual((ar.last.map { [$0] } ?? [] ) + ar.dropLast()))
      
      XCTAssert(de.isBalanced)
      
    }
  }
  
  func testRotateLeft() {
    
    for ar in randArs() {
      
      var de = Deque(ar)
      
      de.rotateLeft()
      
      XCTAssert(de.elementsEqual(ar.dropFirst() + (ar.first.map { [$0] } ?? [])))
      
      XCTAssert(de.isBalanced)
      
    }
  }
  
  func testRotateRightEl() {
    
    for ar in randArs() {
      
      let el = Int(arc4random_uniform(1008730))
      
      var de = Deque(ar)
      
      de.rotateRight(el)
      
      XCTAssert(de.elementsEqual([el] + ar.dropLast()))
      
      XCTAssert(de.isBalanced)
      
    }
  }
  
  func testRotateLeftEl() {
    
    for ar in randArs() {
      
      let el = Int(arc4random_uniform(1008730))
      
      var de = Deque(ar)
      
      de.rotateLeft(el)
      
      XCTAssert(de.elementsEqual(ar.dropFirst() + [el]))
      
      XCTAssert(de.isBalanced)
      
    }
  }
  
  func testPrepend() {
    
    
    for ar in randArs() {
      
      let el = Int(arc4random_uniform(1008730))
      
      var de = Deque(ar)
      
      de.prepend(el)
      
      XCTAssert(de.elementsEqual([el] + ar))
      
      XCTAssert(de.isBalanced)
      
    }
  }
  
  func testPrextend() {
    
    for ar in randArs() {
      
      for eAr in randArs() {
        
        var de = Deque(ar)
        
        let expect = eAr + ar
        
        de.prextend(eAr)
        
        XCTAssert(de.elementsEqual(expect))
        
        XCTAssert(de.isBalanced)
        
      }
    }
  }
  
  func testReserve() {
    
    var de: Deque = [1, 2, 3, 4]
    
    de.reserveCapacity(10)
    
  }
  
  func testUnderestCount() {
    for ar in randArs() {
      let de = Deque(ar)
      XCTAssertEqual(ar.underestimateCount(), de.underestimateCount())
    }
  }
}
