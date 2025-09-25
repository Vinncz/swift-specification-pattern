public struct Storage: Equatable, Hashable, Sendable {
  
  
  let capacityInGB: Int
  
  
  let type: StorageType
  
}



/// Static implementations extension.
public extension Storage {
  
  
  static let HDD64: Storage = Storage(capacityInGB: 64, type: .hdd)
  
  
  static let HDD128: Storage = Storage(capacityInGB: 128, type: .hdd)
  
  
  static let SSD256: Storage = Storage(capacityInGB: 256, type: .ssd)
  
  
  static let SSD512: Storage = Storage(capacityInGB: 512, type: .ssd)
  
  
  static let SSD1024: Storage = Storage(capacityInGB: 1024, type: .ssd)
  
}
