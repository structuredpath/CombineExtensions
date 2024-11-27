import Combine

extension CurrentValuePublisher {
    
    /// Creates a `CurrentValuePublisher` from a `@Published` property’s publisher.
    ///
    /// The resulting publisher emits the initial value of the `@Published` property, followed
    /// by all subsequent values.
    ///
    /// - Parameter publisher: A publisher associated with a `@Published` property.
    public convenience init(
        _ publisher: Published<Output>.Publisher
    ) where Failure == Never {
        var initialValue: Output!
        
        // `Published.Publisher`, similarly to `CurrentValueSubject` and ultimately also
        // `CurrentValuePublisher`, sends its current value to a subscriber upon subscription.
        // We leverage this behavior for obtaining the current value with a short-lived
        // subscription and skip it in the upstream publisher.
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
    
    /// Creates a `@Published` property wrapper that reflects the values of a `CurrentValuePublisher`.
    ///
    /// This is typically used to bind values from a `CurrentValuePublisher` to a `@Published`
    /// property in the initializer of an observable object. The property wrapper has to be
    /// assigned via `self._property = Published(publisher)`.
    ///
    /// - Parameter publisher: A `CurrentValuePublisher` whose values the property wrapper
    ///   will reflect.
    public init(_ publisher: CurrentValuePublisher<Publisher.Output, Publisher.Failure>) {
        self.init(initialValue: publisher.value)
        publisher.assign(to: &projectedValue)
    }
    
    /// Creates a `@Published` property wrapper that reflects the values of a `CurrentValueSubject`.
    ///
    /// This is typically used to bind values from a `CurrentValueSubject` to a `@Published`
    /// property in the initializer of an observable object. The property wrapper has to be
    /// assigned via `self._property = Published(subject)`.
    ///
    /// - Parameter publisher: A `CurrentValueSubject` whose values the property wrapper
    ///   will reflect.
    public init(_ subject: CurrentValueSubject<Publisher.Output, Publisher.Failure>) {
        self.init(CurrentValuePublisher(subject))
    }
    
}
