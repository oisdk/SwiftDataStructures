import XCTest
import Foundation
@testable import SwiftDataStructures

class ContiguousListIndexTests: XCTestCase {
  
  func testIndex() {
    
    let x = ContiguousListIndex(Int(arc4random_uniform(10000)))
        
    XCTAssert(x.distanceTo(x.successor()) == 1)
    
    XCTAssert(x.distanceTo(x.predecessor()) == -1)
    
    let y = ContiguousListIndex(Int(arc4random_uniform(10000)))
    
    XCTAssert(x.advancedBy(x.distanceTo(y)) == y)
    
    XCTAssert(x == x)
    
    XCTAssert(x.successor() > x)
    
    XCTAssert(x.predecessor() < x)
    
    XCTAssert(x.advancedBy(0) == x)
    
    XCTAssert(x.advancedBy(1) == x.successor())
    
    XCTAssert(x.advancedBy(-1) == x.predecessor())
    
    let m = Int(arc4random_uniform(10000)) - 5000
    
    XCTAssert(x.distanceTo(x.advancedBy(m)) == m)
    
  }
  
}