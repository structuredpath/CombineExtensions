import Combine

extension CurrentValuePublisher {
    
    /// Produces a new `CurrentValuePublisher` by transforming the current value and all subsequent
    /// values into new `CurrentValuePublisher` instances, and republishing the values emitted
    /// by the most recently transformed inner publisher.
    ///
    /// Use this operator to dynamically switch between publishers based on the current value
    /// while maintaining a `CurrentValuePublisher` interface.
    ///
    /// - Parameter transform: A closure that transforms a value to a new `CurrentValuePublisher`.
    /// - Returns: A `CurrentValuePublisher` that emits the values from the most recently
    ///   transformed inner publisher.
    ///
    /// - SeeAlso: `Publisher.flatMapLatest(_:)`
    public func flatMapLatest<T>(
        _ transform: @escaping (Output) -> CurrentValuePublisher<T, Failure>
    ) -> CurrentValuePublisher<T, Failure> {
        let currentInnerPublisher = transform(value)
        
        switch (self.storage, currentInnerPublisher.storage) {
        case (.constant, .constant):
            // If the outer and inner publishers are both constant, we need to pass on this
            // characteristic to the outside by using the appropriate initializer.
            return CurrentValuePublisher<T, Failure>(value: currentInnerPublisher.value)
        default:
            let initial = currentInnerPublisher.value
            
            let upstream = Publishers.Merge(
                // The publisher of a single publisher of remaining values produced by the current
                // inner publisher (excluding its current value).
                Just(currentInnerPublisher.dropFirst().eraseToAnyPublisher())
                    .setFailureType(to: Failure.self),
                
                // The publisher of subsequent inner publishers.
                self.dropFirst()
                    .map(transform)
                    .map { $0.eraseToAnyPublisher() }
            ).switchToLatest()
            
            return CurrentValuePublisher<T, Failure>(
                initial: initial,
                upstream: upstream
            )
        }
    }
    
}
