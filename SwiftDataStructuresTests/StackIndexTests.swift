//import XCTest
//import Foundation
//@testable import SwiftDataStructures
//
//class StackIndexTests: XCTestCase {
//  
//  func testIndex() {
//    
//    let x = StackIndex(Int(arc4random_uniform(10000)))
//        
//    XCTAssertEqual(x.distanceTo(x.successor()), 1)
//    
//    XCTAssertEqual(x.distanceTo(x.predecessor()), -1)
//    
//    let y = StackIndex(Int(arc4random_uniform(10000)))
//    
//    XCTAssertEqual(x.advancedBy(x.distanceTo(y)), y)
//    
//    XCTAssertEqual(x, x)
//    
//    XCTAssertGreaterThan(x.successor(), x)
//    
//    XCTAssertLessThan(x.predecessor(), x)
//    
//    XCTAssertEqual(x.advancedBy(0), x)
//    
//    XCTAssertEqual(x.advancedBy(1), x.successor())
//    
//    XCTAssertEqual(x.advancedBy(-1), x.predecessor())
//    
//    let m = Int(arc4random_uniform(10000)) - 5000
//    
//    XCTAssertEqual(x.distanceTo(x.advancedBy(m)), m)
//    
//  }
//  
//}