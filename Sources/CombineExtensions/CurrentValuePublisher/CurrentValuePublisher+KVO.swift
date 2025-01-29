import Foundation

public protocol KVOCurrentValuePublishing {}

extension NSObject: KVOCurrentValuePublishing {}

extension KVOCurrentValuePublishing where Self: NSObject {
    
    /// Returns a `CurrentValuePublisher` that tracks the current value of a KVO-compliant property.
    ///
    /// - Parameter keyPath: The key path of the property to observe.
    /// - Returns: A `CurrentValuePublisher` that tracks the property's value.
    ///
    /// This implementation follows the approach of `NSObject.publisher(for:options:)` from Foundation,
    /// previously available in the [swift-corelibs-foundation](https://bit.ly/nsobject-keyvalueobserving)
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
