import Combine

/// A publisher that wraps a single value and emits a new element whenever the value changes.
///
/// `CurrentValuePublisher` is similar to the built-in `CurrentValueSubject`, but it prevents
/// direct modification of the value by clients. It is useful for exposing a `CurrentValueSubject`
/// whose value should only be updated internally.
///
/// This publisher retains its current value, which is accessible at any time. Upon subscription,
/// it emits the current value, followed by any new values as they occur. It also provides operator
/// overloads that apply to both the current and future values.
///
/// `CurrentValuePublisher` can be created with a constant value, an initial value paired with an
/// upstream publisher, or a backing `CurrentValueSubject`.
///
/// If created with an upstream publisher, `CurrentValuePublisher` maintains an active subscription
/// to it until the upstream publisher completes or the `CurrentValuePublisher` is deallocated.
/// Deallocation occurs when all references to the `CurrentValuePublisher` as well as all downstream
/// subscriptions are released.
///
/// ### Development Notes:
/// - Inspired by the `Property` and `MutableProperty` types from ReactiveSwift, particularly their
///   distinction between constant and composed behaviors, as described at https://bit.ly/3c6iWfq.
/// - Although the implementation differs significantly, this gist served as an initial reference:
///   https://gist.github.com/sharplet/14703e2988e38d870198064989263f75.
/// - The storage evolved from a simple value, to a subject, and finally to a `Storage` abstraction
///   with `constant` and `subject` cases.
public final class CurrentValuePublisher<Output, Failure: Error>: Publisher {
    
    // ============================================================================ //
    // MARK: - Initialization
    // ============================================================================ //
    
    /// Creates a `CurrentValuePublisher` with a constant value.
    ///
    /// When subscribed to, the publisher emits the constant value and immediately finishes.
    public convenience init(value: Output) {
        self.init(storage: .constant(value))
    }
    
    /// Creates a `CurrentValuePublisher` with an initial value and an upstream publisher.
    ///
    /// When subscribed to, the publisher emits its current value and all subsequent values
    /// produced by the the upstream publisher, until the upstream completes or fails.
    ///
    /// - Parameters:
    ///   - initial: The initial value.
    ///   - upstream: The upstream publisher providing subsequent values.
    public convenience init<Upstream>(
        initial: Output,
        upstream: Upstream
    ) where Upstream: Publisher, Upstream.Output == Output, Upstream.Failure == Failure {
        let subject = CurrentValueSubject<Output, Failure>(initial)
        self.init(subject)
        
        // Subscribe to the upstream publisher and forward its values to the underlying current
        // value subject. Store a cancellable in a property to cancel the subscription when the
        // current value publisher gets deallocated. Additionally, observe the completion of the
        // upstream publisher and when it arrives, cancel the subscription when the current value
        // publisher instance is not deallocated. We have to reference `self` weakly as it should
        // not affect the reference count.
        self.upstreamCancellable = upstream.sink(
            receiveCompletion: { [weak self] completion in
                subject.send(completion: completion)
                
                self?.upstreamCancellable?.cancel()
                self?.upstreamCancellable = nil
            },
            receiveValue: { value in
                subject.send(value)
            }
        )
    }
    
    /// Creates a `CurrentValuePublisher` backed by a `CurrentValueSubject`.
    ///
    /// When subscribed to, it emits the subject’s current value and any subsequent values until
    /// the subject completes or fails.
    ///
    /// - Parameter subject: The `CurrentValueSubject` providing the values.
    public convenience init(_ subject: CurrentValueSubject<Output, Failure>) {
        self.init(storage: .subject(subject))
    }
    
    private init(storage: Storage) {
        self.storage = storage
    }
    
    // ============================================================================ //
    // MARK: - Value
    // ============================================================================ //
    
    /// The current value of the publisher.
    public var value: Output { self.storage.value }
    
    // ============================================================================ //
    // MARK: - Subscription Handling
    // ============================================================================ //
    
    /// Attaches the given subscriber to this publisher.
    public func receive<S>(
        subscriber: S
    ) where S: Subscriber, Output == S.Input, Failure == S.Failure {
        self.storage.publisher
            .handleEvents(
                receiveSubscription: { _ in
                    // To prevent deinitialization of self while this subscription is active,
                    // we hold onto a strong reference to self until cancelled.
                    _ = self
                }
            )
            .receive(subscriber: subscriber)
    }
    
    // ============================================================================ //
    // MARK: - Underlying Storage
    // ============================================================================ //
    
    /// The underlying storage backing the publisher.
    internal let storage: Storage
    
    internal enum Storage {
        
        /// The storage for a constant value.
        case constant(Output)
        
        /// The storage for a composed stream of values.
        case subject(CurrentValueSubject<Output, Failure>)
        
        /// The derived current value.
        fileprivate var value: Output {
            switch self {
            case .constant(let value):
                return value
            case .subject(let subject):
                return subject.value
            }
        }
        
        /// The derived publisher.
        fileprivate var publisher: AnyPublisher<Output, Failure> {
            switch self {
            case .constant(let value):
                return Just(value)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            case .subject(let subject):
                return subject.eraseToAnyPublisher()
            }
        }
        
    }
    
    // ============================================================================ //
    // MARK: Private
    // ============================================================================ //
    
    /// The subscription to the upstream publisher, if the `CurrentValuePublisher` was initialized
    /// with an upstream publisher. This subscription ensures that values from the upstream are
    /// forwarded to the current value publisher. It is cancelled when the `CurrentValuePublisher`
    /// is deallocated, ensuring proper cleanup of resources.
    private var upstreamCancellable: AnyCancellable?
    
    // ============================================================================ //
    // MARK: - Deinitialization
    // ============================================================================ //
    
    deinit {
        self.upstreamCancellable?.cancel()
    }

}
