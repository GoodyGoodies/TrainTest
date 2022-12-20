/*
 # README
 - - - - - - - - - -
 
 Assumptions:
 
 1. Locomotives are always at the head of a train.
 
 2. Conductors are not taken into account in maximum person count restrictions.
 
 3. Conductors count influences on the value of the payload and the max overall weight accordingly.
 
 4. Practically you can initialize train and locomotive with not enough pulling forces, but you will not be able to start.
  
*/

import Foundation

// MARK: - Usage

let locomotive = Locomotive(weight: 132.5, length: 10, maxPersonsCount: 1, maxGoodsWeight: 32, pullingForce: 1231243, type: .disel)
let wagon = Wagon(weight: 234, length: 25, maxPersonsCount: 10, maxGoodsWeight: 123, manufacturerName: "Some Name", productionYear: 2007, type: .freight)
let secondWagon = Wagon(weight: 234, length: 25, maxPersonsCount: 10, maxGoodsWeight: 123, manufacturerName: "Some Name", productionYear: 2007, type: .freight)
let train = try? Train(locomotive: locomotive)
try? train?.add(locomotive: locomotive)
train?.getTrainPartsDescriptions()
try? train?.add(wagon: wagon)
try? train?.start()
try? train?.add(wagon: wagon)
try? train?.stop()
try? train?.add(wagon: secondWagon)
train?.getTrainPartsDescriptions()
train?.maxOverallWeight
train?.maxPersonsCount

// MARK: - Tests

import XCTest

final class TrainTests: XCTestCase {
    
    var train: Train!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        train = nil
        super.tearDown()
    }
    
    func test_addLocomotive_IsPossible_whenLocomotiveIsNotUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_addLocomotiveAtIndex_InPossible_whenLocomotiveIsNotUsedAndIndexIsKnown() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        let thirdLocomotive = LocomotiveMock()
        try? train.add(locomotive: thirdLocomotive, at: 1)
        
        XCTAssertEqual(train.allParts[1].id, thirdLocomotive.id)
    }
    
    func test_addLocomotive_AddsAtTails_whenIndexIsWrong() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        let thirdLocomotive = LocomotiveMock()
        try? train.add(locomotive: thirdLocomotive, at: 10000)
        
        XCTAssertEqual(train.allParts[2].id, thirdLocomotive.id)
    }
    
    func test_addLocomotive_isImpossible_whenLocomotiveIsUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        try? train.add(locomotive: locomotive)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
    
    func test_addLocomotive_IsImpossible_WhenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        try? train.start()
        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
    
    func test_removeLocomotive_isPossible_whenLocomotiveIsUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        try? train.remove(locomotive: secondLocomotive)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
    
    func test_removeLocomotive_isImpossible_whenLocomotiveIsNotUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let secondLocomotive = LocomotiveMock()
        try? train.remove(locomotive: secondLocomotive)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
        
    func test_removeLocomotive_IsImpossible_WhenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let secondLocomotive = LocomotiveMock()
        try? train.add(locomotive: secondLocomotive)
        
        try? train.start()
        try? train.remove(locomotive: secondLocomotive)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_removeLocomotive_isImpossible_WhenTrainHasLonelyLocomotive() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        try? train.remove(locomotive: locomotive)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
    
    func test_addWagon_IsPossible_whenWagonIsNotUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_addWagonAtIndex_InPossible_whenWagonIsNotUsedAndIndexIsKnown() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        let secondWagon = WagonMock()
        try? train.add(wagon: secondWagon, at: 0)
        
        XCTAssertEqual(train.allParts[1].id, secondWagon.id)
    }
    
    func test_addWagon_AddsAtTails_whenIndexIsWrong() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        let secondWagon = WagonMock()
        try? train.add(wagon: secondWagon, at: 10000)

        XCTAssertEqual(train.allParts[2].id, secondWagon.id)
    }

    func test_addWagon_IsImpossible_WhenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        try? train.start()
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.allParts.count, 1)
    }
        
    func test_addWagon_isImpossible_whenWagonIsUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_removeWagon_isPossible_whenWagonIsUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_removeWagon_isImpossible_whenWagonIsNotUsed() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        let secondWagon = WagonMock()
        try? train.remove(wagon: secondWagon)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_removeWagon_IsImpossible_WhenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock()
        try? train.add(wagon: wagon)
        
        try? train.start()
        try? train.remove(wagon: wagon)
        
        XCTAssertEqual(train.allParts.count, 2)
    }
    
    func test_ConductorCount_IsZero_WhenMaxPersonsCountIsZero() {
        let locomotive = LocomotiveMock(maxPersonsCount: 0)
        train = try? .init(locomotive: locomotive)
        
        XCTAssertEqual(train.conductorsCount, 0)
    }
    
    func test_ConductorCount_IsIncreasedByOne_ForEveryFiftyMaxPassengerCount() {
        let locomotive = LocomotiveMock(maxPersonsCount: 2)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(maxPersonsCount: 48)
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.conductorsCount, 1)
        
        let secondWagon = WagonMock(maxPersonsCount: 1)
        try? train.add(wagon: secondWagon)
        
        XCTAssertEqual(train.conductorsCount, 2)
    }
    
    func test_getEmptyWeight_returnWightSumOfAllTrainParts() {
        let locomotive = LocomotiveMock(weight: 10)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(weight: 20)
        try? train.add(wagon: wagon)
                
        XCTAssertEqual(train.emptyWeight, 30)
    }
    
    func test_getMaxPassengersCount_returnMaxPassengersCountSumOfAllTrainParts() {
        let locomotive = LocomotiveMock(maxPersonsCount: 10)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(maxPersonsCount: 20)
        try? train.add(wagon: wagon)
                
        XCTAssertEqual(train.maxPersonsCount, 30)
    }
    
    func test_getMaxGoodsWeight_returnMaxGoodsWeightSumOfAllTrainParts() {
        let locomotive = LocomotiveMock(maxGoodsWeight: 10)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(maxGoodsWeight: 20)
        try? train.add(wagon: wagon)
                
        XCTAssertEqual(train.maxGoodsWeight, 30)
    }
    
    func test_getMaxPayload_returnSumOfWeightOfAllPersonsAndConductorsPlustMaxGoodsWeightOfAllTrainParts() {
        let locomotive = LocomotiveMock(maxPersonsCount: 1, maxGoodsWeight: 10)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(maxPersonsCount: 2, maxGoodsWeight: 20)
        try? train.add(wagon: wagon)
        
        XCTAssertEqual(train.maxOverallWeight, 350)
    }
    
    func test_getLength_returnLengthSumOfAllTrainParts() {
        let locomotive = LocomotiveMock(length: 10)
        train = try? .init(locomotive: locomotive)
        
        let wagon = WagonMock(length: 20)
        try? train.add(wagon: wagon)
                
        XCTAssertEqual(train.length, 30)
    }
    
    func test_start_isPossible_whenTrainIsNotInMove_and_pullingForcesAreEnough() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        XCTAssertNoThrow(try train.start())
    }
    
    func test_start_isImpossible_whenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        XCTAssertNoThrow(try train.start())
        XCTAssertThrowsError(try train.start())
    }
    
    func test_start_isImpossible_whenPllingForcesAreNotEnough() {
        let locomotive = LocomotiveMock(pullingForce: 0)
        train = try? .init(locomotive: locomotive)

        XCTAssertThrowsError(try train.start())
    }
    
    func test_stop_isPossible_whenTrainIsInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)
        
        XCTAssertNoThrow(try train.start())
        XCTAssertNoThrow(try train.stop())
    }
    
    func test_stop_isImpossible_whenTrainIsNotInMove() {
        let locomotive = LocomotiveMock(pullingForce: 1000)
        train = try? .init(locomotive: locomotive)

        XCTAssertThrowsError(try train.stop())
    }
}

TrainTests.defaultTestSuite.run()
