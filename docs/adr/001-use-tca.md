# ADR-001: Use The Composable Architecture (TCA)

## Status
Accepted

## Context
We need a robust state management solution for our iOS Bible app that will:
- Handle complex state across multiple features
- Provide predictable state updates
- Enable comprehensive testing
- Support debugging and development
- Scale with the application

## Decision
We will use The Composable Architecture (TCA) from Point-Free as our primary state management solution.

## Rationale

### Pros
- **Unidirectional Data Flow**: State changes are predictable and traceable
- **Testability**: Pure functions and dependency injection make testing straightforward
- **Modularity**: Features can be developed in isolation
- **Time Travel Debugging**: Development tools for state inspection
- **Type Safety**: Leverages Swift's type system for compile-time safety
- **Effect Management**: Clear patterns for handling side effects
- **Community**: Active community and ongoing development

### Cons
- **Learning Curve**: Requires understanding functional programming concepts
- **Boilerplate**: More initial setup compared to simpler solutions
- **Compile Times**: Can increase build times with complex reducers
- **iOS 17+**: Latest versions require newer iOS deployment targets

## Alternatives Considered

### MVVM + Combine
- Pros: Familiar to iOS developers, Apple-native
- Cons: No standard implementation, testing can be complex

### Redux-like (ReSwift)
- Pros: Well-understood pattern
- Cons: Less Swift-idiomatic, fewer iOS-specific features

### SwiftUI @StateObject only
- Pros: Simple, minimal dependencies
- Cons: Difficult to scale, limited testing capabilities

## Implementation

```swift
@Reducer
struct FeatureReducer {
    @ObservableState
    struct State: Equatable {
        // Feature state
    }
    
    enum Action {
        // Feature actions
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Handle actions
        }
    }
}
```

## Consequences

### Positive
- Clear separation of concerns
- Excellent testability
- Predictable state management
- Good developer experience with tools

### Negative
- Team needs TCA training
- More verbose than simple solutions
- Dependency on third-party library

## References
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Point-Free TCA Episodes](https://www.pointfree.co/collections/composable-architecture)
- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)