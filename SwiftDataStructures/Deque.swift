// MARK: Definition

/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues. This implementation has a front queue, which is reversed, and a back queue,
which is not. Operations at either end of the Deque have the same complexity as operations
on the end of either queue.

Three structs conform to the `DequeType` protocol: `Deque`, `DequeSlice`, and
`ContiguousDeque`. These correspond to the standard library array types.
*/

public protocol DequeType :
  MutableSliceable,
  RangeReplaceableCollectionType,
  CustomDebugStringConvertible,
  ArrayLiteralConvertible {
  /// The type that represents the queues.
  typealias Container : RangeReplaceableCollectionType, MutableSliceable
  /// The front queue. It is stored in reverse.
  var front: Container { get set }
  /// The back queue.
  var back : Container { get set }
  /// Constructs an empty `Deque`
  init()
}

// MARK: DebugDescription

extension DequeType {
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    let fStr = front.reverse().map { String(reflecting: $0) }.joinWithSeparator(", ")
    let bStr = back.map { String(reflecting: $0) }.joinWithSeparator(", ")
    return "[" + fStr + " | " + bStr + "]"
  }
}

// MARK: Initializers

extension DequeType {
  internal init(balancedF: Container, balancedB: Container) {
    self.init()
    front = balancedF
    back  = balancedB
  }
  /// Construct from a collection
  public init<
    C : CollectionType where
    C.Index : RandomAccessIndexType,
    C.SubSequence.Generator.Element == Container.Generator.Element,
    C.Index.Distance == Container.Index.Distance
    >(col: C) {
      self.init()
      let mid = col.count / 2
      let midInd = col.startIndex.advancedBy(mid)
      front.reserveCapacity(mid)
      back.reserveCapacity(mid.successor())
      front.appendContentsOf(col[col.startIndex..<midInd].reverse())
      back.appendContentsOf(col[midInd..<col.endIndex])
  }
}

extension DequeType where Container.Index.Distance == Int {
  /// Create an instance containing `elements`.
  public init(arrayLiteral elements: Container.Generator.Element...) {
    self.init(col: elements)
  }
  /// Initialise from a sequence.
  public init<
    S : SequenceType where
    S.Generator.Element == Container.Generator.Element
    >(_ seq: S) {
    self.init(col: Array(seq))
  }
}

// MARK: Indexing

private enum IndexLocation<I> {
  case Front(I), Back(I)
}

extension DequeType where
  Container.Index : RandomAccessIndexType,
  Container.Index.Distance : ForwardIndexType {
  
  private func translate(i: Container.Index.Distance) -> IndexLocation<Container.Index> {
    return i < front.count ?
      .Front(front.endIndex.predecessor().advancedBy(-i)) :
      .Back(back.startIndex.advancedBy(i - front.count))
  }
  
  /**
  The position of the first element in a non-empty `Deque`.
  
  In an empty `Deque`, `startIndex == endIndex`.
  */
  
  public var startIndex: Container.Index.Distance { return 0 }
  
  /**
  The `Deque`'s "past the end" position.
  
  `endIndex` is not a valid argument to `subscript`, and is always reachable from
  `startIndex` by zero or more applications of `successor()`.
  */
  
  public var endIndex  : Container.Index.Distance { return front.count + back.count }
  public subscript(i: Container.Index.Distance) -> Container.Generator.Element {
    get {
      switch translate(i) {
      case let .Front(i): return front[i]
      case let .Back(i): return back[i]
      }
    } set {
      switch translate(i) {
      case let .Front(i): front[i] = newValue
      case let .Back(i): back[i] = newValue
      }
    }
  }
}

// MARK: Index Ranges

private enum IndexRangeLocation<I : ForwardIndexType> {
  case Front(Range<I>), Over(Range<I>, Range<I>), Back(Range<I>), Between
}

extension DequeType where
  Container.Index : RandomAccessIndexType,
  Container.Index.Distance : BidirectionalIndexType {
  
  private func translate
    (i: Range<Container.Index.Distance>)
    -> IndexRangeLocation<Container.Index> {
    if i.endIndex <= front.count {
      let s = front.endIndex.advancedBy(-i.endIndex)
      if s == front.startIndex && i.isEmpty { return .Between }
      let e = front.endIndex.advancedBy(-i.startIndex)
      return .Front(s..<e)
    }
    if i.startIndex >= front.count {
      let s = back.startIndex.advancedBy(i.startIndex - front.count)
      let e = back.startIndex.advancedBy(i.endIndex - front.count)
      return .Back(s..<e)
    }
    let f = front.startIndex..<front.endIndex.advancedBy(-i.startIndex)
    let b = back.startIndex..<back.startIndex.advancedBy(i.endIndex - front.count)
    return .Over(f, b)
  }
}

extension DequeType where
  Container.Index : RandomAccessIndexType,
  Container.Index.Distance : BidirectionalIndexType,
  SubSequence : DequeType,
  SubSequence.Container == Container.SubSequence,
  SubSequence.Generator.Element == Container.Generator.Element {
  
  public subscript(idxs: Range<Container.Index.Distance>) -> SubSequence {
    set { for (index, value) in zip(idxs, newValue) { self[index] = value } }
    get {
      switch translate(idxs) {
      case .Between: return SubSequence()
      case let .Over(f, b):
        return SubSequence( balancedF: front[f], balancedB: back[b] )
      case let .Front(i):
        if i.isEmpty { return SubSequence() }
        return SubSequence(
          balancedF: front[i.startIndex.successor()..<i.endIndex],
          balancedB: front[i.startIndex...i.startIndex]
        )
      case let .Back(i):
        if i.isEmpty { return SubSequence() }
        return SubSequence(
          balancedF: back[i.startIndex..<i.startIndex.successor()],
          balancedB: back[i.startIndex.successor()..<i.endIndex]
        )
      }
    }
  }
}

// MARK: Balance

private enum Balance {
  case FrontEmpty, BackEmpty, Balanced
}

extension DequeType {
  
  private var balance: Balance {
    let (f, b) = (front.count, back.count)
    if f == 0 {
      if b > 1 {
        return .FrontEmpty
      }
    } else if b == 0 {
      if f > 1 {
        return .BackEmpty
      }
    }
    return .Balanced
  }
  
  internal var isBalanced: Bool {
    return balance == .Balanced
  }
}

extension DequeType where Container.Index : BidirectionalIndexType {
  private mutating func check() {
    switch balance {
    case .FrontEmpty:
      let newBack = back.removeLast()
      front.reserveCapacity(back.count)
      front.replaceRange(front.indices, with: back.reverse())
      back.replaceRange(back.indices, with: [newBack])
    case .BackEmpty:
      let newFront = front.removeLast()
      back.reserveCapacity(front.count)
      back.replaceRange(back.indices, with: front.reverse())
      front.replaceRange(front.indices, with: [newFront])
    case .Balanced: return
    }
  }
}

// MARK: ReserveCapacity

extension DequeType {
  /**
  Reserve enough space to store `minimumCapacity` elements.
  
  - Postcondition: `capacity >= minimumCapacity` and the `Deque` has mutable
  contiguous storage.
  - Complexity: O(`count`).
  */
  public mutating func reserveCapacity(n: Container.Index.Distance) {
    front.reserveCapacity(n / 2)
    back.reserveCapacity(n / 2)
  }
}

// MARK: ReplaceRange

extension DequeType where
  Container.Index : RandomAccessIndexType,
  Container.Index.Distance : BidirectionalIndexType {
  
  /**
  Replace the given `subRange` of elements with `newElements`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`subRange.count`) if `subRange.endIndex == self.endIndex` and
  `isEmpty(newElements)`, O(`self.count + newElements.count`) otherwise.
  */
  
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Container.Generator.Element
    >(subRange: Range<Container.Index.Distance>, with newElements: C) {
    defer { check() }
    switch translate(subRange) {
    case .Between:
      back.replaceRange(back.startIndex..<back.startIndex, with: newElements)
    case let .Front(r):
      front.replaceRange(r, with: newElements.reverse())
    case let .Back(r):
      back.replaceRange(r, with: newElements)
    case let .Over(f, b):
      front.removeRange(f)
      back.replaceRange(b, with: newElements)
    }
  }
}

extension RangeReplaceableCollectionType where Index : BidirectionalIndexType {
  private mutating func popLast() -> Generator.Element? {
    return isEmpty ? nil : removeLast()
  }
}

// MARK: StackLike

extension DequeType where Container.Index : BidirectionalIndexType {
  /**
  If `!self.isEmpty`, remove the first element and return it, otherwise return `nil`.
  
  - Complexity: Amortized O(1)
  */
  public mutating func popFirst() -> Container.Generator.Element? {
    defer { check() }
    return front.popLast() ?? back.popLast()
  }
  /**
  If `!self.isEmpty`, remove the last element and return it, otherwise return `nil`.
  
  - Complexity: Amortized O(1)
  */
  public mutating func popLast() -> Container.Generator.Element? {
    defer { check() }
    return back.popLast() ?? front.popLast()
  }
}

// MARK: SequenceType

/// :nodoc:
public struct DequeGenerator<
  Container : RangeReplaceableCollectionType where
  Container.Index : BidirectionalIndexType
  > : GeneratorType {
  
  private let front, back: Container
  private var i: Container.Index
  private var onBack: Bool
  /**
  Advance to the next element and return it, or `nil` if no next element exists.
  
  - Requires: `next()` has not been applied to a copy of `self`.
  */
  public mutating func next() -> Container.Generator.Element? {
    if onBack { return i == back.endIndex ? nil : back[i++] }
    guard i == front.startIndex else { return front[--i] }
    onBack = true
    i = back.startIndex
    return next()
  }
}

extension DequeType where Container.Index : BidirectionalIndexType {
  /**
  Return a `DequeGenerator` over the elements of this `Deque`.
  
  - Complexity: O(1)
  */
  public func generate() -> DequeGenerator<Container> {
    return DequeGenerator(front: front, back: back, i: front.endIndex, onBack: false)
  }
}

// MARK: Rotations

extension DequeType where Container.Index : BidirectionalIndexType {
  
  /**
  Removes an element from the end of `self`, and prepends it to `self`
  
  ```swift
  var deque: Deque = [1, 2, 3, 4, 5]
  deque.rotateRight()
  // deque == [5, 1, 2, 3, 4]
  ```
  
  - Complexity: Amortized O(1)
  */
  public mutating func rotateRight() {
    if back.isEmpty { return }
    front.append(back.removeLast())
    check()
  }
  /**
  Removes an element from the start of `self`, and appends it to `self`
  
  ```swift
  var deque: Deque = [1, 2, 3, 4, 5]
  deque.rotateLeft()
  // deque == [2, 3, 4, 5, 1]
  ```
  
  - Complexity: Amortized O(1)
  */
  public mutating func rotateLeft() {
    if front.isEmpty { return }
    back.append(front.removeLast())
    check()
  }
  /**
  Removes an element from the end of `self`, and prepends `x` to `self`
  
  ```swift
  var deque: Deque = [1, 2, 3, 4, 5]
  deque.rotateRight(0)
  // deque == [0, 1, 2, 3, 4]
  ```
  
  - Complexity: Amortized O(1)
  */
  public mutating func rotateRight(x: Container.Generator.Element) {
    let _ = back.popLast() ?? front.popLast()
    front.append(x)
    check()
  }
  /**
  Removes an element from the start of `self`, and appends `x` to `self`
  
  ```swift
  var deque: Deque = [1, 2, 3, 4, 5]
  deque.rotateLeft(0)
  // deque == [2, 3, 4, 5, 0]
  ```
  
  - Complexity: Amortized O(1)
  */
  public mutating func rotateLeft(x: Container.Generator.Element) {
    let _ = front.popLast() ?? back.popLast()
    back.append(x)
    check()
  }
}

// MARK: Reverse

extension DequeType {
  /**
  Return a `Deque` containing the elements of `self` in reverse order.
  */
  public func reverse() -> Self {
    return Self(balancedF: back, balancedB: front)
  }
}

// MARK: -ending

extension DequeType where Container.Index : BidirectionalIndexType {
  /**
  Prepend `x` to `self`.
  
  The index of the new element is `self.startIndex`.
  
  - Complexity: Amortized O(1).
  */
  public mutating func prepend(x: Container.Generator.Element) {
    front.append(x)
    check()
  }
  /**
  Prepend the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func prextend<
    S : SequenceType where
    S.Generator.Element == Container.Generator.Element
    >(x: S) {
    front.appendContentsOf(x.reverse())
    check()
  }
}

// MARK: Underestimate Count

extension DequeType {
  /**
  Return a value less than or equal to the number of elements in `self`,
  **nondestructively**.
  */
  public func underestimateCount() -> Int {
    return front.underestimateCount() + back.underestimateCount()
  }
}

// MARK: Structs
/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues. This implementation has a front queue, which is a reversed array, and a
back queue, which is an array. Operations at either end of the Deque have the same
complexity as operations on the end of either array.
*/
public struct Deque<Element> : DequeType {
  /// The front and back queues. The front queue is stored in reverse.
  public var front, back: [Element]
  public typealias SubSequence = DequeSlice<Element>
  /// Initialise an empty `Deque`
  public init() { (front, back) = ([], []) }
}
/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues. This implementation has a front queue, which is a reversed ArraySlice, and
a back queue, which is an ArraySlice. Operations at either end of the Deque have the same
complexity as operations on the end of either ArraySlice.

Because an `ArraySlice` presents a view onto the storage of some larger array even after
the original array's lifetime ends, storing the slice may prolong the lifetime of elements
that are no longer accessible, which can manifest as apparent memory and object leakage.
To prevent this effect, use `DequeSlice` only for transient computation.
*/
public struct DequeSlice<Element> : DequeType {
  /// The front and back queues. The front queue is stored in reverse
  public var front, back: ArraySlice<Element>
  public typealias SubSequence = DequeSlice
  /// Initialise an empty `DequeSlice`
  public init() { (front, back) = ([], []) }
}
/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues. This implementation has a front queue, which is a reversed ContiguousArray,
and a back queue, which is a ContiguousArray. Operations at either end of the Deque have
the same complexity as operations on the end of either ContiguousArray.
*/
public struct ContiguousDeque<Element> : DequeType {
  /// The front and back queues. The front queue is stored in reverse
  public var front, back: ContiguousArray<Element>
  public typealias SubSequence = DequeSlice<Element>
  /// Initialise an empty `ContiguousDeque`
  public init() { (front, back) = ([], []) }
}