//
//  ViewController.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 7/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        createComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private methods
    fileprivate func createComponents() {
        
        let room1button = UIButton(type: .custom)
        room1button.frame = CGRect(x: 160, y: 100, width: 100, height: 38)
        room1button.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        room1button.setTitle("Room 1", for: .normal)
        room1button.addTarget(self, action: #selector(room1ButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(room1button)
        
        let room2button = UIButton(type: .custom)
        room2button.frame = CGRect(x: 160, y: 160, width: 100, height: 38)
        room2button.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        room2button.setTitle("Room 2", for: .normal)
        room2button.addTarget(self, action: #selector(room2ButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(room2button)
        
        BKChatWrapper.main.startChatServer()
    }
    
    // MARK: Action methods
    @objc fileprivate func room1ButtonAction(_ sender : UIButton) {
        
        let roomList = RoomUserList()
        roomList.initRoomListFor("Room1")
        self.navigationController?.pushViewController(roomList, animated: true)
    }
    
    @objc fileprivate func room2ButtonAction(_ sender : UIButton) {
        
        let roomList = RoomUserList()
        roomList.initRoomListFor("Room2")
        self.navigationController?.pushViewController(roomList, animated: true)
    }
    
    fileprivate func startRoom(_ name : String) {
        
        
    }
}

