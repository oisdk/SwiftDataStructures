infix operator |> {
associativity right
precedence 100
}
/**
The [cons](https://en.wikipedia.org/wiki/Cons) operator.

This operator lazy. i.e:

```swift
func printAndGiveList() -> LazyList<Int> {
  print(2)
  return .Nil
}

2 |> 1 |> printAndGiveList()
```

Will not print 2.

- Complexity: O(1)
*/
public func |> <T>(lhs: T, @autoclosure(escaping) rhs: () -> LazyList<T>) -> LazyList<T> {
  return .Cons(lhs, rhs)
}

/**
A singly-linked, recursive list. Head-tail decomposition can be accomplished with a
`switch` statement:

```swift
extension LazyList {
  public func map<T>(f: Element -> T) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(x, xs): return f(x) |> xs().map(f)
    }
  }
}
```

Where `|>` is the [cons](https://en.wikipedia.org/wiki/Cons) operator.

Operations on the beginning of the list are O(1), whereas other operations are O(n).

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/07/29/deques-queues-and-lists-in-swift-with-indirect/).
*/

public enum LazyList<Element> : CustomDebugStringConvertible, ArrayLiteralConvertible, GeneratorType, SequenceType {
  case Nil
  indirect case Cons(Element, () -> LazyList<Element>)

  public typealias Generator = LazyList<Element>
  public typealias SubSequence = LazyList<Element>

  // MARK: Initializers

  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      self = head |> LazyList(gen: gen)
    } else {
      self = .Nil
    }
  }
  
  /**
  Construct from an arbitrary sequence with elements of type `Element`. If the underlying
  sequence is lazy, the list constructed will also be lazy. (i.e, the underlying sequence
  will not be evaluated.)
  */
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self = LazyList(gen: seq.generate())
  }
  
  /// Create an instance containing `elements`.
  public init(arrayLiteral elements: Element...) {
    self = LazyList(elements.generate())
  }
  
  // MARK: Instance Properties
  
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return "[" + ", ".join(map{String(reflecting: $0)}) + "]"
  }
  
  /**
  The number of elements in `self`
  
  - Complexity: O(`count`)
  */
  
  public var count: Int {
    switch self {
    case .Nil: return 0
    case let .Cons(_, tail): return tail().count.successor()
    }
  }
  
  /**
  Returns `true` iff `self` is empty.
  */
  public var isEmpty: Bool {
    switch self {
    case .Nil:  return true
    case .Cons: return false
    }
  }
  
  /**
  Returns the first element of `self`, if it exists, or `nil` if `self` is empty.
  */
  
  public var first: Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, _): return head
    }
  }
  /**
  Returns the last element of `self`, if it exists, or `nil` if `self` is empty.
  
  - Complexity: O(`count`)
  */
  public var last: Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, tail): return tail().isEmpty ? head : tail().last
    }
  }
  
  // MARK: Instance Methods
  /**
  Returns the next element if it exists, or nil if it does not.
  */
  public mutating func next() -> Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, tail):
      self = tail()
      return head
    }
  }
  /// Return a *generator* over the elements of this *sequence*.
  ///
  /// - Complexity: O(1).
  public func generate() -> LazyList<Element> {
    return self
  }
  /**
  Returns a `LazyList` containing all but the first element.
  
  - Complexity: O(1)
  */
  public func dropFirst() -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(_, tail): return tail()
    }
  }
  /**
  Returns a `LazyList` containing all but the first element.
  
  - Complexity: O(`count`)
  */
  public func dropLast() -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let tail = tail()
      if tail.isEmpty { return [head] }
      return head |> tail.dropLast()
    }
  }
  /**
  Returns a `LazyList` containing all but the first N elements.
  
  - Complexity: O(n)
  */
  public func dropFirst(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _) ,(_, .Nil): return self
    case (_, let .Cons(_, tail)): return tail().dropFirst(n - 1)
    }
  }
  
  private func divide(at: Int) -> (LazyList<Element>, LazyList<Element>) {
    switch (at, self) {
    case (0, _), (_, .Nil): return (.Nil, self)
    case (_, let .Cons(head, tail)):
      let (front, back) = tail().divide(at - 1)
      return (head |> front, back)
    }
  }
  
  private func dropLast(var ahead: ContiguousDeque<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      ahead.append(head)
      return ahead.removeFirst() |> tail().dropLast(ahead)
    }
  }
  /**
  Returns a `LazyList` containing all but the last n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(n)
  */
  public func dropLast(n: Int) -> LazyList<Element> {
    let (front, back) = divide(n)
    return back.dropLast(ContiguousDeque(front))
  }
  
  /**
  Returns a `LazyList` with `with` appended.
  
  - Complexity: O(`count`)
  */
  
  public func appended(@autoclosure(escaping) with: () -> Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Cons(with(), {.Nil})
    case let .Cons(head, tail): return head |> tail().appended(with)
    }
  }
  
  /**
  Returns a `LazyList` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended(@autoclosure(escaping) with: () -> LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return with()
    case let .Cons(head, tail): return head |> tail().extended(with)
    }
  }
  
  /**
  Returns a `LazyList` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended<S : SequenceType where S.Generator.Element == Element>(@autoclosure(escaping) with: () -> S) -> LazyList<Element> {
    return extended(LazyList(with()))
  }
  
  /**
  Returns `self` with `n` elements dropped.
  
  - Complexity: `n`
  */
  
  public func suffixFrom(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return self
    case let (_, .Cons(_, tail)): return tail().suffixFrom(n - 1)
    }
  }
  
  /**
  Returns a `LazyList` of the initial elements of `self`, of maximum length `n`.
  */
  
  public func prefix(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case let (_, .Cons(head, tail)): return head |> tail().prefix(n - 1)
    }
  }
  
  /**
  Returns a `LazyList` of the final elements of `self`, of maximum length `n`.
  */
  
  public func suffix(n: Int) -> LazyList<Element> {
    return reverse().prefix(n).reverse()
  }
  
  private func divide(maxSplit: Int, @noescape isSplit: Element -> Bool) -> (LazyList<Element>, LazyList<Element>) {
    switch (maxSplit, self) {
    case (0, _), (_, .Nil): return (.Nil, self)
    case (_, let .Cons(head, tail)):
      if isSplit(head) { return (.Nil, tail()) }
      let (front, back) = tail().divide(maxSplit - 1, isSplit: isSplit)
      return (head |> front, back)
    }
  }
  
  /**
  Returns the maximal `LazyList`s of `self`, in order, that don't contain
  elements satisfying the predicate `isSeparator`.
  
  - Parameter maxSplits: The maximum number of `LazyList`s to return, minus 1.
  If `maxSplit` + 1 `LazyList`s are returned, the last one is a suffix of
  `self` containing the remaining elements. The default value is `Int.max`.
  - Parameter allowEmptySubsequences: If `true`, an empty `LazyList` is
  produced in the result for each pair of consecutive elements satisfying `isSeparator`.
  The default value is false.
  - Requires: maxSplit >= 0
  */
  public func split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: Element -> Bool) -> [LazyList<Element>] {
    switch self {
    case .Nil: return []
    default:
      let (front, back) = divide(maxSplit, isSplit: isSeparator)
      let rest = back.split(maxSplit, allowEmptySlices: allowEmptySlices, isSeparator: isSeparator)
      return (!front.isEmpty || allowEmptySlices) ? [front] + rest : rest
    }
  }
  /// :nodoc:
  public func map<T>(transform: Element -> T) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head) |> tail().map(transform)
    }
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> LazyList<T>) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head).extended(tail().flatMap(transform))
    }
  }
  /// :nodoc:
  public func flatMap<S : SequenceType>(transform: Element -> S) -> LazyList<S.Generator.Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return LazyList<S.Generator.Element>(transform(head)).extended(tail().flatMap(transform))
    }
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> T?) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return transform(head).map { $0 |> tail().flatMap(transform) } ?? tail().flatMap(transform)
    }
  }
  /**
  Return a value less than or equal to the number of elements in `self`,
  **nondestructively**.
  */
  public func underestimateCount() -> Int {
    return 0
  }
  /**
  Remove the first element and return it.
  
  - Complexity: O(1)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst() -> Element {
    switch self {
    case .Nil: fatalError("Cannot call removeFirst() on an empty LazyList")
    case let .Cons(head, tail):
      self = tail()
      return head
    }
  }
  /**
  Remove the first element and return it, if it exists. Otherwise, return `nil`.
  
  - Complexity: O(1)
  */
  public mutating func popFirst() -> Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, tail):
      self = tail()
      return head
    }
  }
  /**
  Return `self` prepended with the elements of `with`.
  */
  public func prextended(with: LazyList<Element>) -> LazyList<Element> {
    return with.extended(self)
  }
  /**
  Return `self` prepended with the elements of `with`.
  */
  public func prextended<S : SequenceType where S.Generator.Element == Element>(newElements: S) -> LazyList<Element> {
    return LazyList(newElements).extended(self)
  }
  /// :nodoc:
  public func filter(includeElement: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return includeElement(head) ?
        head |> tail().filter(includeElement) :
        tail().filter(includeElement)
    }
  }

  private func rev(other: LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return other
    case let .Cons(head, tail): return tail().rev(head |> other)
    }
  }
  /// :nodoc:
  public func reverse() -> LazyList<Element> {
    return rev(.Nil)
  }
  /**
  Returns a `LazyList` of the result of calling `combine` on successive elements of `self`
  
  ```swift
  let nums: LazyList = [1, 2, 3]
  nums.scan(0, combine: +)
  // [1, 3, 6]
  ```
  */
  public func scan<T>(initial: T, combine: (accumulator: T, element: Element) -> T) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let cur = combine(accumulator: initial, element: head)
      return cur |> tail().scan(cur, combine: combine)
    }
  }
  /**
  Returns a `LazyList` of the result of calling `combine` on successive elements of
  `self`. Initial is taken to be the first element of `self`.
  
  ```swift
  let nums: LazyList = [1, 2, 3]
  nums.scan(+)
  // [3, 6]
  ```
  */
  public func scan(combine: (accumulator: Element, element: Element) -> Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return tail().scan(head, combine: combine)
    }
  }
  
  /// Return the result of repeatedly calling combine with an initial value and each element
  /// of self, in turn, i.e. return combine(combine(...combine(combine(self[0], self[1]),
  /// self[2]),...self[count-2]), self[count-1]).
  ///
  /// ```swift
  /// [1, 2, 3].reduce(+) // 6
  /// ```
  
  public func reduce<T>(initial: T, @noescape combine: (accumulator: T, element: Element) -> T) -> T {
    switch self {
    case .Nil: return initial
    case let .Cons(head, tail):
      return tail().reduce(combine(accumulator: initial, element: head), combine: combine)
    }
  }
  
  /// Return the result of repeatedly calling combine with an accumulated value
  /// initialized to the first element of self and each element of self, in turn, i.e.
  /// return combine(combine(...combine(combine(self[0], self[1]),
  /// self[2]),...self[count-2]), self[count-1]).
  ///
  /// ```swift
  /// [1, 2, 3].reduce(+) // 6
  /// ```
  
  public func reduce(@noescape combine: (accumulator: Element, element: Element) -> Element) -> Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, tail): return tail().reduce(head, combine: combine)
    }
  }
  
  /**
  Returns a `LazyList` of the initial elements of `self`, up until the first element that
  returns false for `isElement`
  */
  
  public func prefixWhile(isElement: Element -> Bool) -> LazyList<Element> {
    switch self {
    case let .Cons(head, tail) where isElement(head):
      return head |> tail().prefixWhile(isElement)
    default: return .Nil
    }
  }
  
  /**
  Returns a `LazyList` of `self` with the first elements that satisfy `isNotElement` 
  dropped.
  */
  
  public func dropWhile(@noescape isNotElement: Element -> Bool) -> LazyList<Element> {
    switch self {
    case let .Cons(head, tail) where isNotElement(head):
      return tail().dropWhile(isNotElement)
    default: return self
    }
  }
}