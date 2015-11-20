[![Build Status](https://travis-ci.org/oisdk/SwiftDataStructures.svg?branch=master)](https://travis-ci.org/oisdk/SwiftDataStructures)

[Full documentation here](http://oisdk.github.io/SwiftDataStructures/index.html )

# SwiftDataStructures

SwiftDataStructures is a framework of commonly-used data structures for Swift.

Included:

## Deque ##

A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues. This implementation has a front queue, which is reversed, and a back queue,
which is not. Operations at either end of the Deque have the same complexity as operations
on the end of either queue.

Three structs conform to the `DequeType` protocol: `Deque`, `DequeSlice`, and
`ContiguousDeque`. These correspond to the standard library array types.

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/08/09/yet-another-root-of-all-evil/).

## List ##

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

## Trie ##

A [Trie](https://en.wikipedia.org/wiki/Trie) is a prefix tree data structure. It has
set-like operations and properties. Instead of storing hashable elements, however, it
stores *sequences* of hashable elements. As well as set operations, the Trie can be
searched by prefix. Insertion, deletion, and searching are all O(`n`), where `n` is the
length of the sequence being searched for.

![Trie](https://upload.wikimedia.org/wikipedia/commons/b/be/Trie_example.svg "Trie")

Discussion of this specific implementation is available
[here](https://bigonotetaking.wordpress.com/2015/08/11/a-trie-in-swift/).

## Tree ##

A [red-black binary search tree](https://en.wikipedia.org/wiki/Red–black_tree). Adapted
from Airspeed Velocity's [implementation](http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/),
Chris Okasaki's [Purely Functional Data Structures](http://www.cs.cmu.edu/~rwh/theses/okasaki.pdf),
and Stefan Kahrs' [Red-black trees with types](http://dl.acm.org/citation.cfm?id=968482),
which is implemented in the [Haskell standard library](https://hackage.haskell.org/package/llrbtree-0.1.1/docs/Data-Set-RBTree.html).

Elements must be comparable with [Strict total order](https://en.wikipedia.org/wiki/Total_order#Strict_total_order).
