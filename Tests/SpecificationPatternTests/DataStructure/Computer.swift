import Foundation



public struct Computer: Equatable, Hashable, Identifiable, Sendable {
  
  
  public let id: UUID
  
  
  public let name: String
  
  
  public let formFactor: FormFactor
  
  
  public let processor: Processor
  
  
  public let ramSticks: [Memory]
  
  
  public let disks: [Storage]
  
  
  public let preloadedSoftwares: [Software]
  
}



/// Static implementations extension.
public extension Computer {
  
  
  static let AIO_INL_8DDR4_256SSD: Computer = Computer(id: .a11,
                                                       name: "All In One, Intel, 8GB DDR4, 256GB SSD", 
                                                       formFactor: .allInOne, 
                                                       processor: .I510400_INL_6, 
                                                       ramSticks: [.DDR4_8GB], 
                                                       disks: [.SSD256],
                                                       preloadedSoftwares: [])
  
  
  static let AIO_AMD_8DDR4_256SSD: Computer = Computer(id: .a1b,
                                                       name: "All In One, AMD, 8GB DDR4, 256GB SSD", 
                                                       formFactor: .allInOne, 
                                                       processor: .R57400F_AMD_6, 
                                                       ramSticks: [.DDR4_8GB], 
                                                       disks: [.SSD256],
                                                       preloadedSoftwares: [.browser])
  
  
  static let AIO_AMD_8DDR4_512SSD: Computer = Computer(id: .a23, 
                                                       name: "All In One, AMD, 8GB DDR4, 512GB SSD", 
                                                       formFactor: .allInOne, 
                                                       processor: .R57400F_AMD_6, 
                                                       ramSticks: [.DDR4_8GB], 
                                                       disks: [.SSD512],
                                                       preloadedSoftwares: [.office])
  
  
  static let LAP_M2_16DDR5_512SSD: Computer = Computer(id: .a64, 
                                                       name: "Apple MacBook Air M2, 16GB DDR5, 512GB SSD", 
                                                       formFactor: .laptop, 
                                                       processor: .M2_APL_8, 
                                                       ramSticks: [.DDR5_16GB], 
                                                       disks: [.SSD512],
                                                       preloadedSoftwares: [.browser, .phoneLink])
  
  
  static let DST_INL_16DDR5_1024SSD: Computer = Computer(id: .a87, 
                                                         name: "Desktop, Intel, 16GB DDR5, 1TB SSD", 
                                                         formFactor: .desktop, 
                                                         processor: .I510400_INL_6, 
                                                         ramSticks: [.DDR5_16GB], 
                                                         disks: [.SSD1024],
                                                         preloadedSoftwares: [.office, .browser, .phoneLink])
  
}
