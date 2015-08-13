/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues, with the first queue beginning at the start of the Deque, and the second
beginning at the end (in reverse):

```swift
First queue   Second queue
v              v
[0, 1, 2, 3] | [3, 2, 1, 0]
```

This allows for O(*1*) prepending, appending, and removal of first and last elements.

This implementation of a Deque uses two reversed `ContiguousArray`s as the queues. (this
means that the first array has reversed semantics, while the second does not) This allows
for O(*1*) indexing.

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/08/09/yet-another-root-of-all-evil/).
*/

public struct ContiguousDeque<Element> : CustomDebugStringConvertible, ArrayLiteralConvertible, SequenceType, Indexable, MutableSliceable, RangeReplaceableCollectionType {
  internal var front, back: ContiguousArray<Element>

  public typealias SubSequence = ContiguousDequeSlice<Element>
  public typealias Generator = ContiguousDequeGenerator<Element>
  
  // MARK: Initializers
  
  internal init(_ front: ContiguousArray<Element>, _ back: ContiguousArray<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
  
  internal init(balancedF: ContiguousArray<Element>, balancedB: ContiguousArray<Element>) {
    (front, back) = (balancedF, balancedB)
  }
  /// Initilalize from a `ContiguousDequeSlice`
  public init(_ from: ContiguousDequeSlice<Element>) {
    (front, back) = (ContiguousArray(from.front), ContiguousArray(from.back))
  }
  
  private init(array: [Element]) {
    let half = array.endIndex / 2
    self.init(
      balancedF: ContiguousArray(array[array.startIndex..<half].reverse()),
      balancedB: ContiguousArray(array[half..<array.endIndex])
    )
  }
  
  /// Construct from an arbitrary sequence with elements of type `Element`.
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init(array: Array(seq))
  }
  /// Create an instance containing `elements`.
  public init(arrayLiteral elements: Element...) {
    self.init(array: elements)
  }
  
  /// Constructs an empty `ContiguousDeque`
  public init() {
    (front, back) = ([], [])
  }
  
  // MARK: Instance Properties
  
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return
      "[" +
        ", ".join(front.reverse().map { String(reflecting: $0) }) +
        " | " +
        ", ".join(back.map { String(reflecting: $0) }) + "]"
  }

  internal var balance: Balance {
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
  
  /**
  The position of the first element in a non-empty `ContiguousDeque`.
  
  In an empty `ContiguousDeque`, `startIndex == endIndex`.
  */
  public var startIndex: Int { return 0 }
  /**
  The `ContiguousDeque`'s "past the end" position.
  
  `endIndex` is not a valid argument to `subscript`, and is always reachable from
  `startIndex` by zero or more applications of `successor()`.
  */
  public var endIndex: Int { return front.endIndex + back.endIndex }
  
  /**
  Returns the number of elements.
  
  - Complexity: O(1)
  */
  public var count: Int {
    return endIndex
  }
  /**
  Returns the first element of `self`, or `nil` if `self` is empty.
  */
  public var first: Element? {
    return front.last ?? back.first
  }
  /**
  Returns the last element of `self`, or `nil` if `self` is empty.
  */
  public var last: Element? {
    return back.last ?? front.first
  }
  /**
  Returns `true` iff `self` is empty.
  */
  public var isEmpty: Bool {
    return front.isEmpty && back.isEmpty
  }
  
  // MARK: Instance Methods
  
  /**
  This is the function that maintains an invariant: If either queue has more than one
  element, the other must not be empty. This ensures that all operations can be performed
  efficiently. It is caried out whenever a mutating funciton which may break the invariant
  is performed.
  */
  
  internal mutating func check() {
    switch balance {
    case .FrontEmpty:
      let newBack = back.removeLast()
      front.reserveCapacity(back.count)
      front = ContiguousArray(back.reverse())
      back = [newBack]
    case .BackEmpty:
      let newFront = front.removeLast()
      back.reserveCapacity(front.count)
      back = ContiguousArray(front.reverse())
      front = [newFront]
    case .Balanced: return
    }
  }

  /**
  Return a `ContiguousDequeGenerator` over the elements of this `ContiguousDeque`.
  
  - Complexity: O(1)
  */
  public func generate() -> ContiguousDequeGenerator<Element> {
    return ContiguousDequeGenerator(fGen: front.reverse().generate(), sGen: back.generate())
  }
  /**
  Return a value less than or equal to the number of elements in `self`,
  **nondestructively**.
  */
  public func underestimateCount() -> Int {
    return front.underestimateCount() + back.underestimateCount()
  }
  /**
  Returns a `ContiguousDequeSlice` containing all but the first element.
  
  - Complexity: O(1)
  */
  public func dropFirst() -> ContiguousDequeSlice<Element> {
    if front.isEmpty { return ContiguousDequeSlice() }
    return ContiguousDequeSlice(front.dropLast(), ArraySlice(back))
  }
  /**
  Returns a `ContiguousDequeSlice` containing all but the first n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(1)
  */
  public func dropFirst(n: Int) -> ContiguousDequeSlice<Element> {
    if n < front.endIndex {
      return ContiguousDequeSlice(
        balancedF: front.dropLast(n),
        balancedB: ArraySlice(back)
      )
    } else {
      let i = n - front.endIndex
      if i >= back.endIndex { return [] }
      return ContiguousDequeSlice(
        balancedF: [back[i]],
        balancedB: back.dropFirst(i.successor())
      )
    }
  }
  /**
  Returns a `ContiguousDequeSlice` containing all but the last element.
  
  - Complexity: O(1)
  */
  public func dropLast() -> ContiguousDequeSlice<Element> {
    if back.isEmpty { return ContiguousDequeSlice() }
    return ContiguousDequeSlice(ArraySlice(front), back.dropLast())
  }
  /**
  Returns a `ContiguousDequeSlice` containing all but the last n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(1)
  */
  public func dropLast(n: Int) -> ContiguousDequeSlice<Element> {
    if n < back.endIndex {
      return ContiguousDequeSlice(
        balancedF: ArraySlice(front),
        balancedB: back.dropLast(n)
      )
    } else {
      let i = n - back.endIndex
      if i >= front.endIndex { return [] }
      return ContiguousDequeSlice(
        balancedF: front.dropFirst(i.successor()),
        balancedB: [front[i]]
      )
    }
  }
  /**
  Returns a `ContiguousDequeSlice`, up to `maxLength` in length, containing the initial
  elements of `self`.
  
  If maxLength exceeds `self.count`, the result contains all the elements of `self`.
  
  - Requires: `maxLength >= 0`
  - Complexity: O(1)
  */
  public func prefix(maxLength: Int) -> ContiguousDequeSlice<Element> {
    if maxLength == 0 { return [] }
    if maxLength <= front.endIndex {
      let i = front.endIndex - maxLength
      return ContiguousDequeSlice(
        balancedF: front.suffix(maxLength.predecessor()),
        balancedB: [front[i]]
      )
    } else {
      let i = maxLength - front.endIndex
      return ContiguousDequeSlice(
        balancedF: ArraySlice(front),
        balancedB: back.prefix(i)
      )
    }
  }
  /**
  Returns a `ContiguousDequeSlice`, up to `maxLength` in length, containing the final
  elements of `self`.
  
  If `maxLength` exceeds `self.count`, the result contains all the elements of `self`.
  
  - Requires: `maxLength >= 0`
  - Complexity: O(1)
  */
  public func suffix(maxLength: Int) -> ContiguousDequeSlice<Element> {
    if maxLength == 0 { return [] }
    if maxLength <= back.endIndex {
      return ContiguousDequeSlice(
        balancedF: [back[back.endIndex - maxLength]],
        balancedB: back.suffix(maxLength.predecessor())
      )
    } else {
      return ContiguousDequeSlice(
        balancedF: front.prefix(maxLength - back.endIndex),
        balancedB: ArraySlice(back)
      )
    }
  }
  /**
  Returns the maximal `ContiguousDequeSlice`s of `self`, in order, that don't contain
  elements satisfying the predicate `isSeparator`.
  
  - Parameter maxSplits: The maximum number of `ContiguousDequeSlice`s to return, minus 1.
  If `maxSplit` + 1 `ContiguousDequeSlice`s are returned, the last one is a suffix of
  `self` containing the remaining elements. The default value is `Int.max`.
  - Parameter allowEmptySubsequences: If `true`, an empty `ContiguousDequeSlice` is
  produced in the result for each pair of consecutive elements satisfying `isSeparator`.
  The default value is false.
  - Requires: maxSplit >= 0
  */
  public func split(
    maxSplit: Int,
    allowEmptySlices: Bool,
    @noescape isSeparator: Element -> Bool
    ) -> [ContiguousDequeSlice<Element>] {
      var result: [ContiguousDequeSlice<Element>] = []
      var curent:  ContiguousDequeSlice<Element>  = []
      curent.front.reserveCapacity(1)
      curent.back.reserveCapacity(maxSplit - 1)
      for element in self {
        if isSeparator(element) {
          if !curent.isEmpty || allowEmptySlices {
            result.append(curent)
            curent.removeAll(true)
          }
        } else {
          curent.append(element)
        }
      }
      if !curent.isEmpty || allowEmptySlices {
        result.append(curent)
      }
      return result
  }

  /**
  If `!self.isEmpty`, remove the first element and return it, otherwise return `nil`.
  
  - Complexity: Amortized O(1)
  */
  public mutating func popFirst() -> Element? {
    defer { check() }
    return front.popLast() ?? back.popLast()
  }
  /**
  If `!self.isEmpty`, remove the last element and return it, otherwise return `nil`.
  
  - Complexity: Amortized O(1)
  */
  public mutating func popLast() -> Element? {
    defer { check() }
    return back.popLast() ?? front.popLast()
  }
  /**
  Returns `self[startIndex..<end]`
  
  - Complexity: O(1)
  */
  public func prefixUpTo(end: Int) -> ContiguousDequeSlice<Element> {
    return prefix(end)
  }
  /**
  Returns `prefixUpTo(position.successor())`
  
  - Complexity: O(1)
  */
  public func prefixThrough(position: Int) -> ContiguousDequeSlice<Element> {
    return prefix(position.successor())
  }
  /**
  Return a `ContiguousDeque` containing the elements of `self` in reverse order.
  
  - Complexity: O(1)
  */
  public func reverse() -> ContiguousDeque<Element> {
    return ContiguousDeque(balancedF: back, balancedB: front)
  }
  /**
  Returns `self[start..<endIndex]`
  
  - Complexity: O(1)
  */
  public func suffixFrom(start: Int) -> ContiguousDequeSlice<Element> {
    return dropFirst(start)
  }


  /**
  Append `x` to `self`.

  Applying `successor()` to the index of the new element yields `self.endIndex`.
  
  - Complexity: Amortized O(1).
  */
  public mutating func append(x: Element) {
    back.append(x)
    check()
  }
  /**
  Append the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    back.extend(newElements)
    check()
  }
  /**
  Insert `newElement` at index `i`.
  
  - Requires: `i <= count`.
  - Complexity: O(`count`).
  */
  public mutating func insert(newElement: Element, atIndex i: Int) {
    i < front.endIndex ?
      front.insert(newElement, atIndex: front.endIndex - i) :
      back .insert(newElement, atIndex: i - front.endIndex)
    check()
  }
  /**
  Prepend `x` to `self`.
  
  The index of the new element is `self.startIndex`.
  
  - Complexity: Amortized O(1).
  */
  public mutating func prepend(x: Element) {
    front.append(x)
    check()
  }
  /**
  Prepend the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    front.extend(newElements.reverse())
    check()
  }
  /**
  Remove all elements.
  
  - Postcondition: `capacity == 0` iff `keepCapacity` is `false`.
  - Complexity: O(`self.count`).
  */
  public mutating func removeAll(keepCapacity: Bool = false) {
    front.removeAll(keepCapacity: keepCapacity)
    back .removeAll(keepCapacity: keepCapacity)
  }
  /**
  Remove and return the element at index `i`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`count`).
  */
  public mutating func removeAtIndex(i: Int) -> Element {
    defer { check() }
    return i < front.endIndex ?
      front.removeAtIndex(front.endIndex.predecessor() - i) :
      back .removeAtIndex(i - front.endIndex)
  }
  /**
  Remove the element at `startIndex` and return it.
  
  - Complexity: Amortized O(1)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst() -> Element {
    if front.isEmpty { return back.removeLast() }
    defer { check() }
    return front.removeLast()
  }
  /**
  Remove the first `n` elements.

  - Complexity: O(`self.count`)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst(n: Int) {
    if n < front.endIndex {
      front.removeRange((front.endIndex - n)..<front.endIndex)
    } else {
      let i = n - front.endIndex
      if i < back.endIndex {
        self = ContiguousDeque(
          balancedF: [back[i]],
          balancedB: ContiguousArray(back.dropFirst(i.successor()))
        )
      } else {
        removeAll()
      }
    }
  }
  /**
  Remove an element from the end.
  
  - Complexity: Amortized O(1)
  - Requires: `!self.isEmpty`
  */
  public mutating func removeLast() -> Element {
    if back.isEmpty { return front.removeLast() }
    defer { check() }
    return back.removeLast()
  }
  /**
  Remove the last `n` elements.
  
  - Complexity: O(`self.count`)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeLast(n: Int) {
    if n < back.endIndex {
      back.removeRange((back.endIndex - n)..<back.endIndex)
    } else {
      let i = n - back.endIndex
      if i < front.endIndex {
        self = ContiguousDeque(
          balancedF: ContiguousArray(front.dropFirst(i.successor())),
          balancedB: [front[i]]
        )
      } else {
        removeAll()
      }
    }
  }
  /**
  Remove the indicated subRange of elements.

  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`self.count`).
  */
  public mutating func removeRange(subRange: Range<Int>) {
    if subRange.startIndex == subRange.endIndex { return }
    defer { check() }
    switch (subRange.startIndex < front.endIndex, subRange.endIndex <= front.endIndex) {
    case (true, true):
      let start = front.endIndex - subRange.endIndex
      let end   = front.endIndex - subRange.startIndex
      front.removeRange(start..<end)
    case (true, false):
      let frontTo = front.endIndex - subRange.startIndex
      let backTo  = subRange.endIndex - front.endIndex
      front.removeRange(front.startIndex..<frontTo)
      back.removeRange(back.startIndex..<backTo)
    case (false, false):
      let start = subRange.startIndex - front.endIndex
      let end   = subRange.endIndex - front.endIndex
      back.removeRange(start..<end)
    case (false, true): return
    }
  }
  /**
  Replace the given `subRange` of elements with `newElements`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`subRange.count`) if `subRange.endIndex == self.endIndex` and
  `isEmpty(newElements)`, O(`self.count + newElements.count`) otherwise.
  */
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<Int>, with newElements: C) {
      defer { check() }
      switch (subRange.startIndex < front.endIndex, subRange.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - subRange.endIndex
        let end   = front.endIndex - subRange.startIndex
        front.replaceRange(start..<end, with: newElements.reverse())
      case (true, false):
        let frontTo = front.endIndex - subRange.startIndex
        let backTo  = subRange.endIndex - front.endIndex
        front.removeRange(front.startIndex..<frontTo)
        back.replaceRange(back.startIndex..<backTo, with: newElements)
      case (false, false):
        let start = subRange.startIndex - front.endIndex
        let end   = subRange.endIndex - front.endIndex
        back.replaceRange(start..<end, with: newElements)
      case (false, true):
        back.replaceRange(back.startIndex..<back.startIndex, with: newElements)
      }
  }
  /**
  Reserve enough space to store `minimumCapacity` elements.
  
  - Postcondition: `capacity >= minimumCapacity` and the `ContiguousDeque` has mutable
  contiguous storage.
  - Complexity: O(`count`).
  */
  mutating public func reserveCapacity(n: Int) {
    let half = n / 2
    front.reserveCapacity(half)
    back.reserveCapacity(n - half)
  }
  
  // MARK: Subscripts
  
  /**
  Access the element at `position`.
  
  - Requires: `0 <= position < endIndex`
  */
  public subscript(position: Int) -> Element {
    get {
      return position < front.endIndex ?
        front[front.endIndex.predecessor() - position] :
        back[position - front.endIndex]
    } set {
      position < front.endIndex ?
        (front[front.endIndex.predecessor() - position] = newValue) :
        (back[position - front.endIndex] = newValue)
    }
  }
  
  /**
  Access the elements at the given subRange.
  
  - Complexity: O(1)
  */
  
  public subscript(idxs: Range<Int>) -> ContiguousDequeSlice<Element> {
    get {
      if idxs.startIndex == idxs.endIndex { return [] }
      switch (idxs.startIndex < front.endIndex, idxs.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - idxs.endIndex
        let end   = front.endIndex - idxs.startIndex
        return ContiguousDequeSlice(
          balancedF: front[start.successor()..<end],
          balancedB: [front[start]]
        )
      case (true, false):
        let frontTo = front.endIndex - idxs.startIndex
        let backTo  = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice(
          balancedF: front[front.startIndex ..< frontTo],
          balancedB: back [back.startIndex ..< backTo]
        )
      case (false, false):
        let start = idxs.startIndex - front.endIndex
        let end   = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice(
          balancedF: [back[start]],
          balancedB: back[start.successor() ..< end]
        )
      case (false, true): return []
      }
    } set {
      for (index, value) in zip(idxs, newValue) {
        self[index] = value
      }
    }
  }
  
}
internal enum Balance {
  case FrontEmpty, BackEmpty, Balanced
}
/// :nodoc:
public struct ContiguousDequeGenerator<Element> : GeneratorType, SequenceType {
  private var fGen: IndexingGenerator<ReverseRandomAccessCollection<ContiguousArray<Element>>>?
  private var sGen: IndexingGenerator<ContiguousArray<Element>>
  
  /**
  Advance to the next element and return it, or `nil` if no next element exists.
  
  - Requires: `next()` has not been applied to a copy of `self` since the copy was made,
  and no preceding call to `self.next()` has returned `nil`.
  */
  
  mutating public func next() -> Element? {
    if fGen == nil { return sGen.next() }
    return fGen!.next() ?? {
      fGen = nil
      return sGen.next()
      }()
  }
}