import Combine

extension CurrentValuePublisher {
    
    /// Returns a new `CurrentValuePublisher` that combines the current value and subsequent values
    /// from this publisher with those from another `CurrentValuePublisher`.
    ///
    /// The returned publisher emits a tuple containing the latest values from both publishers
    /// whenever the value of either publisher changes.
    ///
    /// - Parameter other: Another `CurrentValuePublisher` to combine with.
    /// - Returns: A `CurrentValuePublisher` that emits tuples of the latest values from both
    ///   publishers.
    public func combineLatest<T>(
        _ other: CurrentValuePublisher<T, Failure>
    ) -> CurrentValuePublisher<(Output, T), Failure> {
        switch (self.storage, other.storage) {
        case (.constant, .constant):
            return CurrentValuePublisher<(Output, T), Failure>(
                value: (self.value, other.value)
            )
        default:
            return CurrentValuePublisher<(Output, T), Failure>(
                initial: (self.value, other.value),
                upstream: Publishers.CombineLatest(self, other).dropFirst()
            )
        }
    }

}

extension CurrentValuePublisher {

    /// Returns a new `CurrentValuePublisher` that combines the current values and subsequent
    /// values from two publishers.
    ///
    /// The returned publisher emits a tuple containing the latest values from both publishers
    /// whenever the value of either publisher changes.
    ///
    /// - Parameters:
    ///   - a: The first `CurrentValuePublisher` to combine.
    ///   - b: The second `CurrentValuePublisher` to combine.
    /// - Returns: A `CurrentValuePublisher` that emits tuples of the latest values from both
    ///   publishers.
    public static func combineLatest<A, B>(
        _ a: CurrentValuePublisher<A, Failure>,
        _ b: CurrentValuePublisher<B, Failure>
    ) -> CurrentValuePublisher<(A, B), Failure> where Output == (A, B) {
        a.combineLatest(b)
    }

    /// Returns a new `CurrentValuePublisher` that combines the current values and subsequent
    /// values from three publishers.
    ///
    /// The returned publisher emits a tuple containing the latest values from all three publishers
    /// whenever the value of any publisher changes.
    ///
    /// - Parameters:
    ///   - a: The first `CurrentValuePublisher` to combine.
    ///   - b: The second `CurrentValuePublisher` to combine.
    ///   - c: The third `CurrentValuePublisher` to combine.
    /// - Returns: A `CurrentValuePublisher` that emits tuples of the latest values from all three
    ///   publishers.
    public static func combineLatest<A, B, C>(
        _ a: CurrentValuePublisher<A, Failure>,
        _ b: CurrentValuePublisher<B, Failure>,
        _ c: CurrentValuePublisher<C, Failure>
    ) -> CurrentValuePublisher<(A, B, C), Failure> where Output == (A, B, C) {
        a.combineLatest(b)
            .combineLatest(c)
            .map { ($0.0, $0.1, $1) }
    }

    /// Returns a new `CurrentValuePublisher` that combines the current values and subsequent
    /// values from four publishers.
    ///
    /// The returned publisher emits a tuple containing the latest values from all four publishers
    /// whenever the value of any publisher changes.
    ///
    /// - Parameters:
    ///   - a: The first `CurrentValuePublisher` to combine.
    ///   - b: The second `CurrentValuePublisher` to combine.
    ///   - c: The third `CurrentValuePublisher` to combine.
    ///   - d: The fourth `CurrentValuePublisher` to combine.
    /// - Returns: A `CurrentValuePublisher` that emits tuples of the latest values from all four
    ///   publishers.
    public static func combineLatest<A, B, C, D>(
        _ a: CurrentValuePublisher<A, Failure>,
        _ b: CurrentValuePublisher<B, Failure>,
        _ c: CurrentValuePublisher<C, Failure>,
        _ d: CurrentValuePublisher<D, Failure>
    ) -> CurrentValuePublisher<(A, B, C, D), Failure> where Output == (A, B, C, D) {
        a.combineLatest(b)
            .combineLatest(c)
            .combineLatest(d)
            .map { ($0.0.0, $0.0.1, $0.1, $1) }
    }

}
