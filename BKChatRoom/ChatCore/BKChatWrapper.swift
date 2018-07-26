//
//  BKChatWrapper.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 7/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import Foundation
import UIKit
import SocketIO


public class BKChatWrapper: NSObject {
    
    fileprivate var userList : [[String : Any]] = [[:]]
    fileprivate var messageList : [[String : Any]] = [[:]]
    fileprivate var userId : String?
    fileprivate var userNickName : String?
    
    static let main : BKChatWrapper = {
        let instance = BKChatWrapper()
        return instance
    }()
    
    override public init() {
        super.init()
    }
    
    deinit {
        
        print("BKChatWrapper deallocated")
    }
    
    // MARK: Public Methods
    public func startChatServer() {
        
        BKChatManager.main.initClientWithPath(SERVER_URL)
    }
    
    public func loginWithId(_ userId : String,
                            nickName : String,
                            room : String,
                            completion : @escaping ([[String : Any]]?) -> Swift.Void) {
        
        BKChatManager.main.connectWithId(userId, nickName: nickName, room: room) { (data : [Any]) in
            
            self.userId = userId
            self.userNickName = nickName
            if let userData = data[0] as? [[String : Any]] {
                
                self.userList = userData
                completion(self.userList)
            }
            else {
                print("Incompatible data")
                completion(nil)
            }
        }
    }
    
    public func logout(_ room : String,
                       completion : () -> Swift.Void) {
        
        if let newUserId = self.userId {
            BKChatManager.main.disconnectWithId(newUserId, room: room, completion: completion)
        }
    }
    
    public func sendMessage(_ message : String, InRoom room : String) {
        
        if let newUserId = self.userId {
            BKChatManager.main.sendMessage(message, toUserId: newUserId, InRoom: room)
        }
    }
    
    public func getMessage(_ completion : @escaping ([String : Any]) -> Swift.Void) {
        
        BKChatManager.main.retrieveChatMessage { (data : [Any]) in
            
            var msgDict : [String : Any] = [:]
            if data.count > 0 {
                if let newDataDict = data[0] as? [String : Any] {
                    
                    if let userId = newDataDict["id"] as? String {
                        msgDict["id"] = userId
                    }
                    
                    if let nickname = newDataDict["nickname"] as? String {
                        msgDict["nickname"] = nickname
                    }
                    
                    if let message = newDataDict["message"] as? String {
                        msgDict["message"] = message
                    }
                    
                    if let date = newDataDict["date"] as? String {
                        msgDict["date"] = date
                    }
                }
            }
            
            completion(msgDict)
        }
    }
    
    public func setUserConnectionListener(_ handler : @escaping (BKUserConnectionType, [String : Any]) -> Swift.Void) {
        
        BKChatManager.main.createConnectionListener(handler)
    }
    
    public func setUserTypingListener(_ handler : @escaping ([String]) -> Swift.Void) {
        
        BKChatManager.main.createTypingListener(handler)
    }
    
    public func userStartTyping(_ room : String) {
        
        if let newUserId = self.userId {
            BKChatManager.main.sendUserActivity(.typing, forUserId: newUserId, InRoom: room)
        }
    }
    
    public func userStopTyping(_ room : String) {
        
        if let newUserId = self.userId {
            BKChatManager.main.sendUserActivity(.stopTyping, forUserId: newUserId, InRoom: room)
        }
    }
}
