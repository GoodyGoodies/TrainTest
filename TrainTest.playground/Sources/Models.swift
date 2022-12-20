import Foundation

// MARK: - TrainPart

public class TrainPart: Hashable, CustomStringConvertible {
    public let id = UUID().uuidString
    public let weight: Double
    public let length: Double
    public let maxPersonsCount: Int
    public let maxGoodsWeight: Double
    
    public var description: String {
        "Train Part №\(id)"
    }
    
    fileprivate var isUsed = false
    
    public init(weight: Double, length: Double, maxPersonsCount: Int, maxGoodsWeight: Double) {
        self.weight = weight
        self.length = length
        self.maxPersonsCount = maxPersonsCount
        self.maxGoodsWeight = maxGoodsWeight
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: TrainPart, rhs: TrainPart) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Locomotive

public class Locomotive: TrainPart {
    public let pullingForce: Double
    public let type: LocomotiveType
    
    public override var description: String {
        "Locomotive №\(id)"
    }

    public init(
        weight: Double,
        length: Double,
        maxPersonsCount: Int,
        maxGoodsWeight: Double,
        pullingForce: Double,
        type: LocomotiveType
    ) {
        self.pullingForce = pullingForce
        self.type = type
        super.init(weight: weight, length: length, maxPersonsCount: maxPersonsCount, maxGoodsWeight: maxGoodsWeight)
    }
}

// MARK: - Wagon

public class Wagon: TrainPart {
    public let manufacturerName: String
    public let productionYear: Int
    public let type: WagonType
    
    public override var description: String {
        "Wagon №\(id)"
    }
    
    public init(
        weight: Double,
        length: Double,
        maxPersonsCount: Int,
        maxGoodsWeight: Double,
        manufacturerName: String,
        productionYear: Int,
        type: WagonType
    ) {
        self.manufacturerName = manufacturerName
        self.productionYear = productionYear
        self.type = type
        super.init(weight: weight, length: length, maxPersonsCount: maxPersonsCount, maxGoodsWeight: maxGoodsWeight)
    }
}

// MARK: - Train

public class Train {
    
    // MARK: - Properties
    
    public var conductorsCount: Int {
        maxPersonsCount % 50 == 0 ? maxPersonsCount / 50 : 1 + (maxPersonsCount / 50)
    }
    
    public var allParts: [TrainPart] {
        locomotives + wagons
    }
    
    public var emptyWeight: Double {
        allParts.reduce(0) { $0 + $1.weight }
    }
    
    public var maxPersonsCount: Int {
        allParts.reduce(0) { $0 + $1.maxPersonsCount }
    }
    
    public var maxGoodsWeight: Double {
        allParts.reduce(0) { $0 + $1.maxGoodsWeight }
    }
    
    public var maxPayload: Double {
        Double(maxPersonsCount) * Constants.averagePersonWeight +
        maxGoodsWeight +
        Double(conductorsCount) * Constants.averagePersonWeight
    }
    
    public var maxOverallWeight: Double {
        maxPayload + emptyWeight
    }
    
    public var length: Double {
        allParts.reduce(0) { $0 + $1.length }
    }
    
    private(set) var locomotives: [Locomotive] = []
    private(set) var wagons: [Wagon] = []
    private(set) var state: TrainState = .stopped
    
    private var isMaxPayloadPossibleToPull: Bool {
        let overallPullingForce = locomotives.reduce(0) { $0 + $1.pullingForce }
        return overallPullingForce >= maxOverallWeight
    }
    
    // MARK: - Init
    
    public init(
        locomotive: Locomotive
    ) throws {
        try add(locomotive: locomotive)
    }
    
    // MARK: - Methods
    
    public func getTrainPartsDescriptions() {
        allParts.forEach { print($0.description) }
    }

    public func add(locomotive: Locomotive, at index: Int? = nil) throws {
        guard state == .stopped else {
            throw TrainErrors.changesProhibitedInMove
        }
        
        guard !locomotive.isUsed else {
            throw LocomotiveErrors.alreadyUsed
        }
        
        if let index = index, locomotives.indices.contains(index) {
            locomotives.insert(locomotive, at: index)
        } else {
            locomotives.append(locomotive)
        }
        
        locomotive.isUsed = true
    }
    
    public func remove(locomotive: Locomotive) throws {
        guard state == .stopped else {
            throw TrainErrors.changesProhibitedInMove
        }
        
        guard locomotives.count > 1 else {
            throw TrainErrors.removingLonelyLocomotiveProhibited
        }
        
        guard locomotive.isUsed else {
            throw LocomotiveErrors.isNotUsed
        }
        
        if let index = locomotives.firstIndex(where: { $0 == locomotive }) {
            locomotives.remove(at: index)
            locomotive.isUsed = false
        } else {
            throw TrainErrors.unknown
        }
    }
    
    public func add(wagon: Wagon, at index: Int? = nil) throws {
        guard state == .stopped else {
            throw TrainErrors.changesProhibitedInMove
        }
        
        guard !wagon.isUsed else {
            throw WagonErrors.alreadyUsed
        }
        
        if let index = index, wagons.indices.contains(index) {
            wagons.insert(wagon, at: index)
        } else {
            wagons.append(wagon)
        }
        
        wagon.isUsed = true
    }
    
    public func remove(wagon: Wagon) throws {
        guard state == .stopped else {
            throw TrainErrors.changesProhibitedInMove
        }
        
        guard wagon.isUsed else {
            throw WagonErrors.isNotUsed
        }
        
        if let index = wagons.firstIndex(where: { $0 == wagon }) {
            wagons.remove(at: index)
            wagon.isUsed = false
        } else {
            throw TrainErrors.unknown
        }
    }
    
    public func start() throws {
        guard state == .stopped else {
            throw TrainErrors.alreadyStarted
        }
        
        guard isMaxPayloadPossibleToPull else {
            throw TrainErrors.lackPullingForce
        }
        
        state = .moved
        print("we started!")
    }
    
    public func stop() throws {
        guard state == .moved else {
            throw TrainErrors.alreadyStopped
        }
        
        state = .stopped
        print("we stopped")
    }
}

// MARK: - Mocks

public final class LocomotiveMock: Locomotive {
    public override init(weight: Double = 10.0, length: Double = 10.0, maxPersonsCount: Int = 0, maxGoodsWeight: Double = 10.0, pullingForce: Double = 30 , type: LocomotiveType = .disel) {
        super.init(weight: weight, length: length, maxPersonsCount: maxPersonsCount, maxGoodsWeight: maxGoodsWeight, pullingForce: pullingForce, type: type)
    }
}

public final class WagonMock: Wagon {
    public override init(weight: Double = 10.0, length: Double = 10.0, maxPersonsCount: Int = 0, maxGoodsWeight: Double = 10.0, manufacturerName: String = "Some Name", productionYear: Int = 2022, type: WagonType = .freight) {
        super.init(weight: weight, length: length, maxPersonsCount: maxPersonsCount, maxGoodsWeight: maxGoodsWeight, manufacturerName: manufacturerName, productionYear: productionYear, type: type)
    }
}
