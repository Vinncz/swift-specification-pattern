# Swift Specification Pattern

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Swift Version](https://img.shields.io/badge/swift-6.0-blue)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-blue)

Use the Swift Specification Pattern package to get up with speed in applying the Specification Pattern in your Swift projects.

Refer to the [documentation](https://vinncz.github.io/swift-specification-pattern/documentation/SpecificationPattern) for exhaustive definitions, relationships, and examples.

## TLDR; Spcecification Pattern?
A `specification` is a building block that makes up complex filter.

It's best described this way. Given a repository contract:
```swift
struct ExpenseRepository {
  var findByWalletId(_ wid: Wallet.ID) async -> [Expense]
  var findByCategoryId(_ cid: Category.ID) async -> [Expense]
  
  var findByWalletIdAndCategoryId(_ wid: Wallet.ID, _ cid: Category.ID) async -> [Expense]
  var findByWalletIdAndDateRange(_ wid: Wallet.ID, _ sd: Date, _ ed: Date) async -> [Expense]
  // more permutations...
}
```

Using the specification pattern, its day and night.
```swift
let spec = Specification<Expense>.all
  .andIfNotEmpty(selectedWallets, applyOrBetween: { .hasWalletId($0.id) })
  .andIfNotEmpty(selectedCategories, applyAndBetween: { .hasCategory($0.id) })
  .andIfPresent(dateRange) { .isInDateRange($0) }
  
expenseRepository.find(matching: spec)
```

Specification pattern takes **infinite** combinations into **one** chain.

## Where Applicable?

### A. Cross-layer Reuse
```swift
// constant specification used in multiple contexts
let highValueExpenseSpec: Specification<Expense> = .where(\.cost) { $0 >= .USD(99) }

// use case validation (apl layer)
let isHighValue = highValueExpenseSpec.isSatisfiedBy(expense)

// repository query (infra layer)
let highValueExpenses = await expenseRepo.find(matching: highValueExpenseSpec)

// view filtering (composition layer)
let filteredExpenses = allExpenses.filter(highValueExpenseSpec.isSatisfiedBy)

// analytics
let highValueCount = allExpenses.count(where: highValueExpenseSpec.isSatisfiedBy)
```

### B. Rule Validation
```swift
// whether budget can accommodate new expense
let canAddExpenseRule: Specification<Wallet> = .hasActiveBudget()
 .and(.canAfford(expense.cost))
 .and(.where(\.budget.allowedCategory) { $0.contains([.transport]) })
 
if canAddExpenseRule.isSatisfiedBy(wallet) {
  // proceed to add expense
} else {
  // show error to user
}
```

### C. Dynamic Filtering
Declare specification based on view's state. As it change, so does the spec, and in turn, the shown data.
```swift
// using TCA use case
@ObservableState
struct ExpenseListViewState {
  var selectedWallet: Wallet.ID? = nil  // may or may not select
  var shownCategories: [Category] = []
  var dateRange: DateRange? = nil
  
  var filteredExpenses: [Expense] {
    let spec = Specification<Expense>.all
      .andIfPresent(selectedWallet) { .hasWalletId($0) }
      .andIfNotEmpty(shownCategories, applyOrBetween: { .hasCategory($0.id) })
      .andIfPresent(dateRange) { .isInDateRange($0) }
    
    return allExpenses.filter(spec.isSatisfiedBy)
  }
}
```

## Installation
1. Add the following snippet to `Package.swift`
   ```swift
   dependencies: [
     .package(url: "https://github.com/Vinncz/swift-specification-pattern.git", from: "1.0.0")
   ]
   ```
   
2. Add `SpecificationPattern` to target dependencies.

## Up and Running

### 1. Declare a Specification

```swift
import SpecificationPattern
typealias ComputerSpecification = Specification<Computer>  // your model type
```

### 2. (Optional) List Predefined Specifications

Staticly predefined rules will help tremendously; as you'll see in the next step.
```swift
extension ComputerSpecification {
  static func hasProcessorVendor(_ vendor: String) -> ComputerSpecification {
    .init { $0.processor.vendor == vendor }
  }
  static func hasStorageMinimumOf(_ gb: Int) -> ComputerSpecification {
    .init { computer in
      computer.storageDrives.reduce(0) { $0 + $1.capacityInGB } >= gb
    }
  }
}
```

### 3. Use It
There are several ways to use the specifications.

**One** is to declare everything upfront and combine them via the `any` or `all` factory.
```swift
let studioComputerRequirements: [ComputerSpecification] = [
  .hasFormFactor(.desktop),  // looks very nice with static methods
  .hasProcessorVendor("AMD").or(.hasProcessorVendor("Intel")),
  .hasStorageMinimumOf(1000)
]
let targetComputer: Specification = .all(of: studioComputerRequirements)

#expect(targetComputer.isSatisfiedBy(.studioBeast))
```

**Two** is to approach it like a view's state.
```swift
var minimumStorage: Int?                              // user has not specified
var preferredProcessorVendor: [ProcessorVendor] = []  // vendors must be ANY of these
var preloadedSoftwares: [Software] = []               // computers must have ALL of these

let spec: () -> ComputerSpecification = {
  ComputerSpecification.all
    .andIfPresent(minimumStorage) { .hasStorageMinimumOf($0) }
    .andIfNotEmpty(preferredProcessorVendor, applyOrBetween: { .hasProcessorVendor($0) })
    .andIfNotEmpty(preloadedSoftwares, applyAndBetween: { .hasPreloadedSoftware($0) })  // only applied if not empty
}
```

**Three** is to wing it inline.
```swift
let m2MacSpec: Specification<Computer> = .where(\.processor) { $0 == .M2_APL_8 }
let x86ComputerSpec: ComputerSpecification = .where(\.processor.vendor) { [.amd, .intel].contains($0) }
let ddr5_16GbComputerSpec: ComputerSpecification = .where(\.ramSticks) { sticks in sticks.allSatisfy({ 
  ($0.type == .ddr5) && ($0.capacityInGB == 16)
})}

// psycopathic one-liner
let highEndGamingRigSpec: ComputerSpecification = .all
  .and(.where(\.formFactor) { $0 == .desktop })
  .and(.where(\.processor.vendor) { [.amd, .intel].contains($0) })
  .and(.where(\.ramSticks) { sticks in sticks.allSatisfy({ 
    ($0.type == .ddr5) && ($0.capacityInGB >= 16)
  })})
  .and(.where(\.gpus) { gpus in gpus.contains(where: { $0.model.contains("RTX") || $0.model.contains("RX") }) })
  .and(.where(\.storageDrives) { drives in drives.contains(where: { $0.capacityInGB >= 2000 }) })
  .and(.where(\.preloadedSoftwares) { softwares in softwares.contains(where: { $0.name == "Steam" }) })
```

## Testing
The Swift Specification Pattern package was tested for a number of usage scenarios using the modern SwiftTesting framework.
Testplan included.

## Requirements
- Swift 5.5+
- iOS 12.0+ / macOS 10.13+ / watchOS 4.0+ / tvOS 12.0+ / visionOS 1.0+

## Contributing
Contributions welcome, issues and PRs are open.

Do adhere to the existing code style and include tests for new features or bug fixes.

swift package --allow-writing-to-directory "./docs" \
    generate-documentation --target "SpecificationPattern" \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path "swift-specification-pattern/" \
    --output-path "./docs"
