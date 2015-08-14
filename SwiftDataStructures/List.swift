infix operator |> {
associativity right
precedence 100
}
/**
The [cons](https://en.wikipedia.org/wiki/Cons) operator.

This operator lazy. i.e:

```swift
func printAndGiveList() -> List<Int> {
  print(2)
  return .Nil
}

2 |> 1 |> printAndGiveList()
```

Will not print 2.

- Complexity: O(1)
*/
public func |> <T>(lhs: T, @autoclosure(escaping) rhs: () -> List<T>) -> List<T> {
  return .Cons(lhs, rhs)
}

/**
A singly-linked, lazy list. Head-tail decomposition can be accomplished with a
`switch` statement:

```swift
extension List {
  public func map<T>(f: Element -> T) -> List<T> {
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

public enum List<Element> : CustomDebugStringConvertible, ArrayLiteralConvertible, GeneratorType, SequenceType {
  case Nil
  indirect case Cons(Element, () -> List<Element>)

  public typealias Generator = List<Element>
  public typealias SubSequence = List<Element>

  // MARK: Initializers

  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      self = head |> List(gen: gen)
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
    self = List(gen: seq.generate())
  }
  
  /// Create an instance containing `elements`.
  public init(arrayLiteral elements: Element...) {
    self = List(elements.generate())
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
  public func generate() -> List<Element> {
    return self
  }
  /**
  Returns a `List` containing all but the first element.
  
  - Complexity: O(1)
  */
  public func dropFirst() -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(_, tail): return tail()
    }
  }
  /**
  Returns a `List` containing all but the last element.
  
  - Complexity: O(`count`)
  */
  public func dropLast() -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let tail = tail()
      if tail.isEmpty { return .Nil }
      return head |> tail.dropLast()
    }
  }
  /**
  Returns a `List` containing all but the first N elements.
  
  - Complexity: O(n)
  */
  public func dropFirst(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _) ,(_, .Nil): return self
    case (_, let .Cons(_, tail)): return tail().dropFirst(n - 1)
    }
  }
  
  private func divide(at: Int) -> (List<Element>, List<Element>) {
    switch (at, self) {
    case (0, _), (_, .Nil): return (.Nil, self)
    case (_, let .Cons(head, tail)):
      let (front, back) = tail().divide(at - 1)
      return (head |> front, back)
    }
  }
  
  private func dropLast(var ahead: Deque<Element>) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      ahead.append(head)
      return ahead.removeFirst() |> tail().dropLast(ahead)
    }
  }
  /**
  Returns a `List` containing all but the last n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(n)
  */
  public func dropLast(n: Int) -> List<Element> {
    let (front, back) = divide(n)
    return back.dropLast(Deque(front))
  }
  
  /**
  Returns a `List` with `with` appended.
  
  - Complexity: O(`count`)
  */
  
  public func appended(@autoclosure(escaping) with: () -> Element) -> List<Element> {
    switch self {
    case .Nil: return .Cons(with(), {.Nil})
    case let .Cons(head, tail): return head |> tail().appended(with)
    }
  }
  
  /**
  Returns a `List` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended(@autoclosure(escaping) with: () -> List<Element>) -> List<Element> {
    switch self {
    case .Nil: return with()
    case let .Cons(head, tail): return head |> tail().extended(with)
    }
  }
  
  /**
  Returns a `List` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended<S : SequenceType where S.Generator.Element == Element>(@autoclosure(escaping) with: () -> S) -> List<Element> {
    return extended(List(with()))
  }

  
  /**
  Returns a `List` of the initial elements of `self`, of maximum length `n`.
  */
  
  public func prefix(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case let (_, .Cons(head, tail)): return head |> tail().prefix(n - 1)
    }
  }
  
  /**
  Returns a `List` of the final elements of `self`, of maximum length `n`.
  */
  
  public func suffix(n: Int) -> List<Element> {
    return zip(0..<n, reverse()).reduce(List.Nil) { $1.1 |> $0 }
  }
  
  private func divide(@noescape isSplit: Element -> Bool) -> (List<Element>, List<Element>) {
    switch self {
    case .Nil: return (.Nil, .Nil)
    case let .Cons(head, tail):
      if isSplit(head) { return (.Nil, tail()) }
      let (front, back) = tail().divide(isSplit)
      return (head |> front, back)
    }
  }
  
  /**
  Returns the maximal `List`s of `self`, in order, that don't contain
  elements satisfying the predicate `isSeparator`.
  
  - Parameter maxSplits: The maximum number of `List`s to return, minus 1.
  If `maxSplit` + 1 `List`s are returned, the last one is a suffix of
  `self` containing the remaining elements. The default value is `Int.max`.
  - Parameter allowEmptySubsequences: If `true`, an empty `List` is
  produced in the result for each pair of consecutive elements satisfying `isSeparator`.
  The default value is false.
  - Requires: maxSplit >= 0
  */
  public func split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: Element -> Bool) -> [List<Element>] {
    if isEmpty || maxSplit == 0 { return [] }
    let (front, back) = divide(isSeparator)
    let rest = back.split(maxSplit - 1, allowEmptySlices: allowEmptySlices, isSeparator: isSeparator)
    return (!front.isEmpty || allowEmptySlices) ? [front] + rest : rest
  }
  /// :nodoc:
  public func map<T>(transform: Element -> T) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head) |> tail().map(transform)
    }
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> List<T>) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head).extended(tail().flatMap(transform))
    }
  }
  /// :nodoc:
  public func flatMap<S : SequenceType>(transform: Element -> S) -> List<S.Generator.Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return List<S.Generator.Element>(transform(head)).extended(tail().flatMap(transform))
    }
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> T?) -> List<T> {
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
    case .Nil: fatalError("Cannot call removeFirst() on an empty List")
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
  public func prextended(with: List<Element>) -> List<Element> {
    return with.extended(self)
  }
  /**
  Return `self` prepended with the elements of `with`.
  */
  public func prextended<S : SequenceType where S.Generator.Element == Element>(newElements: S) -> List<Element> {
    return List(newElements).extended(self)
  }
  /// :nodoc:
  public func filter(includeElement: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return includeElement(head) ?
        head |> tail().filter(includeElement) :
        tail().filter(includeElement)
    }
  }

  private func rev(other: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return other
    case let .Cons(head, tail): return tail().rev(head |> other)
    }
  }
  /// :nodoc:
  public func reverse() -> List<Element> {
    return rev(.Nil)
  }
  /**
  Returns a `List` of the result of calling `combine` on successive elements of `self`
  
  ```swift
  let nums: List = [1, 2, 3]
  nums.scan(0, combine: +)
  // [1, 3, 6]
  ```
  */
  public func scan<T>(initial: T, combine: (accumulator: T, element: Element) -> T) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let cur = combine(accumulator: initial, element: head)
      return cur |> tail().scan(cur, combine: combine)
    }
  }
  /**
  Returns a `List` of the result of calling `combine` on successive elements of
  `self`. Initial is taken to be the first element of `self`.
  
  ```swift
  let nums: List = [1, 2, 3]
  nums.scan(+)
  // [3, 6]
  ```
  */
  public func scan(combine: (accumulator: Element, element: Element) -> Element) -> List<Element> {
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
  Returns a `List` of the initial elements of `self`, up until the first element that
  returns false for `isElement`
  */
  
  public func prefixWhile(isElement: Element -> Bool) -> List<Element> {
    switch self {
    case let .Cons(head, tail) where isElement(head):
      return head |> tail().prefixWhile(isElement)
    default: return .Nil
    }
  }
  
  /**
  Returns a `List` of `self` with the first elements that satisfy `isNotElement` 
  dropped.
  */
  
  public func dropWhile(@noescape isNotElement: Element -> Bool) -> List<Element> {
    switch self {
    case let .Cons(head, tail) where isNotElement(head):
      return tail().dropWhile(isNotElement)
    default: return self
    }
  }
}