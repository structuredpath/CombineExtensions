import Combine

extension CurrentValuePublisher {
    
    /// Initializes a `CurrentValuePublisher` from a `@Published` property’s publisher.
    ///
    /// Captures the current value of the `@Published` property and emits all future updates.
    /// Useful when bridging a `@Published` property to APIs expecting a `CurrentValuePublisher`.
    ///
    /// - Parameter publisher: The publisher exposed by a `@Published` property via its projected
    ///   value, typically accessed via the `$` prefix.
    public convenience init(
        _ publisher: Published<Output>.Publisher
    ) where Failure == Never {
        var initialValue: Output!
        
        // Ideally, we would access the current value of a `@Published` property directly, but
        // there is no API to achieve that. Instead, we rely on the fact that `Published.Publisher`
        // emits its current value upon subscription—similar to `CurrentValueSubject`
        // and `CurrentValuePublisher`. We use a short-lived subscription to capture that value,
        // then drop it from the upstream.
        _ = publisher
            .first()
            .sink { initialValue = $0 }
        
        self.init(
            initial: initialValue,
            upstream: publisher.dropFirst()
        )
    }
    
}

extension Published {
    
    /// Initializes a `@Published` property wrapper backed by a `CurrentValuePublisher`.
    ///
    /// Useful for binding a `CurrentValuePublisher` to a `@Published` property inside
    /// an observable object’s initializer. The wrapper must be assigned directly to the backing
    /// storage, e.g. `self._property = Published(publisher)`.
    ///
    /// While it is technically possible to mutate such a `@Published` property, doing so is
    /// discouraged—any assigned value will be overwritten by the next emission from the upstream
    /// publisher. To prevent accidental writes, the property should typically be declared with
    /// `private(set)` or limited through access control.
    ///
    /// - Parameter publisher: The `CurrentValuePublisher` whose values will drive the `@Published`
    ///   property.
    public init(_ publisher: CurrentValuePublisher<Value, Never>) {
        self.init(initialValue: publisher.value)
        
        publisher
            .dropFirst()
            .assign(to: &self.projectedValue)
    }
    
}

extension Published {
    
    @available(*, deprecated, message: """
    No longer supported. Explicitly convert the subject to a CurrentValuePublisher instead. \
    This initializer creates a one-way binding only—updates to the property do not propagate \ 
    back to the subject, which can lead to confusion.
    """)
    public init(_ subject: CurrentValueSubject<Value, Never>) {
        self.init(CurrentValuePublisher(subject))
    }
    
}
