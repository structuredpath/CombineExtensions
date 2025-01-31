# CombineExtensions

A collection of Combine extensions that introduce additional operators and `CurrentValuePublisher`, an immutable alternative to `CurrentValueSubject`.

## Operators

- `flatMapLatest`: Transforms elements into publishers, republishing values from the most recent inner publisher while canceling previous ones.
- `withPrevious`: Emits tuples of the current and previous elements.

## `CurrentValuePublisher`

- An immutable counterpart to `CurrentValueSubject`.
- Bridges seamlessly with `CurrentValueSubject` and the `@Published` property wrapper for integration with `ObservableObject`.
- Includes custom operator overloads that return instances of `CurrentValuePublisher`, which are applied to both current and future values.
- Support for the `flatMapLatest` operator, enabling nested publisher chaining while ensuring only the most recent publisher remains active.
- Adds support for creating a `CurrentValuePublisher` from a KVO-compliant property on `NSObject`.
