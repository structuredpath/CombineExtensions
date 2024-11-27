import Combine

extension Publisher {
    
    /// Transforms all elements from an upstream publisher into a new publisher and republishes
    /// the elements sent by the most recently transformed inner publisher to appear as if they
    /// were coming from a single stream of events.
    ///
    /// This operator switches the inner publisher as new ones arrive but keeps the outer publisher
    /// constant for downstream subscribers. When a new element arrives and a new publisher is
    /// created, it cancels the previous subscription.
    ///
    /// The behavior of this operator is achieved by combining `map` and `switchToLatest`.
    ///
    /// - Parameter transform: A closure that takes an element as a parameter and returns
    ///   a publisher that produces elements of that type.
    /// - Returns: A publisher that emits events sent by the publisher transformed from the most
    ///   recently transformed element received from the upstream publisher.
    public func flatMapLatest<T: Publisher>(
        _ transform: @escaping (Output) -> T
    ) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Failure {
        self.map(transform).switchToLatest()
    }
    
}
