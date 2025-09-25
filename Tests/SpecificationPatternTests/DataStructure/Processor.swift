public struct Processor: Equatable, Hashable, Sendable {
  
  
  let modelName: String
  
  
  let vendor: ProcessorVendor
  
  
  let coreCount: Int
  
}



/// Static implementations extension.
public extension Processor {
  
  
  static let M1_APL_8: Processor = Processor(modelName: "M1", vendor: .apple, coreCount: 8)
  
  
  static let M2_APL_8: Processor = Processor(modelName: "M2", vendor: .apple, coreCount: 8)
  
  
  static let M3_APL_8: Processor = Processor(modelName: "M3", vendor: .apple, coreCount: 8)
  
  
  static let M4_APL_8: Processor = Processor(modelName: "M4", vendor: .apple, coreCount: 8)
  
  
  static let I510400_INL_6: Processor = Processor(modelName: "i5-10400", vendor: .intel, coreCount: 6)
  
  
  static let R57400F_AMD_6: Processor = Processor(modelName: "Ryzen 5 7400F", vendor: .amd, coreCount: 6)
  
}
