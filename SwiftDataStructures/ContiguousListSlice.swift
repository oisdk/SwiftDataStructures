/**
The [cons](https://en.wikipedia.org/wiki/Cons) operator.

This operator copies the rhs entirely, therefore building lists using it is quadratic.

- Complexity: O(`count`)
*/

public func |> <T>(lhs: T, var rhs: ContiguousListSlice<T>) -> ContiguousListSlice<T> {
  rhs.prepend(lhs)
  return rhs
}

/**
A `ContiguousListSlice` is a list-like data structure, implemented via a reversed
`ArraySlice`. It has performance characteristics similar to an array, except that
operations on the *beginning* generally have complexity of amortized O(1), whereas
operations on the *end* are usually O(`count`).

Because an `ArraySlice` presents a view onto the storage of some larger array even after
the original array's lifetime ends, storing the slice may prolong the lifetime of elements
that are no longer accessible, which can manifest as apparent memory and object leakage.
To prevent this effect, use `ContiguousListSlice` only for transient computation.

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/08/09/yet-another-root-of-all-evil/).
*/

public struct ContiguousListSlice<Element> : CustomDebugStringConvertible, ArrayLiteralConvertible, Indexable, SequenceType, CollectionType, RangeReplaceableCollectionType  {
  internal var contents: ArraySlice<Element>

  // MARK: Initializers
  
  /// Create an instance containing `elements`.
  public init(arrayLiteral: Element...) {
    contents = ArraySlice(arrayLiteral.reverse())
  }
  /// Construct from an array with elements of type `Element`.
  public init(_ array: [Element]) {
    contents = ArraySlice(array.reverse())
  }
  /// Construct from an arbitrary sequence with elements of type `Element`.
  public init<S: SequenceType where S.Generator.Element == Element>(_ seq: S) {
    contents = ArraySlice(seq.reverse())
  }
  /// Constructs an empty `ContiguousListSlice`
  public init() {
    contents = []
  }
  internal init(alreadyReversed: ArraySlice<Element>) {
    contents = alreadyReversed
  }
  // MARK: Instance Properties
  
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return "[" + ", ".join(map {String(reflecting: $0)}) + "]"
  }

  /**
  The `ContiguousListSlice`'s "past the end" position.
  
  `endIndex` is not a valid argument to `subscript`, and is always reachable from
  `startIndex` by zero or more applications of `successor()`.
  */
  public var endIndex: ContiguousListIndex {
    return ContiguousListIndex(contents.startIndex.predecessor())
  }
  /**
  The position of the first element in a non-empty `ContiguousListSlice`.
  
  In an empty `ContiguousListSlice`, `startIndex == endIndex`.
  */
  public var startIndex: ContiguousListIndex {
    return ContiguousListIndex(contents.endIndex.predecessor())
  }
  public subscript(idx: ContiguousListIndex) -> Element {
    get { return contents[idx.val] }
    set { contents[idx.val] = newValue }
  }
  
  public typealias SubSequence = ContiguousListSlice<Element>
  
  /**
  The number of elements in `self`
  
  - Complexity: O(1)
  */
  public var count: Int {
    return contents.count
  }
  /**
  Returns the first element of `self`, or `nil` if `self` is empty.
  */
  public var first: Element? {
    return contents.last
  }
  /**
  Returns the last element of `self`, or `nil` if `self` is empty.
  */
  public var last: Element? {
    return contents.first
  }
  /**
  Returns `true` iff `self` is empty.
  */
  public var isEmpty: Bool {
    return contents.isEmpty
  }
  
  // MARK: Instance Methods
  
  /**
  Returns a `ContiguousListSlice` containing all but the first element.
  
  - Complexity: O(1)
  */
  public func dropFirst() -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropLast())
  }
  /**
  Returns a `ContiguousListSlice` containing all but the last element.
  
  - Complexity: O(1)
  */
  public func dropLast() -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropFirst())
  }
  /**
  Returns a `ContiguousListSlice` containing all but the first n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(1)
  */
  public func dropFirst(n: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropLast(n))
  }
  /**
  Returns a `ContiguousListSlice` containing all but the last n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(1)
  */
  public func dropLast(n: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.dropFirst(n))
  }
  /**
  Return a `IndexingGenerator` over the elements of this `ContiguousList`.
  
  - Complexity: O(1)
  */
  public func generate() -> IndexingGenerator<ContiguousListSlice> {
    return IndexingGenerator(self)
  }
  /**
  Returns a `ContiguousListSlice`, up to `maxLength` in length, containing the initial
  elements of `self`.
  
  If maxLength exceeds `self.count`, the result contains all the elements of `self`.
  
  - Requires: `maxLength >= 0`
  - Complexity: O(1)
  */
  public func prefix(maxLength: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffix(maxLength))
  }
  /**
  Returns a `ContiguousListSlice`, up to `maxLength` in length, containing the final
  elements of `self`.
  
  If `maxLength` exceeds `self.count`, the result contains all the elements of `self`.
  
  - Requires: maxLength >= 0
  - Complexity: O(1)
  */
  public func suffix(maxLength: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefix(maxLength))
  }
  /**
  Returns the maximal `ContiguousListSlice`s of `self`, in order, that don't contain
  elements satisfying the predicate `isSeparator`.
  
  - Parameter maxSplits: The maximum number of `ContiguousListSlice`s to return, minus 1.
  If `maxSplit` + 1 `ContiguousListSlice`s are returned, the last one is a suffix of
  `self` containing the remaining elements. The default value is `Int.max`.
  - Parameter allowEmptySubsequences: If `true`, an empty `ContiguousListSlice` is
  produced in the result for each pair of consecutive elements satisfying `isSeparator`.
  The default value is false.
  - Requires: maxSplit >= 0
  */
  public func split(
    maxSplit: Int,
    allowEmptySlices: Bool,
    @noescape isSeparator: Element -> Bool
    ) -> [ContiguousListSlice<Element>] {
      var result: [ContiguousListSlice<Element>] = []
      var i = startIndex
      for j in indices where isSeparator(self[i]) {
        let slice = self[i..<j]
        i = j.successor()
        if (!slice.isEmpty || allowEmptySlices) {
          result.append(slice)
        }
        if result.count > maxSplit {
          result.append(self[i..<endIndex])
          return result
        }
      }
      return result
  }
  /**
  Return a value less than or equal to the number of elements in `self`,
  **nondestructively**.
  */
  public func underestimateCount() -> Int {
    return contents.underestimateCount()
  }
  /**
  Returns a `ArraySlice` containing the elements in `self` in reverse order.
  
  - Complexity: O(1)
  */
  public func reverse() -> ArraySlice<Element> {
    return contents
  }


  /**
  If `!self.isEmpty`, remove the first element and return it, otherwise return `nil`.
  
  - Complexity: O(1)
  */
  public mutating func popFirst() -> Element? {
    return contents.popLast()
  }
  /**
  If `!self.isEmpty`, remove the last element and return it, otherwise return `nil`.
  
  - Complexity: O(`count`)
  */
  public mutating func popLast() -> Element? {
    return contents.isEmpty ? nil : contents.removeFirst()
  }
  /**
  Returns `prefixUpTo(position.successor())`
  
  - Complexity: O(1)
  */
  public func prefixThrough(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return prefixUpTo(i.successor())
  }
  /**
  Returns `self[startIndex..<end]`
  
  - Complexity: O(1)
  */
  public func prefixUpTo(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffixFrom(i.val.successor()))
  }
  /**
  Returns `prefixUpTo(position.successor())`
  
  - Complexity: O(1)
  */
  public func prefixThrough(i: Int) -> ContiguousListSlice<Element> {
    return prefixUpTo(i.successor())
  }
  /**
  Returns `self[startIndex..<end]`
  
  - Complexity: O(1)
  */
  public func prefixUpTo(i: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.suffix(i))
  }
  /**
  Remove the element at `startIndex` and return it.
  
  - Complexity: O(1)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst() -> Element {
    return contents.removeLast()
  }
  /**
  Remove an element from the end.
  
  - Complexity: O(`count`)
  - Requires: `!self.isEmpty`
  */
  public mutating func removeLast() -> Element {
    return contents.removeFirst()
  }
  /**
  Returns `self[start..<endIndex]`
  
  - Complexity: O(1)
  */
  public func suffixFrom(i: ContiguousListIndex) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefixThrough(i.val))
  }
  /**
  Returns `self[start..<endIndex]`
  
  - Complexity: O(1)
  */
  public func suffixFrom(i: Int) -> ContiguousListSlice<Element> {
    return ContiguousListSlice(alreadyReversed: contents.prefixUpTo(contents.endIndex - i))
  }
  public subscript(idxs: Range<ContiguousListIndex>) -> ContiguousListSlice<Element> {
    get {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      return ContiguousListSlice(alreadyReversed: contents[start..<end])
    } set {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      contents[start..<end] = newValue.contents
    }
  }
  public subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
  public subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
    get {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      return ContiguousListSlice(alreadyReversed: contents[str..<end] )
    } set {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      contents[str..<end] = newValue.contents
    }
  }

  /**
  Append `x` to `self`.
  
  Applying `successor()` to the index of the new element yields `self.endIndex`.
  
  - Complexity: O(`count`).
  */
  public mutating func append(with: Element) {
    contents.insert(with, atIndex: contents.startIndex)
  }
  /**
  Prepend `x` to `self`.
  
  The index of the new element is `self.startIndex`.
  
  - Complexity: Amortized O(1).
  */
  public mutating func prepend(with: Element) {
    contents.append(with)
  }
  /**
  Append the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func extend<S : CollectionType where S.Generator.Element == Element>(newElements: S) {
    contents.replaceRange(contents.startIndex..<contents.startIndex, with: newElements.reverse())
  }
  /**
  Append the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    extend(Array(newElements))
  }
  /**
  Prepend the elements of `newElements` to `self`.
  
  - Complexity: O(*length of result*).
  */
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
    contents.extend(newElements.reverse())
  }
  /**
  Insert `newElement` at index `i`.
  
  - Requires: `i <= count`.
  - Complexity: O(`count`).
  */
  public mutating func insert(newElement: Element, atIndex i: ContiguousListIndex) {
    contents.insert(newElement, atIndex: i.val.successor())
  }
  /**
  Insert `newElement` at index `i`.
  
  - Requires: `i <= count`.
  - Complexity: O(`count`).
  */
  public mutating func insert(newElement: Element, atIndex i: Int) {
    contents.insert(newElement, atIndex: contents.endIndex - i)
  }
  /**
  Remove all elements.
  
  - Postcondition: `capacity == 0` iff `keepCapacity` is `false`.
  - Complexity: O(`self.count`).
  */
  public mutating func removeAll(keepCapacity keepCapacity: Bool) {
    contents.removeAll(keepCapacity: keepCapacity)
  }
  /**
  Remove and return the element at index `i`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`count`).
  */
  public mutating func removeAtIndex(index: ContiguousListIndex) -> Element {
    return contents.removeAtIndex(index.val)
  }
  /**
  Remove and return the element at index `i`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`count`).
  */
  public mutating func removeAtIndex(index: Int) -> Element {
    return contents.removeAtIndex(contents.endIndex.predecessor() - index)
  }
  /**
  Remove the first `n` elements.
  
  - Complexity: O(`n`)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst(n: Int) {
    contents.removeRange((contents.endIndex - n)..<contents.endIndex)
  }
  /**
  Remove the last `n` elements.
  
  - Complexity: O(`self.count`)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeLast(n: Int) {
    contents.removeFirst(n)
  }
  /**
  Remove the indicated `subRange` of elements.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`self.count`).
  */
  public mutating func removeRange(subRange: Range<ContiguousListIndex>) {
    let str = subRange.endIndex.val.successor()
    let end   = subRange.startIndex.val.successor()
    contents.removeRange(str..<end)
  }
  /**
  Remove the indicated `subRange` of elements.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`self.count`).
  */
  public mutating func removeRange(subRange: Range<Int>) {
    let str = contents.endIndex - subRange.endIndex
    let end = contents.endIndex - subRange.startIndex
    contents.removeRange(str..<end)
  }
  /**
  Replace the given `subRange` of elements with `newElements`.
  
  Invalidates all indices with respect to `self`.
  
  - Complexity: O(`subRange.count`) if `subRange.endIndex == self.endIndex` and
  `isEmpty(newElements)`, O(`self.count + newElements.count`) otherwise.
  */
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<ContiguousListIndex>, with newElements: C) {
      let str = subRange.endIndex.val.successor()
      let end = subRange.startIndex.val.successor()
      contents.replaceRange((str..<end), with: newElements.reverse())
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
      let str = contents.endIndex - subRange.endIndex
      let end = contents.endIndex - subRange.startIndex
      contents.replaceRange((str..<end), with: newElements.reverse())
  }
  /**
  Reserve enough space to store `minimumCapacity` elements.
  
  - Postcondition: `capacity >= minimumCapacity` and the `ContiguousDeque` has mutable
  contiguous storage.
  - Complexity: O(`count`).
  */
  public mutating func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}
