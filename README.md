# CombineExtensions

A collection of Combine extensions featuring:

- **`CurrentValuePublisher`**
  - An immutable alternative to `CurrentValueSubject`.
  - Bridges seamlessly with `CurrentValueSubject` and the `@Published` property wrapper for integration with `ObservableObject`.
  - Includes custom operator overloads that apply to both current and future values.

- **Operators**
  - `flatMapLatest`: Transforms elements into publishers, republishing values from the most recent inner publisher while canceling previous ones.
  - `withPrevious`: Emits tuples of the current and previous elements.
