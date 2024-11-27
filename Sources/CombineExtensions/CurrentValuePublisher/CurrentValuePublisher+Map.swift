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
    
#if compiler(<6.0)

extension CurrentValuePublisher {
    
    /// Produces a new `CurrentValuePublisher` by extracting a value from the current and all
    /// subsequent values using the given key path.
    ///
    /// This overload is provided for Swift versions prior to 6.0, where key path inference
    /// in `map` is not fully supported.
    ///
    /// - Parameter keyPath: A key path to extract a property of a value.
    /// - Returns: A `CurrentValuePublisher` that emits the values extracted by the given key path.
    public func map<T>(
        _ keyPath: KeyPath<Output, T>
    ) -> CurrentValuePublisher<T, Failure> {
        self.map { $0[keyPath: keyPath] }
    }
    
}

#endif
