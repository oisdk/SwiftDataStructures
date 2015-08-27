// MARK: Cons
infix operator |> { associativity right precedence 100}
/**
The [cons](https://en.wikipedia.org/wiki/Cons) operator.

This operator is lazy. i.e:

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

// MARK: Definition

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

Or a `guard case`:

```swift
extension List {
  public func map<T>(transform: Element -> T) -> List<T> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return transform(x) |> xs().map(transform)
  }
}
```

Where `|>` is the [cons](https://en.wikipedia.org/wiki/Cons) operator.

Operations on the beginning of the list are O(1), whereas other operations are O(n).

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/07/29/deques-queues-and-lists-in-swift-with-indirect/).

Full documentation is available [here](http://oisdk.github.io/SwiftDataStructures/Enums/List.html).
*/

public enum List<Element> {
  case Nil
  case Cons(Element, () -> List<Element>)
}

// MARK: SequenceType

extension List: GeneratorType, LazySequenceType {
  /**
  Returns the next element if it exists, or nil if it does not.
  */
  public mutating func next() -> Element? {
    guard case let .Cons(head, tail) = self else { return nil }
    self = tail()
    return head
  }
}

// MARK: Initializers

extension List : ArrayLiteralConvertible {
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
}

// MARK: DebugDescription

extension List : CustomDebugStringConvertible {
  
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return Array(self).debugDescription
  }
}

// MARK: Properties

extension List {
  /**
  The number of elements in `self`
  
  - Complexity: O(`count`)
  */
  
  public var count: Int {
    guard case let .Cons(_, t) = self else { return 0 }
    return t().count.successor()
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
    if case let .Cons(h, _) = self { return h }
    return nil
  }
  /**
  Returns the last element of `self`, if it exists, or `nil` if `self` is empty.
  
  - Complexity: O(`count`)
  */
  public var last: Element? {
    guard case let .Cons(x, xs) = self else { return nil }
    let t = xs()
    return t.isEmpty ? x : t.last
  }
}

// MARK: -ending

extension List {
  /**
  Returns a `List` with `with` appended.
  
  - Complexity: O(`count`)
  */
  
  public func appended(@autoclosure(escaping) with: () -> Element) -> List<Element> {
    guard case let .Cons(x, xs) = self else { return [with()] }
    return x |> xs().appended(with)
  }
  
  /**
  Returns a `List` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended(@autoclosure(escaping) with: () -> List<Element>) -> List<Element> {
    guard case let .Cons(x, xs) = self else { return with() }
    return x |> xs().extended(with)
  }
  
  /**
  Returns a `List` extended by the elements of `with`.
  
  - Complexity: O(`count`)
  */
  
  public func extended<
    S : SequenceType where S.Generator.Element == Element
    >(@autoclosure(escaping) with: () -> S) -> List<Element> {
      return extended(List(with()))
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
  public func prextended<
    S : SequenceType where S.Generator.Element == Element
    >(newElements: S) -> List<Element> {
      return List(newElements).extended(self)
  }
}

// MARK: Dropping

extension List {
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
    case (_, let .Cons(x, xs)):
      let (front, back) = xs().divide(at - 1)
      return (x |> front, back)
    }
  }
  
  private func dropLast(var ahead: Deque<Element>) -> List<Element> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    ahead.append(x)
    return ahead.removeFirst() |> xs().dropLast(ahead)
  }
  /**
  Returns a `List` containing all but the last n elements.
  
  - Requires: `n >= 0`
  - Complexity: O(`count`)
  */
  public func dropLast(n: Int) -> List<Element> {
    let (front, back) = divide(n)
    return back.dropLast(Deque(front))
  }
}

// MARK: Conditional Dropping

extension List {
  /**
  Returns a `List` of the initial elements of `self`, up until the first element that
  returns false for `isElement`
  */
  
  public func prefixWhile(isElement: Element -> Bool) -> List<Element> {
    switch self {
    case let .Cons(x, xs) where isElement(x):
      return x |> xs().prefixWhile(isElement)
    default: return .Nil
    }
  }
  
  /**
  Returns a `List` of `self` with the first elements that satisfy `isNotElement`
  dropped.
  */
  
  public func dropWhile(@noescape isNotElement: Element -> Bool) -> List<Element> {
    switch self {
    case let .Cons(x, xs) where isNotElement(x):
      return xs().dropWhile(isNotElement)
    default: return self
    }
  }
}

// MARK: Slicing

extension List {
  /**
  Returns a `List` of the initial elements of `self`, of maximum length `n`.
  */
  
  public func prefix(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case let (_, .Cons(x, xs)): return x |> xs().prefix(n - 1)
    }
  }
  
  /**
  Returns a `List` of the final elements of `self`, of maximum length `n`.
  */
  
  public func suffix(n: Int) -> List<Element> {
    return zip(0..<n, reverse()).reduce(List.Nil) { $1.1 |> $0 }
  }
  
  private func divide(@noescape isSplit: Element throws -> Bool) rethrows -> (List<Element>, List<Element>) {
    guard case let .Cons(x, xs) = self else { return (.Nil, .Nil) }
    if try isSplit(x) { return (.Nil, xs()) }
    let (front, back) = try xs().divide(isSplit)
    return (x |> front, back)
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
  public func split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: Element throws -> Bool) rethrows -> [List<Element>] {
    if isEmpty || maxSplit == 0 { return [] }
    let (front, back) = try divide(isSeparator)
    let rest = try back.split(maxSplit - 1, allowEmptySlices: allowEmptySlices, isSeparator: isSeparator)
    return (!front.isEmpty || allowEmptySlices) ? [front] + rest : rest
  }
}

// MARK: Stacklike

extension List {
  /**
  Remove the first element and return it.
  
  - Complexity: O(1)
  - Requires: `!self.isEmpty`.
  */
  public mutating func removeFirst() -> Element {
    guard case let .Cons(x, xs) = self else { fatalError("Cannot call removeFirst() on an empty List") }
    self = xs()
    return x
  }
  /**
  Remove the first element and return it, if it exists. Otherwise, return `nil`.
  
  - Complexity: O(1)
  */
  public mutating func popFirst() -> Element? {
    guard case let .Cons(x, xs) = self else { return nil }
    self = xs()
    return x
  }
}

// MARK: Reverse

extension List {
  private func rev(other: List<Element>) -> List<Element> {
    guard case let .Cons(x, xs) = self else { return other }
    return xs().rev(x |> other)
  }
  /// :nodoc:
  public func reverse() -> List<Element> {
    return rev(.Nil)
  }
}

// MARK: Higher-Order

extension List {
  /// :nodoc:
  public func map<T>(transform: Element -> T) -> List<T> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return transform(x) |> xs().map(transform)
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> List<T>) -> List<T> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return transform(x).extended(xs().flatMap(transform))
  }
  /// :nodoc:
  public func flatMap<S : SequenceType>(transform: Element -> S) -> List<S.Generator.Element> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return List<S.Generator.Element>(transform(x)).extended(xs().flatMap(transform))
  }
  /// :nodoc:
  public func flatMap<T>(transform: Element -> T?) -> List<T> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return transform(x).map { $0 |> xs().flatMap(transform) } ?? xs().flatMap(transform)
  }
  /// :nodoc:
  public func filter(includeElement: Element -> Bool) -> List<Element> {
    guard case let .Cons(x, xs) = self else { return .Nil }
    return includeElement(x) ?
      x |> xs().filter(includeElement) :
      xs().filter(includeElement)
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
    guard case let .Cons(x, xs) = self else { return .Nil }
    let cur = combine(accumulator: initial, element: x)
    return cur |> xs().scan(cur, combine: combine)
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
    guard case let .Cons(x, xs) = self else { return .Nil }
    return xs().scan(x, combine: combine)
  }
  
  /// Return the result of repeatedly calling combine with an initial value and each element
  /// of self, in turn, i.e. return combine(combine(...combine(combine(self[0], self[1]),
  /// self[2]),...self[count-2]), self[count-1]).
  ///
  /// ```swift
  /// [1, 2, 3].reduce(+) // 6
  /// ```
  
  public func reduce<T>(initial: T, @noescape combine: (accumulator: T, element: Element) -> T) -> T {
    guard case let .Cons(x, xs) = self else { return initial }
    return xs().reduce(combine(accumulator: initial, element: x), combine: combine)
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
    guard case let .Cons(x, xs) = self else { return nil }
    return xs().reduce(x, combine: combine)
  }
  
  /**
  The same as the `reduce` function, except that `combine` is called on `self` in reverse,
  and the arguments are flipped.
  */
  
  public func reduceR<T>(initial: T, combine: (element: Element, accumulator: T) -> T) -> T {
    guard case let .Cons(x, xs) = self else { return initial }
    return combine(element: x, accumulator: xs().reduceR(initial, combine: combine))
  }
  
  /**
  The same as the `reduce` function, except that `combine` is called on `self` in reverse,
  and the arguments are flipped. The initial agument to `accumulator` for `combine` is 
  taken as the final element of `self`.
  */
  
  public func reduceR(combine: (element: Element, accumulator: Element) -> Element) -> Element? {
    guard case let .Cons(x, xs) = self else { return nil }
    guard let ac = xs().reduceR(combine) else { return x }
    return combine(element: x, accumulator: ac)
  }
}
