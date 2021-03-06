//
//  NetworkSpeedTracker.swift
//  BitTorrent
//
//  Created by Ben Davis on 13/08/2017.
//  Copyright © 2017 Ben Davis. All rights reserved.
//

import Foundation

public protocol NetworkSpeedTrackable {
    var totalNumberOfBytes: Int { get }
    func numberOfBytesDownloaded(since date: Date) -> Int
    func numberOfBytesDownloaded(over timeInterval: TimeInterval) -> Int
}

public struct NetworkSpeedTracker: NetworkSpeedTrackable {
    public var totalNumberOfBytes: Int = 0
    
    // TODO: limit number of dataPoints stored
    private var dataPoints: [NetworkSpeedDataPoint] = [NetworkSpeedDataPoint(0)]
    
    mutating func increase(by bytes: Int) {
        totalNumberOfBytes += bytes
        addDataPoint(NetworkSpeedDataPoint(totalNumberOfBytes))
    }
    
    private mutating func addDataPoint(_ dataPoint: NetworkSpeedDataPoint) {
        dataPoints = [dataPoint] + dataPoints
    }
    
    public func numberOfBytesDownloaded(since date: Date) -> Int {
        
        guard let previouslyDataPoint = dataPoints.firstWhere({ $0.dateRecorded < date }) else {
            return totalNumberOfBytes
        }
        return totalNumberOfBytes - previouslyDataPoint.numberOfBytes
    }
    
    public func numberOfBytesDownloaded(over timeInterval: TimeInterval) -> Int  {
        return numberOfBytesDownloaded(since: Date(timeIntervalSinceNow: -timeInterval))
    }
}

public struct NetworkSpeedDataPoint: Equatable, Comparable {
    
    var numberOfBytes: Int
    var dateRecorded: Date
    
    init(_ numberOfBytes: Int, dateRecorded: Date = Date()) {
        self.numberOfBytes = numberOfBytes
        self.dateRecorded = dateRecorded
    }
    
    public static func ==(_ lhs: NetworkSpeedDataPoint, _ rhs: NetworkSpeedDataPoint) -> Bool {
        return (
            lhs.numberOfBytes == rhs.numberOfBytes &&
                lhs.dateRecorded == rhs.dateRecorded
        )
    }
    
    public static func <(lhs: NetworkSpeedDataPoint, rhs: NetworkSpeedDataPoint) -> Bool {
        return lhs.dateRecorded.compare(rhs.dateRecorded) == .orderedAscending
    }
}
// Not sure why I need this 🤷‍♂️
extension Collection {
    func firstWhere(_ predicate: (Element) -> Bool) -> Element? {
        return first(where: predicate)
    }
}
