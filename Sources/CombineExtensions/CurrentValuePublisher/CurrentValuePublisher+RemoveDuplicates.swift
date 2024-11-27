import Combine

extension CurrentValuePublisher {
    
    /// Returns a new `CurrentValuePublisher` that emits values only when they differ from the
    /// previous value, as determined by the provided predicate.
    ///
    /// - Parameter predicate: A closure that compares the previous and current values and returns
    ///   `true` if they are considered duplicates.
    /// - Returns: A `CurrentValuePublisher` that emits only distinct values.
    public func removeDuplicates(
        by predicate: @escaping (Output, Output) -> Bool
    ) -> CurrentValuePublisher<Output, Failure> {
        switch self.storage {
        case .constant:
            return self
        case .subject:
            let initialValue = self.value
            
            let upstream = self.dropFirst()
                .drop { predicate(initialValue, $0) }
                .removeDuplicates(by: predicate)
            
            return CurrentValuePublisher(
                initial: initialValue,
                upstream: upstream
            )
        }
    }
    
}

extension CurrentValuePublisher where Output: Equatable {
    
    /// Returns a new `CurrentValuePublisher` that emits values only when they differ from the
    /// previous value.
    ///
    /// - Returns: A `CurrentValuePublisher` that emits only distinct values.
    public func removeDuplicates() -> CurrentValuePublisher<Output, Failure> {
        return self.removeDuplicates(by: ==)
    }
    
}
