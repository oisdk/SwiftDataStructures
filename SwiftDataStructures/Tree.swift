/**
A [red-black binary search tree](https://en.wikipedia.org/wiki/Red–black_tree). Adapted
from Airspeed Velocity's [implementation](http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/),
Chris Okasaki's [Purely Functional Data Structures](http://www.cs.cmu.edu/~rwh/theses/okasaki.pdf),
and Stefan Kahrs' [Red-black trees with types](http://dl.acm.org/citation.cfm?id=968482),
which is implemented in the [Haskell standard library](https://hackage.haskell.org/package/llrbtree-0.1.1/docs/Data-Set-RBTree.html).

Elements must be comparable with [Strict total order](https://en.wikipedia.org/wiki/Total_order#Strict_total_order).
*/

public enum Tree<Element: Comparable> : SequenceType, ArrayLiteralConvertible, CustomDebugStringConvertible, Equatable {
  
  case Empty
  indirect case Node(Color,Tree<Element>,Element,Tree<Element>)
  
  // MARK: Initializers
  
  /// Create an empty `Tree`.
  
  public init() { self = .Empty }
  
  private init(_ x: Element, color: Color = .B, left: Tree<Element> = .Empty, right: Tree<Element> = .Empty) {
    self = .Node(color, left, x, right)
  }
  
  /// Create a `Tree` from a sequence
  
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init()
    for x in seq { insert(x) }
  }
  
  /// Create a `Tree` of `elements`
  
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
  
  // MARK: Instance Properties
  
  /// A description of `self`, suitable for debugging
  
  public var debugDescription: String {
    return Array(self).debugDescription
  }
  /**
  Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
  
  - Complexity: O(*log n*)
  */
  
  public var first: Element? {
    return minElement()
  }
  
  /**
  Returns the largest element in `self` if it's present, or `nil` if `self` is empty
  
  - Complexity: O(*log n*)
  */
  
  public var last: Element? {
    return maxElement()
  }
  
  /// Returns `true` iff `self` is empty
  
  public var isEmpty: Bool {
    switch self {
    case .Empty: return true
    case .Node: return false
    }
  }
  
  /**
  Returns the number of elements in `self`
  
  - Complexity: O(`count`)
  */
  
  public var count: Int {
    guard case let .Node(_, l, _, r) = self else { return 0 }
    return 1 + l.count + r.count
  }
  
  internal var isBalanced: Bool {
    switch balance {
    case .Balanced: return true
    case .UnBalanced: return false
    }
  }
  
  internal var balance: TreeBalance {
    guard case let .Node(c, l, _, r) = self else { return .Balanced(blackHeight: 1) }
    if case let .Node(_, _, lx, _) = l, case let .Node(_, _, rx, _) = r {
      guard lx < rx else { return .UnBalanced }
    }
    guard case let .Balanced(x) = l.balance else { return .UnBalanced }
    guard case let .Balanced(y) = r.balance else { return .UnBalanced }
    guard x == y else { return .UnBalanced }
    if c == .B { return .Balanced(blackHeight: x + 1) }
    if case .Node(.R, _, _, _) = l { return .UnBalanced }
    if case .Node(.R, _, _, _) = r { return .UnBalanced }
    return .Balanced(blackHeight: x)
  }
  
  // MARK: Instance Methods
  
  private func balanceL() -> Tree {
    switch self {
    case let .Node(.B, .Node(.R, .Node(.R, a, x, b), y, c), z, d):
      return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
    case let .Node(.B, .Node(.R, a, x, .Node(.R, b, y, c)), z, d):
      return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
    default:
      return self
    }
  }
  
  private func balanceR() -> Tree {
    switch self {
    case let .Node(.B, a, x, .Node(.R, .Node(.R, b, y, c), z, d)):
      return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
    case let .Node(.B, a, x, .Node(.R, b, y, .Node(.R, c, z, d))):
      return .Node(.R, .Node(.B,a,x,b),y,.Node(.B,c,z,d))
    default:
      return self
    }
  }
  
  private func cont(x: Element, _ p: Element?) -> Bool {
    guard case let .Node(_, l, y, r) = self else { return x == p }
    return x < y ? l.cont(x, p) : r.cont(x, y)
  }
  
  /**
  Returns `true` iff `self` contains `x`
  
  - Complexity: O(*log n*)
  */
  
  public func contains(x: Element) -> Bool {
    return cont(x, nil)
  }
  
  private func ins(x: Element) -> Tree {
    guard case let .Node(c, l, y, r) = self else { return Tree(x, color: .R) }
    if x < y { return Tree(y, color: c, left: l.ins(x), right: r).balanceL() }
    if y < x { return Tree(y, color: c, left: l, right: r.ins(x)).balanceR() }
    return self
  }
  
  /**
  Inserts `x` into `self`
  
  - Complexity: O(*log n*)
  */
  
  public mutating func insert(x: Element) {
    guard case let .Node(_, l, y, r) = ins(x) else { preconditionFailure() }
    self = .Node(.B, l, y, r)
  }
  
  /**
  Runs a `TreeGenerator` over the elements of `self`. (The elements are presented in order,
  from smallest to largest)
  */
  
  public func generate() -> TreeGenerator<Element> {
    guard case let .Node(_, l, e, r) = self else { return .Empty }
    return .Node(l.generate(), e, r)
  }
  
  /**
  Returns the smallest element in `self` if it's present, or `nil` if `self` is empty
  
  - Complexity: O(*log n*)
  */
  
  public func minElement() ->  Element? {
    switch self {
    case .Empty: return nil
    case .Node(_, .Empty, let e, _): return e
    case .Node(_, let l, _, _): return l.minElement()
    }
  }
  
  /**
  Returns the largest element in `self` if it's present, or `nil` if `self` is empty
  
  - Complexity: O(*log n*)
  */
  
  public func maxElement() -> Element? {
    switch self {
    case .Empty: return nil
    case .Node(_, _, let e, .Empty) : return e
    case .Node(_, _, _, let r): return r.maxElement()
    }
  }
  
  private func turnR() -> Tree {
    if case let .Node(_, l, x, r) = self { return .Node(.R, l, x, r) }
    preconditionFailure("Should not call turnR on an empty Tree")
  }
  
  private func turnB() -> Tree {
    if case let .Node(_, l, x, r) = self { return .Node(.B, l, x, r) }
    preconditionFailure("Should not call turnB on an empty Tree")
  }
  
  private func unbalancedR() -> (result: Tree, wasBlack: Bool) {
    guard case let .Node(c, l, x, r) = self else {
      preconditionFailure("Should not call unbalancedR on an empty Tree")
    }
    switch r {
    case let .Node(.B, rl, rx, rr):
      return (Tree.Node(.B, l, x, .Node(.R, rl, rx, rr)).balanceR(), c == .B)
    case let .Node(_, rl, rx, rr):
      return (Tree.Node(.B, Tree.Node(.B, l, x, rl.turnR()).balanceR(), rx, rr), false)
    default:
      preconditionFailure("Should not call unbalancedR with an empty right Tree")
    }
  }
  
  private func unbalancedL() -> (result: Tree, wasBlack: Bool) {
    guard case let .Node(c, l, x, r) = self else {
      preconditionFailure("Should not call unbalancedL on an empty Tree")
    }
    switch l {
    case let .Node(.B, ll, lx, lr):
      return (Tree.Node(.B, .Node(.R, ll, lx, lr), x, r).balanceL(), c == .B)
    case let .Node(_, ll, lx, lr):
      return (Tree.Node(.B, ll, lx, Tree.Node(.B, lr.turnR(), x, r).balanceL()), false)
    default:
      preconditionFailure("Should not call unbalancedL with an empty left Tree")
    }
  }
  
  private func _deleteMin() -> (Tree, Bool, Element) {
    switch self {
    case .Empty:
      preconditionFailure("Should not call _deleteMin on an empty Tree")
    case .Node(.B, .Empty, let x, .Empty):
      return (.Empty, true, x)
    case .Node(.B, .Empty, let x, let .Node(.R, rl, rx, rr)):
      return (.Node(.B, rl, rx, rr), false, x)
    case .Node(.R, .Empty, let x, let r):
      return (r, false, x)
    case let .Node(c, l, x, r):
      let (l0, d, m) = l._deleteMin()
      if d {
        let tD = Tree.Node(c, l0, x, r).unbalancedR()
        return (tD.0, tD.1, m)
      } else {
        return (Tree.Node(c, l0, x, r), false, m)
      }
    }
  }
  
  /**
  Removes the smallest element from `self` and returns it if it exists, or returns `nil`
  if `self` is empty.
  
  - Complexity: O(*log n*)
  */
  
  public mutating func removeMin() -> Element? {
    guard case .Node = self else { return nil }
    let (t, _, x) = _deleteMin()
    self = t
    return x
  }
  
  private func _deleteMax() -> (Tree, Bool, Element) {
    switch self {
    case .Empty:
      preconditionFailure("Should not call _deleteMax on an empty Tree")
    case let .Node(.B, .Empty, x, .Empty):
      return (.Empty, true, x)
    case let .Node(.B, .Node(.R, rl, rx, rr), x, .Empty):
      return (.Node(.B, rl, rx, rr), false, x)
    case let .Node(.R, l, x, .Empty):
      return (l, false, x)
    case let .Node(c, l, x, r):
      let (r0, d, m) = r._deleteMax()
      if d {
        let tD = Tree.Node(c, l, x, r0).unbalancedL()
        return (tD.0, tD.1, m)
      } else {
        return (.Node(c, l, x, r0), false, m)
      }
    }
  }
  
  /**
  Removes the largest element from `self` and returns it if it exists, or returns `nil`
  if `self` is empty.
  
  - Complexity: O(*log n*)
  */
  
  public mutating func removeMax() -> Element? {
    guard case .Node = self else { return nil }
    let (t, _, x) = _deleteMax()
    self = t
    return x
  }
  
  private func del(x: Element) -> (Tree, Bool)? {
    guard case let .Node(c, l, y, r) = self else { return nil }
    if x < y {
      guard let (l0, d) = l.del(x) else { return nil }
      let t = Tree.Node(c, l0, y, r)
      return d ? t.unbalancedR() : (t, false)
    } else if y < x {
      guard let (r0, d) = r.del(x) else { return nil }
      let t = Tree.Node(c, l, y, r0)
      return d ? t.unbalancedL() : (t, false)
    } else {
      if case .Empty = r {
        guard c == .B else { return (l, false) }
        if case let .Node(.R, ll, lx, lr) = l { return (.Node(.B, ll, lx, lr), false) }
        return (l, true)
      }
      let (r0, d, m) = r._deleteMin()
      let t = Tree.Node(c, l, m, r0)
      return d ? t.unbalancedL() : (t, false)
    }
  }
  
  /**
  Removes `x` from `self` and returns it if it is present, or `nil` if it is not.
  
  - Complexity: O(*log n*)
  */
  
  public mutating func remove(x: Element) -> Element? {
    guard let (t, _) = del(x) else { return nil }
    if case let .Node(_, l, y, r) = t {
      self = .Node(.B, l, y, r)
    } else {
      self = .Empty
    }
    return x
  }
  
  /**
  Returns a sequence of the elements of `self` from largest to smallest
  */
  
  public func reverse() -> ReverseTreeGenerator<Element> {
    guard case let .Node(_, l, e, r) = self else { return .Empty }
    return .Node(l, e, r.reverse())
  }
}

/// :nodoc:

internal enum TreeBalance {
  case Balanced(blackHeight: Int)
  case UnBalanced
}

/// :nodoc:

public enum TreeGenerator<Element : Comparable> : GeneratorType {
  case Empty
  indirect case Node(TreeGenerator, Element, Tree<Element>)
  public mutating func next() -> Element? {
    guard case .Node(var g, let e, let t) = self else { return nil }
    if let next = g.next() {
      self = .Node(g, e, t)
      return next
    } else {
      self = t.generate()
      return e
    }
  }
}

/// :nodoc:

public enum ReverseTreeGenerator<Element : Comparable> : GeneratorType, SequenceType {
  case Empty
  indirect case Node(Tree<Element>, Element, ReverseTreeGenerator)
  public mutating func next() -> Element? {
    guard case .Node(let t, let e, var g) = self else { return nil }
    if let next = g.next() {
      self = .Node(t, e, g)
      return next
    } else {
      self = t.reverse()
      return e
    }
  }
}

/// :nodoc:

public enum Color { case R, B }

/// :nodoc:

public func ==<E : Comparable>(lhs: Tree<E>, rhs: Tree<E>) -> Bool {
  return lhs.elementsEqual(rhs)
}
