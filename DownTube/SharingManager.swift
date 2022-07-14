//
//  SharingManager.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/11/22.
//

import Foundation
import MultipeerConnectivity
import Combine
class SharingManager: NSObject, ObservableObject {
    static let shared = SharingManager()
    private override init() {
        super.init()
    }
    let serviceType = "downtube-sharer"
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var activeSession: MCSession? {
        didSet {
            activeSession?.delegate = self
        }
    }
    private lazy var advertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(peer: SharingManager.shared.peerID, discoveryInfo: nil, serviceType: SharingManager.shared.serviceType)
        advertiser.delegate = SharingManager.shared
        return advertiser
    }()
    private lazy var browser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: SharingManager.shared.peerID, serviceType: SharingManager.shared.serviceType)
        browser.delegate = SharingManager.shared
        return browser
    }()
    @Published var isDiscoverable = false
    @Published var peers: [MCPeerID] = []
    @Published var peerConnectivity: [MCPeerID: Bool] = [:]
    @Published var isAvailable = true
    var handlerForPeerConnectivity: (peer: MCPeerID, handler: ((Bool) -> Void))?
    func beginAdvertising() {
        advertiser.startAdvertisingPeer()
        isDiscoverable = true
    }
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        isDiscoverable = false
    }
    func startSearchingForAvailablePeers() {
        browser.startBrowsingForPeers()
    }
    func stopSearchingForAvailablePeers() {
        browser.stopBrowsingForPeers()
        peers.removeAll()
        activeSession?.disconnect()
        activeSession = nil
    }
    func createSession() -> MCSession {
        MCSession(peer: peerID)
    }
    func connectToPeer(peer: MCPeerID,_ handler: @escaping ((Bool) -> Void)) {
        if activeSession == nil {
            activeSession = createSession()
        }
        guard activeSession!.connectedPeers.isEmpty else { return }
        browser.invitePeer(peer, to: activeSession!, withContext: nil, timeout: 30)
        handlerForPeerConnectivity = (peer, handler)
    }
    func sendVideo(_ video: Video) -> Progress? {
        let vidURL = video.videoUrl
        if activeSession == nil {
            activeSession = createSession()
        }
        guard !peers.isEmpty else { return nil }
        do {
            try activeSession!.send(video.sharingData()!, toPeers: peers, with: .reliable)
            return activeSession!.sendResource(at: vidURL, withName: video.videoId, toPeer: peers[0])
        } catch {
            print(error)
            Logs.addError(error)
            return nil
        }
    }
    func peerConnectionStatus(peer: MCPeerID) -> Bool {
        peerConnectivity[peer] ?? false
    }
}
extension SharingManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("request")
        MainViewUpdator.shared.getUserInputToAcceptConnection(name: peerID.displayName) { accepted in
            if self.activeSession == nil {
                self.activeSession = self.createSession()
            }
            invitationHandler(accepted, self.activeSession!)
        }
        
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Logs.addError(error)
        print(error)
    }
}
extension SharingManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard !peers.contains(where: { $0 === peerID }) else {
            return
        }
        peers.append(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll {
            $0.isEqual(peerID)
        }
    }
}
extension SharingManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            let connected: Bool
            switch state {
            case .notConnected:
                connected = false
            case .connecting:
                connected = false
            case .connected:
                connected = true
            @unknown default:
                connected = false
            }
            self.peerConnectivity[peerID] = connected
            guard let handler = self.handlerForPeerConnectivity else { return }
            if peerID.hash == handler.peer.hash {
                handler.handler(connected)
            }
        }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.sync {
            Video.addVideo(from: data)
        }
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        DispatchQueue.main.sync {
            let vid = Video.video(for: resourceName)
            vid?.downloadProgress = progress
        }
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        DispatchQueue.main.sync {
            guard error == nil else {
                Logs.addError(error!)
                return
            }
            guard let localURL = localURL else {
                return
            }
            let vid = Video.video(for: resourceName)
            vid?.videoFinishedDownloading(localURL)
            session.disconnect()
            activeSession = nil
        }
    }
}
extension MCPeerID: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
