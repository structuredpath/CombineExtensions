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
