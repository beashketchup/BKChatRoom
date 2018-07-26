//
//  MessageViewController.swift
//  BKChatRoom
//
//  Created by Ashish Parmar on 9/3/17.
//  Copyright © 2017 Ashish. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    fileprivate var messsageTableView = UITableView()
    fileprivate var messageView = UIView()
    fileprivate var messageBox = UITextField()
    
    fileprivate var messageList : [[String : Any]] = [[:]]
    fileprivate var userId = ""
    fileprivate var currentRoom = ""
    fileprivate var keyboardFrame = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        createComponents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardShown(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardDismissed(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Public Methods
    public func initMessageRoom(_ roomName : String, forUserId userId : String) {
        
        self.currentRoom = roomName
        self.userId = userId
    }
    
    // MARK: Private methods
    fileprivate func createComponents() {
        
        let screenSize = UIScreen.main.bounds.size
        
        let exitButton = UIButton(type: .custom)
        exitButton.frame = CGRect(x: screenSize.width - 50 - 80, y: 100, width: 80, height: 38)
        exitButton.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 51/255, alpha: 1.0)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.addTarget(self, action: #selector(exitButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(exitButton)
        
        self.messsageTableView = UITableView(frame: CGRect(x: 0, y: 150, width: screenSize.width, height: screenSize.height - 150 - 50), style: .plain)
        self.messsageTableView.delegate = self
        self.messsageTableView.dataSource = self
        self.view.addSubview(self.messsageTableView)
        
        self.messsageTableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        
        self.messageView = UIView(frame: CGRect(x: 0, y: screenSize.height - 50, width: screenSize.width, height: 50))
        self.messageView.backgroundColor = UIColor.darkGray
        self.view.addSubview(self.messageView)
        
        self.messageBox = UITextField(frame: CGRect(x: 5, y: 5, width: screenSize.width - 50 - 15, height: 40))
        self.messageBox.backgroundColor = UIColor.white
        self.messageBox.delegate = self
        self.messageView.addSubview(self.messageBox)
        
        let rect = self.messageBox.frame
        
        let sendButton = UIButton(type: .custom)
        sendButton.frame = CGRect(x: rect.origin.x + rect.size.width + 5, y: 5, width: 50, height: 40)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
        self.messageView.addSubview(sendButton)
        
        createIncomingMessageHandler()
        
        createTypingMessageHandler()
    }
    
    fileprivate func exitChat(_ fromRoom : String) {
        
        BKChatWrapper.main.logout(fromRoom) {
            
            print("User : \(self.userId) logout.")
            
            DispatchQueue.main.async { [weak self] in
                
                if let defaultNav = self?.navigationController {
                    defaultNav.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    fileprivate func createIncomingMessageHandler() {
        
        BKChatWrapper.main.getMessage { (data : [String : Any]) in
            
            DispatchQueue.main.async { [weak self] in
                
                if data.count > 0 {
                    self?.messageList.append(data)
                    self?.messsageTableView.reloadData()
                }
                else {
                    print("Message length is 0")
                }
            }
        }
    }
    
    fileprivate func createTypingMessageHandler() {
        
        BKChatWrapper.main.setUserTypingListener { (userList : [String]) in
            
            print("Users typing ********* : \(userList)")
        }
    }
    
    fileprivate func updateMessageViewLayout(_ frame : CGRect) {
        
        let screenSize = UIScreen.main.bounds.size
        var currentFrame = self.messageView.frame
        currentFrame.origin.y = screenSize.height - currentFrame.size.height - frame.size.height
        
        self.messageView.frame = currentFrame
    }
    
    // MARK: Action methods
    @objc fileprivate func sendButtonAction(_ sender : UIButton) {
        
        if let str = self.messageBox.text {
            
            if str.characters.count > 0 {
                
                BKChatWrapper.main.sendMessage(str, InRoom: self.currentRoom)
                self.messageBox.text = ""
            }
        }
    }
    
    @objc fileprivate func exitButtonAction(_ sender : UIButton) {
        
        exitChat(self.currentRoom)
        self.userId = ""
    }
    
    // MARK: Notification methods
    @objc private func didKeyboardShown(_ notification : NSNotification) {
        
        if let info  = notification.userInfo,
            let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            let rawFrame = value.cgRectValue
            self.keyboardFrame = self.view.convert(rawFrame, from: nil)
            
            updateMessageViewLayout(self.keyboardFrame)
        }
    }
    
    @objc private func didKeyboardDismissed(_ notification : NSNotification) {
        
        self.keyboardFrame = CGRect.zero
        updateMessageViewLayout(self.keyboardFrame)
    }
}

extension MessageViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65.0
    }
}

extension MessageViewController : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messageList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")
        
        if let _ = cell {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "messageCell")
        }
        
        let dictObject = self.messageList[indexPath.row]
        
        if let userId = dictObject["id"] as? String,
            let nickname = dictObject["nickname"] as? String,
            let msgDate = dictObject["date"] as? String {
            
            let updateStr = "~ \(userId) @ (\(nickname)) on \(msgDate)"
            cell!.detailTextLabel?.text = updateStr
            
            if userId == self.userId {
                
                cell!.textLabel?.textAlignment = .right
                cell!.detailTextLabel?.textAlignment = .right
            }
        }
        
        if let msg = dictObject["message"] as? String {
            
            cell!.textLabel?.text = msg
        }
        
        return cell!
    }
}

extension MessageViewController : UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        BKChatWrapper.main.userStartTyping(self.currentRoom)
    }
}
