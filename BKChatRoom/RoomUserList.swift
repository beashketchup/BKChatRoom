//
//  RoomUserList.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 7/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit

class RoomUserList: UIViewController {
    
    fileprivate var userTableView = UITableView()
    fileprivate var userList : [[String : Any]] = [[:]]
    fileprivate var messageList : [[String : Any]] = [[:]]
    fileprivate var userId = ""
    fileprivate var userNickName = ""
    fileprivate var currentRoom = ""
    
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
    
    // MARK: Public Methods
    public func initRoomListFor(_ roomName : String) {
        
        self.currentRoom = roomName
    }
    
    // MARK: Private methods
    fileprivate func createComponents() {
        
        let screenSize = UIScreen.main.bounds.size
        
        let joinButton = UIButton(type: .custom)
        joinButton.frame = CGRect(x: 50, y: 100, width: 80, height: 38)
        joinButton.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        joinButton.setTitle("Join", for: .normal)
        joinButton.addTarget(self, action: #selector(joinButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(joinButton)
        
        let exitButton = UIButton(type: .custom)
        exitButton.frame = CGRect(x: screenSize.width - 50 - 80, y: 100, width: 80, height: 38)
        exitButton.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.addTarget(self, action: #selector(exitButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(exitButton)
        
        self.userTableView = UITableView(frame: CGRect(x: 0, y: 150, width: screenSize.width, height: screenSize.height - 150), style: .plain)
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
        self.view.addSubview(self.userTableView)
        
        self.userTableView.register(UITableViewCell.self, forCellReuseIdentifier: "requiredCell")
    }
    
    fileprivate func createNewUser() {
        
        let alertController = UIAlertController(title: "Chat Room", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { [unowned self]
            (action) -> Void in
            
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                
                self.createNewUser()
                print("Recreating user dialog")
            }
            else {
                self.userNickName = textfield.text!
                let comp = self.userNickName.components(separatedBy: ":")
                
                self.userId = comp[0]
                self.userNickName = comp[1]
                
                BKChatWrapper.main.loginWithId(self.userId, nickName: self.userNickName, room: self.currentRoom, completion: {
                    (data : [[String : Any]]?) in
                    
                    guard let userData = data else {
                        print("User list not found.")
                        return
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        self?.userList.removeAll()
                        self?.userList.append(contentsOf: userData)
                        self?.userTableView.reloadData()
                    }
                })
            }
        }
        
        alertController.addAction(OKAction)
        self.navigationController?.present(alertController, animated: true, completion: { 
            
            print("Dialog Presented")
        })
    }
    
    fileprivate func exitChat(_ fromRoom : String) {
        
        BKChatWrapper.main.logout(fromRoom) {
            
            print("User : \(self.userNickName) logout.")
            
            DispatchQueue.main.async { [weak self] in
                
                self?.userId = ""
                self?.userNickName = ""
                self?.userList.removeAll()
                self?.userTableView.reloadData()
            }
        }
    }
    
    fileprivate func createIncomingMessageHandler() {
        
        BKChatWrapper.main.getMessage { (data : [String : Any]) in
            
            if data.count > 0 {
                self.messageList.append(data)
            }
            else {
                print("Message length is 0")
            }
        }                
    }
    
    // MARK: Action methods
    @objc fileprivate func joinButtonAction(_ sender : UIButton) {
        
        createNewUser()
    }
    
    @objc fileprivate func exitButtonAction(_ sender : UIButton) {
        
        exitChat(self.currentRoom)
    }
}

extension RoomUserList : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let messageController = MessageViewController()
        messageController.initMessageRoom(self.currentRoom, forUserId: self.userId)
        self.navigationController?.pushViewController(messageController, animated: true)
    }
}

extension RoomUserList : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.userList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "requiredCell")
        
        if let _ = cell {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "requiredCell")
        }
        
        let dictObject = self.userList[indexPath.row]
        
        if let nickName = dictObject["nickName"] as? String {
            cell!.textLabel?.text = nickName
        }
        
        if let status = dictObject["status"] as? Bool {
            cell!.detailTextLabel?.text = status ? "Online" : "Offline"
            cell!.detailTextLabel?.textColor = status ? UIColor.green : UIColor.red
        }
        
        return cell!
    }
}


