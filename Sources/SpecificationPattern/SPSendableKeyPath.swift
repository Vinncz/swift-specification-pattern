import Foundation



/// Sendable wrapper to capture `KeyPath` in a `@Sendable` closure.
/// 
/// ### Problem
/// Depending on the toolchain--especially older versions of macOS and iOS--KeyPath's 
/// sendable conformance may be conditional and not always be inferred in generic contexts.
/// 
/// ### Solution
/// Since `KeyPath` is immutable and thread-safe,
/// an @unchecked Sendable wrapper is all that is needed.
public struct SPSendableKeyPath<Root, Value>: @unchecked Sendable {
  
  
  /// The wrapped KeyPath.
  public let keyPath: KeyPath<Root, Value>
  
  
  /// Non-labeled initializer.
  public init(_ keyPath: KeyPath<Root, Value>) { self.keyPath = keyPath }
  
}
