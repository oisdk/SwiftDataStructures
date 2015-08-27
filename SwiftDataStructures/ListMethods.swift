extension List {
  public func tails() -> List<List> {
    guard case let .Cons(_, xs) = self else { return .Nil }
    return self |> xs().tails()
  }
}

extension List where Element : Hashable {
  private func uniqs(past: Set<Element>) -> List {
    guard case let .Cons(x, xs) = self else { return .Nil }
    if past.contains(x) { return xs().uniqs(past) }
    return x |> xs().uniqs(past.union([x]))
  }
  public func uniques() -> List { return uniqs([]) }
}

func product<T>(seqs: List<List<T>>) -> List<List<T>> {
  guard case let .Cons(s, ss) = seqs else { return [[]] }
  let rest = product(ss())
  return s.flatMap { x in rest.map { x |> $0 } }
}