import Combine

// Inspired by https://stackoverflow.com/a/67133582/670119

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
    public func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        self.scan(Optional<(Output?, Output)>.none) { ($0?.1, $1) }
            .compactMap { $0 }
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
    public func withPrevious(
        initialValue: Output
    ) -> AnyPublisher<(previous: Output, current: Output), Failure> {
        self.scan((initialValue, initialValue)) { ($0.1, $1) }
            .eraseToAnyPublisher()
    }
    
}
