class Stack<Element> {
  var items = [Reference<Element>]()

  var count: Int {
    items.count
  }

  var peek: Reference<Element>? {
    items.last
  }

  var isEmpty: Bool {
    items.isEmpty
  }

  func push(_ item: Element) {
    items.append(Reference(value: item))
  }

  @discardableResult
  func pop() -> Reference<Element>? {
    items.popLast()
  }
}

@dynamicMemberLookup
class Reference<Value> {
  var value: Value

  init(value: Value) {
    self.value = value
  }

  subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
    value[keyPath: keyPath]
  }
}
