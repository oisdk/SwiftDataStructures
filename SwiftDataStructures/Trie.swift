/**
A [Trie](https://en.wikipedia.org/wiki/Trie) is a prefix tree data structure. It has
set-like operations and properties. Instead of storing hashable elements, however, it
stores *sequences* of hashable elements. As well as set operations, the Trie can be
searched by prefix. Insertion, deletion, and searching are all O(`n`), where `n` is the
length of the sequence being searched for.

![Trie](https://upload.wikimedia.org/wikipedia/commons/b/be/Trie_example.svg "Trie")

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/08/11/a-trie-in-swift/).
*/

public struct Trie<Element : Hashable> : CustomDebugStringConvertible, Equatable, SequenceType {
  private var children: [Element:Trie<Element>]
  private var endHere : Bool
  
  // MARK: Initializers
  
  /// Create an empty `Trie`
  public init() {
    children = [:]
    endHere  = false
  }
  
  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      (children, endHere) = ([head:Trie(gen:gen)], false)
    } else {
      (children, endHere) = ([:], true)
    }
  }

  private mutating func insert<
    G : GeneratorType where G.Element == Element
    >(var gen: G) {
      if let head = gen.next() {
        children[head]?.insert(gen) ?? {children[head] = Trie(gen: gen)}()
      } else {
        endHere = true
      }
  }

  /// Construct from an arbitrary sequence of sequences with elements of type `Element`.
  public init<
    S : SequenceType, IS : SequenceType where
    S.Generator.Element == IS,
    IS.Generator.Element == Element
    >(_ seq: S) {
      self.init()
      for word in seq { insert(word) }
  }
  
  /// Construct from an arbitrary sequence with elements of type `Element`.
  public init
    <S : SequenceType where S.Generator.Element == Element>
    (_ seq: S) {
      self.init(gen: seq.generate())
  }
  
  // MARK: Instance Properties
  
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return ", ".join(map {"".join($0.map { String(reflecting: $0) })})
  }
  
  /**
  Returns the number of members of `self`.
  
  - Complexity: O(`count`)
  */
  public var count: Int {
    return children.values.reduce(endHere ? 1 : 0) { $0 + $1.count }
  }
  
  // MARK: Instance Methods
  
  /// Insert a member into the Trie.
  public mutating func insert
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      insert(seq.generate())
  }
  
  /// Return a *generator* over the members.
  ///
  /// - Complexity: O(1).
  public func generate() -> TrieGenerator<Element>  {
    return TrieGenerator(self)
  }


  private func completions
    <G : GeneratorType where G.Element == Element>
    (var start: G) -> Trie<Element> {
      guard let head = start.next() else  { return self }
      guard let child = children[head] else { return Trie() }
      return child.completions(start)
  }
  /**
  Returns a Trie of the suffixes of the members of `self` which start with `start`.
  
  ```swift
  let words = ["hello", "hiya", "hell", "jonah", "jolly", "joseph"].map{$0.characters}
  
  let store = Trie(words)
  
  store
    .completions("jo".characters)
    .map(String.init)
  
  // ["lly", "seph", "nah"]
  ```
  */
  public func completions<S : SequenceType where S.Generator.Element == Element>(start: S) -> Trie<Element> {
    return completions(start.generate())
  }

  private mutating func remove<
    G : GeneratorType where G.Element == Element
    >(var gen g: G) -> RemoveState {
      guard let head = g.next() else {
        endHere = false
        return children.isEmpty ? .Removable : .NotRemovable
      }
      guard let removeState = children[head]?.remove(gen: g) else { return .NotPresent }
      guard case .Removable = removeState else { return removeState }
      children.removeValueForKey(head)
      return (!endHere && children.isEmpty) ? .Removable : .NotRemovable
      
  }
  /// Remove the member from the Trie and return it if it was present.
  public mutating func remove<
    S : SequenceType where S.Generator.Element == Element
    >(seq: S) -> [Element]? {
      let result = Array(seq)
      switch remove(gen: result.generate()) {
      case .NotPresent: return nil
      default: return result
      }
  }

  private func contains<
    G : GeneratorType where G.Element == Element
    >(var gen: G) -> Bool {
      guard let head = gen.next() else { return endHere }
      return children[head]?.contains(gen) ?? false
  }
  /// Returns `true` if the Trie contains a member.
  public func contains
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) -> Bool {
      return contains(seq.generate())
  }
  /// Return a new Trie with elements that are either in the Trie or a finite
  /// sequence but do not occur in both.
  public func exclusiveOr<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    > (sequence: S) -> Trie<Element> {
      var ret = self
      for element in sequence {
        if ret.contains(element) {
          ret.remove(element)
        } else {
          ret.insert(element)
        }
      }
      return ret
  }
  /// For each element of a finite sequence, remove it from the Trie if it is a
  /// common element, otherwise add it to the Trie.
  public mutating func exclusiveOrInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      for element in sequence {
        if contains(element) {
          remove(element)
        } else {
          insert(element)
        }
      }
  }
  /// Return a new set with elements common to this Trie and a finite sequence.
  public func intersect<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Trie<Element> {
      return Trie(sequence.filter(contains))
  }
  /// Remove any members of this Trie that aren't also in a finite sequence.
  public mutating func intersectInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      self = intersect(sequence)
  }
  /// Returns true if no members in the Trie are in a finite sequence.
  public func isDisjointWith<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool { return !sequence.contains(self.contains) }
  /// Returns true if the Trie is a superset of a finite sequence.
  public func isSupersetOf<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool {
      return !sequence.contains { !self.contains($0) }
  }
  /// Returns true if the set is a subset of a finite sequence.
  public func isSubsetOf<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool {
      return Trie(sequence).isSupersetOf(self)
  }
  /// Insert elements of a `Trie` into this `Trie`.
  public mutating func unionInPlace(with: Trie<Element>) {
    endHere = endHere || with.endHere
    for (head, child) in with.children {
      children[head]?.unionInPlace(child) ?? {children[head] = child}()
    }
  }
  /// Return a new Trie with elements in this Trie that do not occur
  /// in a finite sequence.
  public func subtract<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Trie<Element> {
      var result = self
      for element in sequence { result.remove(element) }
      return result
  }
  /// Remove all members in the Trie that occur in a finite sequence.
  public mutating func subtractInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      for element in sequence { remove(element) }
  }
  /// Insert elements of a finite sequence into this `Trie`.
  public mutating func unionInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) { unionInPlace(Trie(sequence)) }
  /// Return a new Trie with items in both this set and a finite sequence.
  public func union(var with: Trie<Element>) -> Trie<Element> {
    with.unionInPlace(self)
    return with
  }
  /// Return a new Trie with items in both this set and a finite sequence.
  public func union<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S)  -> Trie<Element> {
      return union(Trie(sequence))
  }

  /**
  Returns a Trie which contains the results of applying `transform` to the members of
  `self`
  */
  public func map<S : SequenceType>(@noescape transform: [Element] -> S) -> Trie<S.Generator.Element> {
    var result = Trie<S.Generator.Element>()
    for seq in self {
      result.insert(transform(seq))
    }
    return result
  }

  /**
  Returns a Trie which contains the non-nil results of applying `transform` to the members
  of `self`
  */
  public func flatMap<S : SequenceType>(@noescape transform: [Element] -> S?) -> Trie<S.Generator.Element> {
    var result = Trie<S.Generator.Element>()
    for seq in self {
      if let transformed = transform(seq) {
        result.insert(transformed)
      }
    }
    return result
  }
  /**
  Returns a Trie which contains the merged results of applying `transform` to `self`.
  */
  public func flatMap<T>(@noescape transform: [Element] -> Trie<T>) -> Trie<T> {
    var ret = Trie<T>()
    for seq in self {
      ret.unionInPlace(transform(seq))
    }
    return ret
  }

  /**
  Returns a Trie which contains the members of `self` which satisfy `includeElement`.
  */
  public func filter(@noescape includeElement: [Element] -> Bool) -> Trie<Element> {
    var ret = Trie()
    for element in self where includeElement(element) { ret.insert(element) }
    return ret
  }
}

/// :nodoc:
public struct TrieGenerator<Element : Hashable> : GeneratorType {
  private var children: DictionaryGenerator<Element, Trie<Element>>
  private var curHead : [Element]
  private var innerGen: () -> [Element]?
  /// Advance to the next element and return it, or `nil` if no next
  /// element exists.
  ///
  /// - Requires: No preceding call to `self.next()` has returned `nil`.
  public mutating func next() -> [Element]? {
    for ;; {
      if let next = innerGen() { return curHead + next }
      guard let (head, child) = children.next() else { return nil }
      curHead = [head]
      var g = child.generate()
      innerGen = {g.next()}
      if child.endHere { return curHead }
    }
  }
  private init(_ from: Trie<Element>) {
    children = from.children.generate()
    innerGen = {nil}
    curHead  = []
  }
}
private enum RemoveState {
  case NotPresent, NotRemovable, Removable
}
/// :nodoc:
public func ==<T>(lhs: Trie<T>, rhs: Trie<T>) -> Bool {
  return lhs.endHere == rhs.endHere && lhs.children == rhs.children
}