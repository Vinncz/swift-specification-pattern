import Foundation



/// Declares combinatorial operations that defines specification pattern.
/// 
/// Conform to the ``SPSpecificationCombinable`` protocol to inherit the necessary
/// methods to work with other specifications.
/// 
/// ## Mathematical Foundation
/// Specifications form a Boolean algebra with:
/// - Identity elements: `all` (true) and `none` (false)
/// - Binary operations: `and` (∧) and `or` (∨)  
/// - Unary operation: `not` (¬)
/// - Laws: commutativity, associativity, distributivity, etc.
public protocol SPSpecificationCombinable {
  
  
  /// Identity element for `AND` operations (specification that always satisfy).
  /// 
  /// This specification always returns `true`.
  static var all: Self { get }
  
  
  /// Identity element for `OR` operations (specification that never satisfy).
  /// 
  /// This specification always returns `false`.
  static var none: Self { get }
  
  
  /// Combines self with the given specification using the `AND` operation.
  /// Returns a new specification object that is satisfied when BOTH are satisfied.
  /// 
  /// ## Mathematical Properties
  /// ### Commutative
  /// ```swift
  /// a.and(b) == b.and(a) 
  /// ```
  /// ### Associative
  /// ```swift
  /// a.and(b).and(c) == a.and(b.and(c))
  /// ```
  /// ### Identity
  /// ```swift
  /// a.and(.all) == a
  /// ```
  func and(_ other: Self) -> Self
  
  
  /// Combines self with the given specification using the `OR` operation.
  /// Returns a new specification object that is satisfied when EITHER or BOTH are satisfied.
  /// 
  /// ## Mathematical Properties
  /// ### Commutative 
  /// ```swift
  /// a.or(b) == b.or(a)
  /// ```
  /// ### Associative 
  /// ```
  /// a.or(b).or(c) == a.or(b.or(c))
  /// ```
  /// ### Identity 
  /// ```
  /// a.or(.none) == a
  /// ```
  func or(_ other: Self) -> Self
  
  
  /// Negates self.
  /// Returns a new specification that is satisfied when self is not.
  /// 
  /// ## Mathematical Properties
  /// ### Double Negation
  /// ```swift
  /// a.not().not() == a
  /// ```
  /// ### De Morgan's Laws
  /// ```swift
  /// a.and(b).not() == a.not().or(b.not())
  /// ```
  func not() -> Self
  
}
