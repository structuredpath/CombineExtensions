import Foundation

public protocol KVOCurrentValuePublishing {}

extension NSObject: KVOCurrentValuePublishing {}

extension KVOCurrentValuePublishing where Self: NSObject {
    
    /// Returns a `CurrentValuePublisher` that tracks the current value of a KVO-compliant property.
    ///
    /// - Parameter keyPath: The key path of the property to observe.
    /// - Returns: A `CurrentValuePublisher` that tracks the property’s value.
    ///
    /// This implementation follows the approach of Foundation’s `NSObject.publisher(for:options:)`,
    /// whose exact up-to-date declaration is difficult to find in Apple’s documentation, as
    /// [discussed on Stack Overflow](https://stackoverflow.com/q/60381905/670119). An older
    /// version can be found in the [swift-corelibs-foundation](https://spth.eu/publishers-kvo)
    /// open source repository.
    public func currentValuePublisher<Value>(
        for keyPath: KeyPath<Self, Value>
    ) -> CurrentValuePublisher<Value, Never> {
        return CurrentValuePublisher(
            initial: self[keyPath: keyPath],
            upstream: self.publisher(for: keyPath, options: .new)
        )
    }
    
}
