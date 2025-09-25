import Foundation



/// Generic implementation of the specification design pattern.
/// 
/// Use the ``Specification`` object to express business logic in a 
/// series of simple, reusable predicates that can be combined using
/// Boolean algebra operations.
/// 
/// ## Quick Usage Walkthrough
/// ```swift
/// // given the following DS
/// public struct Computer {
///   public let processor: Processor
///   public let disks: [Storage]
///   public let preloadedSoftwares: [Software]
/// }
/// 
/// // declaring specification is as easy as
/// import SpecificationPattern
/// typealias ComputerSpecification = Specification<Computer>
/// 
/// // static requirements enable easy chaining
/// extension ComputerSpecification {
///   static func hasProcessorVendor(_ vendor: ProcessorVendor) -> ComputerSpecification {
///     .init { $0.processor.vendor == vendor }
///   }
///   static func hasStorageMinimumOf(_ min: Int) -> ComputerSpecification {
///     .init { $0.disks.map({ $0.capacityInGB }).reduce(0, +) >= min }
///   }
///   static func hasPreloadedSoftware(_ software: Software) -> ComputerSpecification {
///     .init { $0.preloadedSoftwares.contains(software) }
///   }
/// }
/// 
/// // then, given the need to query things
/// var minimumStorage: Int? = nil
/// var preferredProcessorVendor: [ProcessorVendor] = []
/// var preloadedSoftwares: [Software] = []
/// 
/// // simply compose the states together
/// let searchRequirements = ComputerSpecification.all
///  .andIfPresent(minimumStorage) { .hasStorageMinimumOf($0) }
///  .andIfNotEmpty(preferredProcessorVendor, applyOrBetween: { .hasProcessorVendor($0) })
///  .andIfNotEmpty(preloadedSoftwares, applyAndBetween: { .hasPreloadedSoftware($0) })
/// 
/// // delegate the translation process from spec
/// // into impl. of API request/SQLite query/etc.
/// let dataSource: ComputerRepository
/// dataSource.find(matching: spec)
/// ```
/// 
/// ## Learn More
/// See the `SpecificationTests` for a more varied and detailed implementations.
public struct Specification<T>: SPOptionalSPSpecificationCombinable, Sendable where T: Sendable {
  
  
  /// The predicate closure that evaluates T.
  public let isSatisfiedBy: @Sendable (T) -> Bool
  
  
  /// Initializes a new specification.
  ///
  /// - Parameter isSatisfiedBy: A closure that takes T and returns true if it satisfies the specification.
  public init(isSatisfiedBy: @escaping @Sendable (T) -> Bool) {
    self.isSatisfiedBy = isSatisfiedBy
  }
  
}



/// `SPSpecificationCombinable` conformance via `SPOptionalSPSpecificationCombinable` extension.
public extension Specification {
  
  
  static var all: Self {
    Specification { _ in true }
  }
  
  
  static var none: Self {
    Specification { _ in false }
  }
  
  
  func and(_ other: Specification<T>) -> Self {
    Specification { self.isSatisfiedBy($0) && other.isSatisfiedBy($0) }
  }
  
  
  func or(_ other: Self) -> Self {
    Specification { self.isSatisfiedBy($0) || other.isSatisfiedBy($0) }
  }
  
  
  func not() -> Self {
    Specification { !self.isSatisfiedBy($0) }
  }
  
}



/// Convenience factory methods extension.
public extension Specification {
  
  
  /// Reduces the given specifications with `OR` logic.
  /// Returns a new specification object that is satisfied when ANY (one or more) are satisfied.
  /// 
  /// ## Behavior
  /// - Empty array → Returns `none` (satisfied by nothing).
  /// - Single element → Returns that element unchanged.
  /// - Multiple elements → Combines with `OR` via `reduce`.
  /// 
  /// ## Usage Example
  /// ```swift
  /// let buyersGuide: [Specification<Computer>] = [
  ///   .hasFormFactor(.desktop),
  ///   .hasProcessorVendor(.intel),
  ///   .hasPreloadedSoftware(.browser)
  /// ]
  /// let relevantComputers: Specification = .any(of: buyersGuide)
  /// 
  /// // evaluates to EITHER desktop OR having intel processor OR having browser preinstalled
  /// ```
  static func any(of specifications: [Self]) -> Self {
    guard !specifications.isEmpty else { return Self.none }
    return specifications.reduce(Self.none) { $0.or($1) }
  }
  
  
  /// Reduces the given specifications with `AND` logic.
  /// Returns a new specification object that is satisfied when EVERY specs are satisfied.
  /// 
  /// ## Behavior
  /// - Empty array → Returns `all` (satisfied by everything).
  /// - Single element → Returns that element unchanged.
  /// - Multiple elements → Combines with `AND` via `reduce`.
  /// 
  /// ## Usage Example
  /// ```swift
  /// let studioComputerRequirements: [Specification<Computer>] = [
  ///    .hasFormFactor(.desktop),
  ///    .hasProcessorVendor(.amd).or(.hasProcessorVendor(.intel)),
  ///    .hasStorageMinimumOf(1000)
  ///  ]
  ///  let completeSpec: Specification = .all(of: studioComputerRequirements)
  ///  
  ///  // evaluates to MUST BE desktop AND having (amd or intel) processor AND minimum storage of 1000
  /// ```
  static func all(of specifications: [Self]) -> Self {
    guard !specifications.isEmpty else { return Self.all }
    return specifications.reduce(Self.all) { $0.and($1) }
  }
  
}



/// Convenience declaration methods extension.
public extension Specification {
  
  
  /// Equality check shorthand. 
  /// Returns a specification that matches entities where the keypath equals the given value.
  /// 
  /// ## Usage Example
  /// ```swift
  /// struct Computer {
  ///   let processor: Processor
  ///   let formFactor: FormFactor
  /// }
  /// 
  /// let isAppleProduct = Specification<Computer>.where(\.processor, equals: .M2_APL_8)
  /// let isDesktopComputer = Specification<Computer>.where(\.formFactor, equals: .desktop)
  /// ```
  /// 
  /// - Parameters:
  ///   - keyPath: The keypath to the property to compare.
  ///   - value: The value to compare against.
  /// - Returns: A specification that checks property equality.
  static func `where`<Value: Equatable & Sendable>(_ keyPath: KeyPath<T, Value>, equals value: Value) -> Specification<T> {
    let kp = SPSendableKeyPath<T, Value>(keyPath)
    return Specification { entity in
      entity[keyPath: kp.keyPath] == value
    }
  }
  
  
  /// Predicate-based check shorthand.
  /// Returns a specification that matches entities where the property at the given keypath satisfies the given predicate.
  /// 
  /// ## Example
  /// 
  /// ```swift
  /// struct Computer {
  ///   let processor: Processor
  ///   let disks: [Storage]
  /// }
  /// 
  /// let hasHighCoreCount = Specification<Computer>.where(\.processor.coreCount) { $0 >= 8 }
  /// let hasLargeStorage = Specification<Computer>.where(\.disks) { $0.map({ $0.capacityInGB }).reduce(0, +) >= 1000 }
  /// ```
  /// 
  /// - Parameters:
  ///   - keyPath: The keypath to the property to evaluate.
  ///   - predicate: The predicate to apply to the property value.
  /// - Returns: A specification that applies the predicate to the specified property.
  static func `where`<Value>(_ keyPath: KeyPath<T, Value>, satisfies predicate: @escaping @Sendable (Value) -> Bool) -> Specification<T> {
    let kp = SPSendableKeyPath<T, Value>(keyPath)
    return Specification { entity in
      predicate(entity[keyPath: kp.keyPath])
    }
  }
  
  
  /// Element membership check shorthand.
  /// Returns a specification that matches entities where the collection property at the given keypath contains the specified value.
  /// 
  /// ## Example
  /// 
  /// ```swift
  /// struct Computer {
  ///   let disks: [Storage]
  ///   let preloadedSoftwares: [Software]
  /// }
  /// 
  /// let has512SSD = Specification<Computer>.where(\.disks, contains: .SSD512)
  /// let hasBrowser = Specification<Computer>.where(\.preloadedSoftwares, contains: .browser)
  /// ```
  /// 
  /// - Parameters:
  ///   - keyPath: The keypath to the collection property.
  ///   - value: The value to search for in the collection.
  /// - Returns: A specification that checks collection membership.
  static func `where`<C: Swift.Collection & SendableMetatype>(_ keyPath: KeyPath<T, C>, contains value: C.Element) -> Specification<T> where C.Element: Equatable & Sendable {
    let kp = SPSendableKeyPath<T, C>(keyPath)
    return Specification { entity in
      entity[keyPath: kp.keyPath].contains(value)
    }
  }
  
}
