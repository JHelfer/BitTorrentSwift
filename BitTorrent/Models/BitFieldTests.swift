//
//  BitFieldTests.swift
//  BitTorrentTests
//
//  Created by Ben Davis on 08/07/2017.
//  Copyright © 2017 Ben Davis. All rights reserved.
//

import XCTest
@testable import BitTorrent

class BitFieldTests: XCTestCase {
    
    func test_create() {
        let sut = BitField(size: 5)
        XCTAssertEqual(sut.size, 5)
        XCTAssertEqual(sut.value, [false, false, false, false, false])
    }
    
    func test_canSetValueAtIndex() {
        var sut = BitField(size: 5)
        sut.set(at: 0)
        sut.set(at: 2)
        sut.set(at: 4)
        XCTAssertEqual(sut.value, [true, false, true, false, true])
    }
    
    func test_canUnsetValueAtIndex() {
        var sut = BitField(size: 5)
        sut.set(at: 0)
        sut.set(at: 2)
        sut.set(at: 4)
        sut.unset(at: 4)
        XCTAssertEqual(sut.value, [true, false, true, false, false])
    }
    
    func test_canTestAtIndex() {
        var sut = BitField(size: 5)
        sut.set(at: 0)
        sut.set(at: 2)
        XCTAssertTrue(sut.isSet(at: 0))
        XCTAssertFalse(sut.isSet(at: 1))
        XCTAssertTrue(sut.isSet(at: 2))
        XCTAssertFalse(sut.isSet(at: 3))
        XCTAssertFalse(sut.isSet(at: 4))
    }
    
    func test_canConvertToData_bitsAlignToBytes() {
        var sut = BitField(size: 16)
        sut.set(at: 7)
        sut.set(at: 15)
        sut.set(at: 14)
        let result = sut.toData()
        XCTAssertEqual(result, Data(bytes:[1, 3]))
    }
    
    func test_canConvertToData_bitsDoNotAlignToBytes() {
        var sut = BitField(size: 13)
        sut.set(at: 7)
        sut.set(at: 12)
        let result = sut.toData()
        XCTAssertEqual(result, Data(bytes:[1, 8]))
    }
    
    func test_canConvertToData_lessThan8Bits() {
        var sut = BitField(size: 5)
        sut.set(at: 3)
        let result = sut.toData()
        XCTAssertEqual(result, Data(bytes:[16]))
    }
    
    func test_canInitWithData() {
        var example = BitField(size: 16)
        example.set(at: 7)
        example.set(at: 15)
        example.set(at: 14)
        
        let data = example.toData()
        let result = BitField(data: data, size: 16)
        XCTAssertEqual(result, example)
    }
    
    func test_canEnumerateThrough() {
        var example = BitField(size: 5)
        
        example.set(at: 2)
        example.set(at: 3)
        
        var indices: [Int] = []
        var values: [Bool] = []
        for (index, isSet) in example {
            indices.append(index)
            values.append(isSet)
        }
        
        XCTAssertEqual(indices, [0,1,2,3,4])
        XCTAssertEqual(values, [false,false,true,true,false])
    }
    
    func test_allBitsSet() {
        var example = BitField(size: 5)
        example.set(at: 0)
        example.set(at: 1)
        example.set(at: 2)
        example.set(at: 3)
        
        XCTAssertFalse(example.complete)
        example.set(at: 4)
        XCTAssertTrue(example.complete)
    }
}
