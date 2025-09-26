import Foundation
import Testing
@testable import SpecificationPattern



// swiftlint:disable type_body_length
@Suite("Specification Tests")
struct SpecificationTests {
  
  
  @Test("`all` matches against every computers")
  func testAllSpecification() {
    let spec = ComputerSpecification.all
    
    #expect(spec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(spec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(spec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`none` matches against no computer")
  func testNoneSpecification() {
    let spec = ComputerSpecification.none
    
    #expect(!spec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!spec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!spec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`and` operation combines correctly")
  func testAndSpecification() {
    let fullyPassingSpec = ComputerSpecification.all
      .and(.hasStorageMinimumOf(256))
    
    #expect(fullyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(fullyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(fullyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let partiallyPassingSpec = fullyPassingSpec.and(.hasUniformRamArchitecture(.ddr5))
    #expect(!partiallyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( partiallyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( partiallyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let minimallyPassingSpec = partiallyPassingSpec.and(.hasFormFactor(.desktop))
    #expect(!minimallyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!minimallyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( minimallyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let failingSpec = minimallyPassingSpec.and(.hasProcessorVendor(.apple))
    #expect(!failingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!failingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!failingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`or` operation combines correctly")
  func testOrSpecification() {
    let minimallyPassingSpec = ComputerSpecification.hasStorageMinimumOf(768)
    #expect(!minimallyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!minimallyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( minimallyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let partiallyPassingSpec = minimallyPassingSpec.or(.hasProcessorVendor(.apple))
    #expect(!partiallyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( partiallyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( partiallyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let fullyPassingSpec = partiallyPassingSpec.or(.hasProcessorVendor(.amd))
    #expect( fullyPassingSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( fullyPassingSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( fullyPassingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`not` operation negates specification correctly")
  func testBasicAndDoubleNotOperation() {
    let amdComputer = ComputerSpecification.hasProcessorVendor(.amd)
    #expect(!amdComputer.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!amdComputer.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!amdComputer.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let not_amdComputer = amdComputer.not()
    #expect( not_amdComputer.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!not_amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!not_amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( not_amdComputer.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( not_amdComputer.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let not_not_amdComputer = not_amdComputer.not()
    #expect(!not_not_amdComputer.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( not_not_amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( not_not_amdComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!not_not_amdComputer.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!not_not_amdComputer.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`not` operation follows De Morgan's Laws")
  func testDeMorgansLaws() {
    let diskMoreThan500OrAMD = ComputerSpecification.none
      .or(.hasStorageMinimumOf(500))
      .or(.hasProcessorVendor(.amd))
    #expect(!diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))  // neither has the minimum 500 nor AMD processor
    #expect( diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( diskMoreThan500OrAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( diskMoreThan500OrAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let not_diskMoreThan500OrAMD = diskMoreThan500OrAMD.not()
    #expect( not_diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!not_diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))  // disk bigger than 500, AMD processor
    #expect(!not_diskMoreThan500OrAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))  // disk bigger than 500
    #expect(!not_diskMoreThan500OrAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))  // disk bigger than 500
    #expect(!not_diskMoreThan500OrAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // disk bigger than 500
    
    let diskLessThan500AndNotAMD = ComputerSpecification.all
      .and(.hasStorageMinimumOf(500).not())
      .and(.hasProcessorVendor(.amd).not())
    #expect( diskLessThan500AndNotAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!diskLessThan500AndNotAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!diskLessThan500AndNotAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!diskLessThan500AndNotAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!diskLessThan500AndNotAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    
    let diskMoreThan500AndAMD = ComputerSpecification.all
      .and(.hasStorageMinimumOf(500))
      .and(.hasProcessorVendor(.amd))
    #expect(!diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))  // disk less than 500
    #expect(!diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))  // disk less than 500
    #expect( diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!diskMoreThan500AndAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))  // not AMD processor
    #expect(!diskMoreThan500AndAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // not AMD processor
    
    let not_diskMoreThan500AndAMD = diskMoreThan500AndAMD.not()
    #expect( not_diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( not_diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!not_diskMoreThan500AndAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))  // disk more than 500, AMD processor
    #expect( not_diskMoreThan500AndAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( not_diskMoreThan500AndAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let diskLessThan500OrNotAMD = ComputerSpecification.none
      .or(.hasStorageMinimumOf(500).not())
      .or(.hasProcessorVendor(.amd).not())
    #expect( diskLessThan500OrNotAMD.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( diskLessThan500OrNotAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!diskLessThan500OrNotAMD.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( diskLessThan500OrNotAMD.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( diskLessThan500OrNotAMD.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`andIfPresent` combines correctly with value")
  func testAndIfPresentWithValue() {
    let allInOneComputer = ComputerSpecification.hasFormFactor(.allInOne)
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!allInOneComputer.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))  // not AIO
    #expect(!allInOneComputer.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // not AIO
    
    let desiredMinimumStorageSize: Int? = 500
    let allInOneComputerWith512Storage = allInOneComputer.andIfPresent(desiredMinimumStorageSize, { .hasStorageMinimumOf($0) })
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))  // does not satisfy minimum storage
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))  // does not satisfy minimum storage
    #expect( allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let desiredVendor: ProcessorVendor? = .intel
    let allInOneComputerWith512StorageAndProcessorVendor = allInOneComputerWith512Storage.andIfPresent(desiredVendor) { .hasProcessorVendor($0) }
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))  // does not satisfy Intel as vendor
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`andIfPresent` combines correctly with nil")
  func testAndIfPresentWithNil() {
    let allInOneComputer = ComputerSpecification.hasFormFactor(.allInOne)
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( allInOneComputer.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!allInOneComputer.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!allInOneComputer.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    let desiredMinimumStorageSize: Int? = nil
    let allInOneComputerWith512Storage = allInOneComputer.andIfPresent(desiredMinimumStorageSize) { .hasStorageMinimumOf($0) }
    #expect( allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( allInOneComputerWith512Storage.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!allInOneComputerWith512Storage.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // nothing changed
    
    let desiredVendor: ProcessorVendor? = nil
    let allInOneComputerWith512StorageAndProcessorVendor = allInOneComputerWith512Storage.andIfPresent(desiredVendor) { .hasProcessorVendor($0) }
    #expect( allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!allInOneComputerWith512StorageAndProcessorVendor.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // nothing changed
  }
  
  
  @Test("`andIfNotEmpty(_: applyOrBetween:)` and `andIfNotEmpty(_: applyAndBetween:) combines correctly with empty arrays and those with values")
  func testAndIfNotEmpty() {
    var minimumStorage: Int?
    var preferredProcessorVendor: [ProcessorVendor] = []
    var preloadedSoftwares: [Software] = []
    
    let spec: () -> ComputerSpecification = {
      ComputerSpecification.all
        .andIfPresent(minimumStorage) { .hasStorageMinimumOf($0) }
        .andIfNotEmpty(preferredProcessorVendor, applyOrBetween: { .hasProcessorVendor($0) })
        .andIfNotEmpty(preloadedSoftwares, applyAndBetween: { .hasPreloadedSoftware($0) })
    }
    
    // no filter applied at first
    #expect( spec().isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( spec().isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( spec().isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    // show computer with at least 512G of storage
    minimumStorage = 512
    preferredProcessorVendor = []  // empty -> ignored
    preloadedSoftwares = []        // empty -> ignored
    #expect(!spec().isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( spec().isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( spec().isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    // show computer with (at least 512G of storage) AND (AMD or Intel processor)
    minimumStorage = 512
    preferredProcessorVendor = [.intel, .amd]
    preloadedSoftwares = []  // empty -> ignored
    #expect(!spec().isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect( spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!spec().isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( spec().isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    // show computers that have browser bundled 
    minimumStorage = nil           // empty -> ignored
    preferredProcessorVendor = []  // empty -> ignored
    preloadedSoftwares = [.browser]
    #expect(!spec().isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect( spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( spec().isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( spec().isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
    
    // show computers with (processor made by .apple OR .amd OR .intel) AND (having .phoneLink bundled)
    minimumStorage = nil  // empty -> ignored
    preferredProcessorVendor = [.apple, .amd, .intel]
    preloadedSoftwares = [.phoneLink]
    #expect(!spec().isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!spec().isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( spec().isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( spec().isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`any` combines specifications correctly")
  func testAny() {
    let buyersGuide: [ComputerSpecification] = [
      .hasFormFactor(.desktop),
      .hasProcessorVendor(.intel),
      .hasPreloadedSoftware(.browser)
    ]
    let relevantComputerSpecs: ComputerSpecification = .any(of: buyersGuide)  // factory via typealias
    
    #expect( relevantComputerSpecs.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))    // pass due to .intel
    #expect( relevantComputerSpecs.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))    // pass due to browser
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect( relevantComputerSpecs.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))    // pass due to browser
    #expect( relevantComputerSpecs.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // pass due to desktop, intel, and browser
  }
  
  
  @Test("`any` with empty array returns nothing")
  func testAnyEmpty() {
    let buyersGuide: [ComputerSpecification] = []
    let relevantComputerSpecs = ComputerSpecification.any(of: buyersGuide)
    
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(!relevantComputerSpecs.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`all` combines specification correctly")
  func testAll() {
    let studioComputerRequirements: [ComputerSpecification] = [
      .hasFormFactor(.desktop),
      .hasProcessorVendor(.amd).or(.hasProcessorVendor(.intel)),
      .hasStorageMinimumOf(1000)
    ]
    let completeSpec: Specification = .all(of: studioComputerRequirements)  // factory via declaration
    
    #expect(!completeSpec.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(!completeSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(!completeSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(!completeSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect( completeSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))  // pass due to desktop, intel, and storage size
    
    
    let failingRequirements: [ComputerSpecification] = [
      .hasFormFactor(.desktop),
      .hasProcessorVendor(.amd),   // have both amd and intel in one system
      .hasProcessorVendor(.intel),
      .hasStorageMinimumOf(1000)
    ]
    let failingSpec = Specification<Computer>.all(of: failingRequirements)
    
    #expect(!failingSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`all` with empty array returns everything")
  func testAllEmpty() {
    let studioComputerRequirements: [ComputerSpecification] = []
    let completeSpec = Specification<Computer>.all(of: studioComputerRequirements)
    
    #expect(completeSpec.isSatisfiedBy(Computer.AIO_INL_8DDR4_256SSD))
    #expect(completeSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_256SSD))
    #expect(completeSpec.isSatisfiedBy(Computer.AIO_AMD_8DDR4_512SSD))
    #expect(completeSpec.isSatisfiedBy(Computer.LAP_M2_16DDR5_512SSD))
    #expect(completeSpec.isSatisfiedBy(Computer.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`where(_:, equals:)` works correctly & play along with `or`, `and`, `not`")
  func testWhereKeypathEquals() {
    let m2MacSpec: Specification<Computer> = .where(\.processor, equals: .M2_APL_8)
    #expect( m2MacSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect(!m2MacSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect(!m2MacSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let intelComputerSpec: ComputerSpecification = .where(\.processor.vendor, equals: .intel)
    #expect(!intelComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect( intelComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect( intelComputerSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let x86ComputerSpec: ComputerSpecification = .where(\.processor.vendor, equals: .amd)
      .or(.where(\.processor.vendor, equals: .intel))
    #expect(!x86ComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect( x86ComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect( x86ComputerSpec.isSatisfiedBy(.AIO_AMD_8DDR4_256SSD))
    
    let ddr5_16GbComputerSpec: ComputerSpecification = .where(\.ramSticks.first?.type, equals: .ddr5)
      .and(.where(\.ramSticks.first?.capacityInGB, equals: 16))
    #expect(ddr5_16GbComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    
    let notIntelComputerSpec = intelComputerSpec.not()
    #expect( notIntelComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect(!notIntelComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect(!notIntelComputerSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`where(_:, satisfies:)` works correctly & play along with `or`, `and`, `not`")
  func testWhereKeypathSatisfies() {
    let m2MacSpec: Specification<Computer> = .where(\.processor) { $0 == .M2_APL_8 }
    #expect( m2MacSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect(!m2MacSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect(!m2MacSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let intelComputerSpec: ComputerSpecification = .where(\.processor.vendor) { $0 == .intel }
    #expect(!intelComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect( intelComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect( intelComputerSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let x86ComputerSpec: ComputerSpecification = .where(\.processor.vendor) { [.amd, .intel].contains($0) }
    #expect(!x86ComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect( x86ComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect( x86ComputerSpec.isSatisfiedBy(.AIO_AMD_8DDR4_256SSD))
    
    let ddr5_16GbComputerSpec: ComputerSpecification = .where(\.ramSticks) { sticks in sticks.allSatisfy({ 
      ($0.type == .ddr5) && ($0.capacityInGB == 16)
    })}
    #expect(ddr5_16GbComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    
    let notIntelComputerSpec = intelComputerSpec.not()
    #expect( notIntelComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect(!notIntelComputerSpec.isSatisfiedBy(.AIO_INL_8DDR4_256SSD))
    #expect(!notIntelComputerSpec.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
  }
  
  
  @Test("`where(_:, contains:)` works correctly & play along with `or`, `and`, `not`")
  func testWhereKeypathContains() {
    let ddr5_16GbComputerSpec: ComputerSpecification = .where(\.ramSticks, contains: .DDR5_16GB)
    #expect(ddr5_16GbComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    
    let internetCapableComputer: ComputerSpecification = .where(\.preloadedSoftwares, contains: .browser)
    #expect(!internetCapableComputer.isSatisfiedBy(.AIO_AMD_8DDR4_512SSD))
    #expect( internetCapableComputer.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect( internetCapableComputer.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let internetIncapableBrowser = internetCapableComputer.not()
    #expect( internetIncapableBrowser.isSatisfiedBy(.AIO_AMD_8DDR4_512SSD))
    #expect(!internetIncapableBrowser.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
    #expect(!internetIncapableBrowser.isSatisfiedBy(.DST_INL_16DDR5_1024SSD))
    
    let modernComputerSpec: ComputerSpecification = ddr5_16GbComputerSpec
      .and(.where(\.disks, contains: .SSD512)
           .or(.where(\.disks, contains: .SSD256)))
    #expect(modernComputerSpec.isSatisfiedBy(.LAP_M2_16DDR5_512SSD))
  }
  
}
// swiftlint:enable type_body_length



typealias ComputerSpecification = Specification<Computer>
extension ComputerSpecification {
  
  
  static func hasProcessorVendor(_ vendor: ProcessorVendor) -> ComputerSpecification {
    .init { $0.processor.vendor == vendor }
  }
  
  
  static func hasUniformRamArchitecture(_ arc: MemoryType) -> ComputerSpecification {
    .init { computer in computer.ramSticks.allSatisfy({ $0.type == arc }) }
  }
  
  
  static func hasFormFactor(_ ff: FormFactor) -> ComputerSpecification {
    .init { $0.formFactor == ff }
  }
  
  
  static func hasStorageMinimumOf(_ min: Int) -> ComputerSpecification {
    .init { $0.disks.map({ $0.capacityInGB }).reduce(0, +) >= min }
  }
  
  
  static func hasPreloadedSoftware(_ software: Software) -> ComputerSpecification {
    .init { $0.preloadedSoftwares.contains(software) }
  }
  
}
extension ComputerSpecification {
  
  
  static let amdLaptop = ComputerSpecification.hasProcessorVendor(.amd).and(.hasFormFactor(.laptop))
  
}
