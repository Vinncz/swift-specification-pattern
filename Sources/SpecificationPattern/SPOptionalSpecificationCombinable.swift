import Foundation



/// Set of additional operations to support conditional composition with optional values.
/// 
/// Conform to the ``SPOptionalSPSpecificationCombinable`` to inherit the necessary
/// methods and implementations, that are especially useful while working with optionals;
/// either nil values, or an empty array.
public protocol SPOptionalSPSpecificationCombinable: SPSpecificationCombinable {
  
  
  /// `AND`s self and the given specification if the value is present,
  /// return self unaltered otherwise.
  /// 
  /// ## Usage Example
  /// ```swift
  /// var minimumStorageSpace: Int? = nil
  /// 
  /// // equals to `ComputerSpecification.all` when 
  /// // `minimumStorageSpace` is nil.
  /// let spec = ComputerSpecification.all
  ///   .andIfPresent(minimumStorageSpace) { 
  ///     ComputerSpecification.hasStorageMinimumOf($0)
  ///   }
  /// 
  /// var minimumRamSize: Int? = 32
  /// 
  /// // equals to `ComputerSpecification.hasMemoryMinimumOf(minimumRamSize)` 
  /// // when `minimumStorageSpace` is nil.
  /// let highEndSpec = ComputerSpecification.all
  ///   .andIfPresent(minimumStorageSpace) {
  ///     ComputerSpecification.hasStorageMinimumOf($0) 
  ///   }
  ///   .andIfPresent(minimumRamSize) {
  ///     ComputerSpecification.hasMemoryMinimumOf($0) 
  ///   }
  /// ```
  func andIfPresent<T>(_ value: T?, _ builder: (T) -> Self) -> Self
  
  
  /// Evaluates each element against the builder, applies `OR` between the results,
  /// then `AND`s them with self. Returns self unaltered otherwise.
  /// 
  /// ## Usage Example
  /// ```swift
  /// var preferredProcessorVendor: [ProcessorVendor] = [.amd, .intel]
  /// 
  /// // query computers that have EITHER `.amd` OR `.intel` processor
  /// // or query ALL computers if empty.
  /// let spec = ComputerSpecification.all
  ///   .andIfNotEmpty(preferredProcessorVendor, applyOrBetween: {
  ///     ComputerSpecification.hasProcessorVendor($0)
  ///   })
  /// ```
  func andIfNotEmpty<T>(_ values: [T], applyOrBetween builder: (T) -> Self) -> Self
  
  
  /// Evaluates each element against the builder, applies `AND` between the results,
  /// then `AND`s them with self. Returns self unaltered otherwise.
  /// 
  /// ## Usage Example
  /// ```swift
  /// var preloadedSoftwares: [Software] = [.office, .browser]
  /// 
  /// // query computers that have BOTH `.office` AND `.browser` preinstalled.
  /// // or, query ALL computers if empty.
  /// let spec = ComputerSpecification.all
  ///   .andIfNotEmpty(preloadedSoftwares, applyAndBetween: { software
  ///     ComputerSpecification.hasPreloadedSoftware(software)
  ///   })
  /// ```
  func andIfNotEmpty<T>(_ values: [T], applyAndBetween builder: (T) -> Self) -> Self
  
}



/// Default implementations extension.
public extension SPOptionalSPSpecificationCombinable {
  
  
  func andIfPresent<T>(_ value: T?, _ builder: (T) -> Self) -> Self {
    guard let value else { return self }
    return self.and(builder(value))
  }
  
  
  func andIfNotEmpty<T>(_ values: [T], applyOrBetween builder: (T) -> Self) -> Self {
    guard !values.isEmpty else { return self }
    
    let combinedSpec = values.map(builder).reduce(Self.none) { $0.or($1) }
    return self.and(combinedSpec)
  }
  
  
  func andIfNotEmpty<T>(_ values: [T], applyAndBetween builder: (T) -> Self) -> Self {
    guard !values.isEmpty else { return self }
    
    let combinedSpec = values.map(builder).reduce(Self.all) { $0.and($1) }
    return self.and(combinedSpec)
  }
  
}
