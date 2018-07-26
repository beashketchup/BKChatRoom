//
//  BKChatManager.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 9/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

public class BKChatManager: NSObject {
    
    fileprivate var reachability : Reachability?
    
    fileprivate var mainSocket : SocketIOClient?
    
    fileprivate let socketQueue = DispatchQueue(label: "SOCKET_QUEUE", qos: .utility, attributes: .concurrent)
    
    //fileprivate var userConnectionCompletionBlock : UserConnectionUpdateBlock?
    //fileprivate var userTypingCompletionBlock : UserTypingUpdateBlock?
    
    static let main : BKChatManager = {
        let instance = BKChatManager()
        return instance
    }()
    
    override public init() {
        super.init()
    }
    
    deinit {
        
        print("BKChatManager deallocated")
    }
    
    // MARK: Public Methods
    public func initClientWithPath(_ path : String) {
        
        guard let newURL = URL(string: path) else {
            
            print("Invalid path")
            return
        }
        
        self.mainSocket = SocketIOClient(socketURL: newURL, config: [.handleQueue(self.socketQueue)])
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        
        establishConnection()
    }
    
    public func connectWithId(_ userId : String,
                              nickName : String,
                              room : String,
                              completion : @escaping ([Any]) -> Swift.Void) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.emit("connectUser", userId, nickName, room)
        
        socket.on("userList") {
            (dataArray, ack) -> Swift.Void in
            
            completion(dataArray)
        }
    }
    
    public func disconnectWithId(_ userId : String,
                                 room : String,
                                 completion : () -> Swift.Void) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        
        socket.emit("exitUser", userId, room)
        completion()
    }
    
    public func sendMessage(_ message : String, toUserId userId : String, InRoom room : String) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.emit("chatMessage", userId, message, room)
    }
    
    public func retrieveChatMessage(_ completion : @escaping ([Any]) -> Swift.Void) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.on("newChatMessage") {
            (dataArray, socketAck) -> Void in
            
            completion(dataArray)
        }
    }
    
    public func sendUserActivity(_ activityType : BKActivityType, forUserId userId : String, InRoom room : String) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.emit(activityType.rawValue, userId, room)
    }
    
    public func createConnectionListener(_ handler : @escaping (BKUserConnectionType, [String : Any]) -> Swift.Void) {
        
        addConnectionListener(handler)
    }
    
    public func createTypingListener(_ handler : @escaping ([String]) -> Swift.Void) {
        
        addTypingListener(handler)
    }
    
    // MARK: Private Methods
    
    // MARK: Connection Methods
    fileprivate func establishConnection() {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.connect()
    }
    
    fileprivate func closeConnection() {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.disconnect()
    }
    
    // MARK: Listener Add Methods
    fileprivate func addConnectionListener(_ handler : @escaping (BKUserConnectionType, [String : Any]) -> Swift.Void) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        // remove any old listener
        removeConnectionListener()
        
        socket.on("userConnectUpdate") {
            (dataArray, socketAck) -> Void in
            
            if dataArray.count > 0 {
                
                if let dataDict = dataArray[0] as? [String : Any] {
                    
                    handler(.chatRoomUserConnected, dataDict)
                }
            }
        }
        
        socket.on("userExitUpdate") {
            (dataArray, socketAck) -> Void in
            
            if dataArray.count > 0 {
                
                if let dataDict = dataArray[0] as? [String : Any] {
                    
                    handler(.chatRoomUserDisconnected, dataDict)
                }
            }
        }
    }
    
    fileprivate func addTypingListener(_ handler : @escaping ([String]) -> Swift.Void) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        // remove any old listener
        removeTypingListener()
        
        socket.on("userTypingUpdate") {
            (dataArray, socketAck) -> Void in
            
            if dataArray.count > 0 {
                
                if let rowArray = dataArray[0] as? [[String : Any]] {
                    
                    var namesList : [String] = []
                    
                    for newDataDict in rowArray {
                        
                        if let nickName = newDataDict["nickName"] as? String {
                            namesList.append(nickName)
                        }
                    }
                    
                    handler(namesList)
                }
            }
        }
    }
    
    // MARK: Listener Removal Methods
    fileprivate func removeConnectionListener() {
        
        removeListener("userConnectUpdate")
        removeListener("userExitUpdate")
    }
    
    fileprivate func removeTypingListener() {
        
        removeListener("userTypingUpdate")
    }
    
    fileprivate func removeListener(_ forId : String) {
        
        guard let socket = self.mainSocket else {
            
            print("Connection not initialized.")
            return
        }
        
        socket.off(forId)
    }
    
    // MARK: Notification Methods
    @objc fileprivate func applicationDidBecomeActive(_ sender : Any) {
        
        establishConnection()
    }
    
    @objc fileprivate func applicationDidEnterBackground(_ sender : Any) {
        
        closeConnection()
    }
}
