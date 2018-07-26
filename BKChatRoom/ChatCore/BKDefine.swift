//
//  BKDefine.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 10/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//


//public let SERVER_URL = "http://172.20.10.13:3000"
public let SERVER_URL = "http://139.59.127.213:3000"

public enum BKUserConnectionType : String {
    
    case chatRoomUserConnected = "chatRoomUserConnected",
    chatRoomUserDisconnected = "chatRoomUserDisconnected"
}

public enum BKActivityType : String {
    
    case typing = "startType",
    stopTyping = "stopType"
}

public enum BKConfigurationType : String {
    
    case userConnectionListener = "ConnectionListener",
    userTypingListener = "TypingListener"
}
