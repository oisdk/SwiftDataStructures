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

extension List {
  private func mMap<T>(f: Element -> T?) -> List<T>? {
    guard case let .Cons(x, xs) = self else { return .Nil }
    guard let fx = f(x), fxs = xs().mMap(f) else { return nil }
    return fx |> fxs
  }
}

private func uncons<T>(l: List<T>) -> (T, List<T>)? {
  guard case let .Cons(x, xs) = l else { return nil }
  return (x, xs())
}

private func frst<T, U>(t: (T, U)) -> T { return t.0 }
private func scnd<T, U>(t: (T, U)) -> U { return t.1 }

func transpose<T>(seqs: List<List<T>>) -> List<List<T>> {
  return seqs.mMap(uncons).map { ps in ps.map(frst) |> transpose(ps.map(scnd)) } ?? .Nil
}