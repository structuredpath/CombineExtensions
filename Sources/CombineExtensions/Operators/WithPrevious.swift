import Combine

extension Publisher {
    
    /// Transforms elements from the upstream publisher into a tuple containing the current and
    /// the previous element, where the previous element is optional.
    ///
    /// The first tuple emitted will contain `nil` for the previous element and the first element
    /// from the upstream publisher as the current element. Subsequent tuples will include the
    /// current element from the previous emission as the previous element.
    ///
    ///     let range = (1...5)
    ///     cancellable = range.publisher
    ///         .withPrevious()
    ///         .sink { print("(\($0.previous), \($0.current))") }
    ///     // Prints: "(nil, 1) (Optional(1), 2) (Optional(2), 3) (Optional(3), 4) (Optional(4), 5)"
    ///
    /// - Returns: A publisher that emits a tuple of the previous and current elements from the
    ///   upstream publisher.
    ///
    /// - Note: Until version 0.3.0 of the library, this was implemented using `.scan` (see
    ///   [this post](https://stackoverflow.com/a/67133582/670119)). However, that approach
    ///   strongly retained previous values and could keep them in memory longer than expected
    ///   when `Output` was a reference type. This version avoids that by using a local variable
    ///   inside `map`, which does not retain previous values beyond each emission.
    public func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        var previous: Output?
        return self
            .map { current in
                defer { previous = current }
                return (previous: previous, current: current)
            }
            .eraseToAnyPublisher()
    }
    
    /// Transforms elements from the upstream publisher into a tuple containing the current and
    /// the previous element, starting with the specified initial value.
    ///
    /// The first tuple emitted will use the provided `initialValue` as the previous element and
    /// the first element from the upstream publisher as the current element. Subsequent tuples
    /// will include the current element from the previous emission as the previous element.
    ///
    ///     let range = (1...5)
    ///     cancellable = range.publisher
    ///         .withPrevious(initialValue: 0)
    ///         .sink { print("(\($0.previous), \($0.current))") }
    ///     // Prints: "(0, 1) (1, 2) (2, 3) (3, 4) (4, 5)"
    ///
    /// - Parameter initialValue: The initial value to use as the previous element for the first
    ///   emission.
    /// - Returns: A publisher that emits a tuple of the previous and current elements from the
    ///   upstream publisher.
    ///
    /// - Note: Until version 0.3.0 of the library, this was implemented using `.scan` (see
    ///   [this post](https://stackoverflow.com/a/67133582/670119)). However, that approach
    ///   strongly retained previous values and could keep them in memory longer than expected
    ///   when `Output` was a reference type. This version avoids that by using a local variable
    ///   inside `map`, which does not retain previous values beyond each emission.
    public func withPrevious(
        initialValue: Output
    ) -> AnyPublisher<(previous: Output, current: Output), Failure> {
        var previous = initialValue
        return self
            .map { current in
                defer { previous = current }
                return (previous: previous, current: current)
            }
            .eraseToAnyPublisher()
    }
    
}
