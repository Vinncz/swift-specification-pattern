public struct Memory: Codable, Equatable, Hashable, Sendable {
  
  
  let capacityInGB: Int
  
  
  let type: MemoryType
  
}



/// Static implementations extension.
public extension Memory {
  
  
  static let DDR4_8GB: Memory = Memory(capacityInGB: 8, type: .ddr4)
  
  
  static let DDR4_16GB: Memory = Memory(capacityInGB: 16, type: .ddr4)
  
  
  static let DDR5_16GB: Memory = Memory(capacityInGB: 16, type: .ddr5)
  
  
  static let DDR5_32GB: Memory = Memory(capacityInGB: 32, type: .ddr5)
  
  
  static let LPDDR5_32GB: Memory = Memory(capacityInGB: 32, type: .lpddr5)
  
}
