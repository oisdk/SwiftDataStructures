import XCTest
@testable import SwiftDataStructures
import Foundation

private func randArs() -> [[Int]] {
  return (0...10).map {
    (0..<$0).map {
      _ in Int(arc4random_uniform(UInt32.max))
    }
  }
}

class DequeTests: XCTestCase {
  
  func testEmptyInit() {
    
    let _ = Deque<Int>()
    
    let _ = DequeSlice<Int>()
    
  }
  
  func testSeqInit() {
    
    for randAr in randArs() {
      let jo = Deque(randAr)
      
      let an = DequeSlice(randAr)
      
      XCTAssert(jo.elementsEqual(randAr))
      
      XCTAssert(an.elementsEqual(randAr))
      
      XCTAssert(jo.isBalanced)
      
      XCTAssert(an.isBalanced)
    }
    
  }
  
  func testIndInit() {
    
    for randAr in randArs() {
      
      let jo = Deque(randAr)
      
      let an = DequeSlice(randAr)
      
      XCTAssertEqual(jo.endIndex, randAr.endIndex)
      XCTAssertEqual(an.endIndex, randAr.endIndex)
      
      XCTAssert(jo.isBalanced)
      
      XCTAssert(an.isBalanced)
      
      for i in randAr.indices {
        
        XCTAssertEqual(jo[i], randAr[i])
        XCTAssertEqual(an[i], randAr[i])
        
      }
    }
    
  }
  
  func testRangeInds() {
    
    
    let randAr = (1...10).map { _ in arc4random_uniform(UInt32.max) }
    
    let jo = Deque(randAr)
    
    let an = DequeSlice(randAr)
    
    for i in randAr.indices {
      
      for j in (i...randAr.endIndex) {
        
        let r = i..<j
        
        let arSlice = randAr[r]
        
        let joSlice = jo[r]
        
        let anSlice = an[r]
        
        XCTAssert(arSlice.elementsEqual(joSlice), "\n" + arSlice.debugDescription + " " + Array(joSlice).debugDescription + "\n" + randAr.debugDescription + "\n" + i.description + ", " + j.description)
        
        XCTAssert(arSlice.elementsEqual(anSlice), "\n" + arSlice.debugDescription + " " + Array(joSlice).debugDescription + "\n" + randAr.debugDescription + "\n" + i.description + ", " + j.description)
        
        XCTAssert(joSlice.isBalanced)
        
        XCTAssert(anSlice.isBalanced)
        
      }
    }
  }
  
  func testArrayLiteralConvertible() {
    
    let de: Deque = [1, 2, 3, 4, 5, 6]
    
    let ar = [1, 2, 3, 4, 5, 6]
    
    XCTAssert(de.elementsEqual(ar))
    
  }
  
  func testIndMut() {
    
    for var randAr in randArs().dropFirst() {
      
      var de = Deque(randAr)
      
      let i = Int(arc4random_uniform(UInt32(randAr.count)))
      
      let n = Int(arc4random_uniform(100000))
      
      randAr[i] = n
      
      de[i] = n
      
      XCTAssert(randAr.elementsEqual(de))
    }
  }
  
  func testDebugDesc() {
    
    let expectation = "[1, 2, 3 | 4, 5, 6, 7]"
    
    let reality = Deque([1, 2, 3, 4, 5, 6, 7]).debugDescription
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testRangeIndsSet() {
    
    let randAr = (1...10).map { _ in arc4random_uniform(UInt32.max) }
    
    for i in randAr.indices {
      
      for j in (i...randAr.endIndex) {
        
        let r = i..<j
        
        let replace = r.map { _ in arc4random_uniform(UInt32.max) }
        
        var mutAr = randAr
        
        var de = Deque(randAr)
        
        mutAr[r] = ArraySlice(replace)
        
        de[r] = DequeSlice(replace)
        
        XCTAssert(mutAr.elementsEqual(de))
        
      }
    }
  }
  
  func testReplaceRange() {
    
    for ar in randArs() {
      let replacement = (0..<arc4random_uniform(6)).map { _ in Int(arc4random_uniform(10000)) }
      for start in ar.indices {
        for end in (start...ar.endIndex) {
          var array = ar
          var deque = Deque(array)
          array.replaceRange(start..<end, with: replacement)
          deque.replaceRange(start..<end, with: replacement)
          XCTAssertTrue(array.elementsEqual(deque), "\n" + array.debugDescription + " != " + deque.debugDescription + "\n" + replacement.debugDescription)
          XCTAssertTrue(deque.isBalanced)
        }
      }
    }
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
