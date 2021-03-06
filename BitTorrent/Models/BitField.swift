//
//  BitField.swift
//  BitTorrent
//
//  Created by Ben Davis on 08/07/2017.
//  Copyright © 2017 Ben Davis. All rights reserved.
//

import Foundation

public struct BitField: Equatable {
    public let size: Int
    public private(set) var value: [Bool]
    public var complete: Bool {
        return !contains(where: { !$0.isSet })
    }
    
    init(size: Int) {
        self.size = size
        self.value = Array(repeating: false, count: size)
    }
    
    init(data: Data, size: Int) {
        precondition(BitField.dataMatchesSize(size, data: data), "The number of bytes doesn't match the given size")
        self.init(size: size)
        for byteIndex in 0 ..< data.count {
            let byte = data.correctingIndicies[byteIndex]
            for i in 0 ..< 8 where (byteIndex*8 + i) < size {
                if isNthBitSet(byte, n: i) {
                    set(at: byteIndex*8 + i)
                }
            }
        }
    }
    
    private static func dataMatchesSize(_ size: Int, data: Data) -> Bool {
        let numberOfBytes = numberOfBytesForSize(size)
        return data.count == numberOfBytes
    }
    
    fileprivate func isNthBitSet(_ byte: UInt8, n: Int) -> Bool {
        let mask: [UInt8] = [128, 64, 32, 16, 8, 4, 2, 1]
        let maskN: UInt8 = mask[n]
        return (byte & maskN) != 0
    }
    
    public func isSet(at index: Int) -> Bool {
        return value[index]
    }
    
    mutating func set(at index: Int) {
        value[index] = true
    }
    
    mutating func unset(at index: Int) {
        value[index] = false
    }
    
    func toData() -> Data {
        let numberOfBytes = BitField.numberOfBytesForSize(size)
        
        var bytes: [UInt8] = []
        for i in 0..<numberOfBytes {
            let startIndex = i * 8
            var byte: UInt8
            if size >= startIndex + 8 {
                byte = UInt8(bits: (value[startIndex],
                                    value[startIndex + 1],
                                    value[startIndex + 2],
                                    value[startIndex + 3],
                                    value[startIndex + 4],
                                    value[startIndex + 5],
                                    value[startIndex + 6],
                                    value[startIndex + 7]))
            } else {
                byte = UInt8(bits: (value[startIndex],
                                    (size > startIndex + 1) ? value[startIndex + 1] : false,
                                    (size > startIndex + 2) ? value[startIndex + 2] : false,
                                    (size > startIndex + 3) ? value[startIndex + 3] : false,
                                    (size > startIndex + 4) ? value[startIndex + 4] : false,
                                    (size > startIndex + 5) ? value[startIndex + 5] : false,
                                    (size > startIndex + 6) ? value[startIndex + 6] : false,
                                    false))
            }
            bytes.append(byte)
        }
        
        return Data(bytes: bytes)
    }
    
    private static func numberOfBytesForSize(_ size: Int) -> Int {
        if (size % 8) == 0 {
            return size / 8
        } else {
            return (size / 8) + 1
        }
    }
    
    public static func ==(_ lhs: BitField, _ rhs: BitField) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BitField: Collection {
    
    public typealias Index = Array<Bool>.Index
    
    public var startIndex: Index {
        return value.startIndex
    }
    
    public var endIndex: Index {
        return value.endIndex
    }
    
    public subscript(position: Index) -> (index: Int, isSet: Bool) {
        precondition(position >= 0 && position < size, "out of bounds")
        return (index: position, isSet: value[position])
    }
    
    public func index(after i: Index) -> Index {
        return value.index(after: i)
    }
}
