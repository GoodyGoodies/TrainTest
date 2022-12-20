import Foundation

public enum TrainErrors: Error {
    case alreadyStarted
    case alreadyStopped
    case lackPullingForce
    case changesProhibitedInMove
    case removingLonelyLocomotiveProhibited
    case unknown
}

public enum LocomotiveErrors: Error {
    case alreadyUsed
    case isNotUsed
}

public enum WagonErrors: Error {
    case alreadyUsed
    case isNotUsed
}

public enum WagonType {
    case passenger
    case sleeping
    case restaurant
    case freight
}

public enum LocomotiveType {
    case disel
    case electrical
    case steam
}

public enum TrainState {
    case stopped
    case moved
}

