extension CurrentValuePublisher {
    
    /// Produces a new `CurrentValuePublisher` by applying the given closure to the current
    /// and all subsequent values.
    ///
    /// - Parameter transform: A closure that transforms a given value.
    /// - Returns: A `CurrentValuePublisher` that emits the transformed values.
    public func map<T>(
        _ transform: @escaping (Output) -> T
    ) -> CurrentValuePublisher<T, Failure> {
        switch self.storage {
        case .constant:
            return CurrentValuePublisher<T, Failure>(
                value: transform(self.value)
            )
        case .subject:
            // We need to reference `self` in the upstream instead of using the subject extracted
            // from the storage in order to keep `self` and thus its upstream alive.
            return CurrentValuePublisher<T, Failure>(
                initial: transform(self.value),
                upstream: self.dropFirst().map(transform)
            )
        }
    }
    
}
