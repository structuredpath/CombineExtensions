import Combine

extension CurrentValuePublisher where Output == Bool {
    
    /// Returns a new `CurrentValuePublisher` that computes the logical AND of the current value
    /// and subsequent values of this publisher with those of another `CurrentValuePublisher`.
    ///
    /// The resulting publisher emits `true` only when the latest values from both publishers
    /// are `true`.
    ///
    /// - Parameter other: Another `CurrentValuePublisher` of `Bool` to combine with.
    /// - Returns: A `CurrentValuePublisher` that emits the logical AND of the latest values.
    public func and(
        _ other: CurrentValuePublisher<Bool, Failure>
    ) -> CurrentValuePublisher<Bool, Failure> {
        return self.combineLatest(other).map { $0 && $1 }
    }
    
    /// Returns a new `CurrentValuePublisher` that computes the logical OR of the current value
    /// and subsequent values of this publisher with those of another `CurrentValuePublisher`.
    ///
    /// The resulting publisher emits `true` if the latest value from either publisher is `true`.
    ///
    /// - Parameter other: Another `CurrentValuePublisher` of `Bool` to combine with.
    /// - Returns: A `CurrentValuePublisher` that emits the logical OR of the latest values.
    public func or(
        _ other: CurrentValuePublisher<Bool, Failure>
    ) -> CurrentValuePublisher<Bool, Failure> {
        return self.combineLatest(other).map { $0 || $1 }
    }
    
}
