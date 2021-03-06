//
//  TorrentClientManagerStubs.swift
//  BitTorrent
//
//  Created by Ben Davis on 13/08/2017.
//  Copyright © 2017 Ben Davis. All rights reserved.
//

@testable import BitTorrent

class TorrentServerStub: TorrentServer {
    init(metaInfo: TorrentMetaInfo) {
        let clientId = Data(repeating: 1, count: 20)
        super.init(infoHash: metaInfo.infoHash, clientId: clientId)
    }
    
    var startListeningCalled = false
    override func startListening() {
        startListeningCalled = true
    }
}

class TorrentProgressManagerStub: TorrentProgressManager {
    
    let fileHandle: FileHandleFake
    
    init(metaInfo: TorrentMetaInfo) {
        fileHandle = FileHandleFake(data: Data(repeating: 0, count: metaInfo.info.length))
        let fileManager = TorrentFileManager(metaInfo: metaInfo, rootDirectory: "/", fileHandles: [fileHandle])
        let progress = TorrentProgress(size: metaInfo.info.pieces.count)
        super.init(fileManager: fileManager, progress: progress)
    }
    
    var testProgress = TorrentProgress(size: 1)
    override var progress: TorrentProgress {
        return testProgress
    }
    
    var setDownloadedPieceCalled = false
    var setDownloadedPieceParameters: (piece: Data, pieceIndex: Int)?
    override func setDownloadedPiece(_ piece: Data, pieceIndex: Int) {
        setDownloadedPieceCalled = true
        setDownloadedPieceParameters = (piece, pieceIndex)
    }
    
    var setLostPieceCalled = false
    var setLostPieceIndex: Int = 0
    override func setLostPiece(at index: Int) {
        setLostPieceCalled = true
        setLostPieceIndex = index
    }
    
    var getNextPieceToDownloadCalled = false
    var getNextPieceToDownloadParameter: BitField?
    var getNextPieceToDownloadResult: TorrentPieceRequest?
    override func getNextPieceToDownload(from availablePieces: BitField) -> TorrentPieceRequest? {
        getNextPieceToDownloadCalled = true
        getNextPieceToDownloadParameter = availablePieces
        return getNextPieceToDownloadResult
    }
}

class TorrentPeerManagerStub: TorrentPeerManager {
    
    init(metaInfo: TorrentMetaInfo) {
        let clientId = Data(repeating: 1, count: 20)
        super.init(clientId: clientId, infoHash: metaInfo.infoHash, bitFieldSize: metaInfo.info.pieces.count)
    }
    
    var addPeersCalled = false
    var addPeersParameter: [TorrentPeerInfo]? = nil
    override func addPeers(withInfo peerInfos: [TorrentPeerInfo]) {
        addPeersCalled = true
        addPeersParameter = peerInfos
    }
    
    var addPeerCalled = false
    var addPeerParameter: TorrentPeer? = nil
    override func addPeer(_ peer: TorrentPeer) {
        addPeerCalled = true
        addPeerParameter = peer
    }
}

class TorrentTrackerManagerStub: TorrentTrackerManager {
    
    let tracker = TorrentTrackerStub()
    
    init(metaInfo: TorrentMetaInfo) {
        let clientId = Data(repeating: 1, count: 20)
        super.init(metaInfo: metaInfo, clientId: clientId, port: 123, trackers: [tracker])
    }
    
    var startCalled = false
    override func start() {
        startCalled = true
    }
}
