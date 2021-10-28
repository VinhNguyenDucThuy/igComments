//
//  API.swift
//  IG Manager
//
//  Created by apple on 7/14/21.
//

import SwiftUI
import FBSDKLoginKit

struct Comment: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var timestamp: String
    var username: String
}

struct UserInfo {
    var id: String
    var name: String
    var first_name: String
}

class API {
    func getAllComments(igMediaId: String, limit: String = "", completion: @escaping ([Comment]) -> ()) {
        
    }
    
    func getCommentIGMediaWithPath(path: String, after: String, completion: @escaping ([Comment]) -> ()) {
//        let path = "18241462546042051" + "/comments"
//        let path = "17894326796271505" + "/comments"
//        let path = "17939576665602135" + "/comments"
        let path = "17913731327026340" + "/comments"
        
        let parameters = ["fields": "username,text,timestamp,id", "limit": "50", "after": after]
        GraphRequest(graphPath: path, parameters: parameters).start { (connection, result, error) in
            var comments : [Comment] = []
            if (error == nil) {
                let fbDetails = result as! NSDictionary
                if let data: [NSDictionary] = fbDetails["data"] as? [NSDictionary] {
                    for commentData in data {
                        var comment : Comment = Comment(id: "", text: "", timestamp: "", username: "")
                        if let commentId: String = commentData["id"] as? String {
                            comment.id = commentId
                        }
                        if let text: String = commentData["text"] as? String {
                            comment.text = text
                        }
                        if let timestamp: String = commentData["timestamp"] as? String {
                            comment.timestamp = timestamp
                        }
                        if let username: String = commentData["username"] as? String {
                            comment.username = username
                        }
                        
                        
                        self.writeData(comment: comment)
                        comments.append(comment)
                    }
                }
                
                if let paging: NSDictionary = fbDetails["paging"] as? NSDictionary{
                    if let cursors: NSDictionary = paging["cursors"] as? NSDictionary{
                        if let afterCursors: String = cursors["after"] as? String {
                            self.getCommentIGMediaWithPath(path: path, after: afterCursors) { commentsAfter in
                                for commentAfter in commentsAfter {
                                    comments.append(commentAfter)
                                    DispatchQueue.main.async {
                                        completion(comments)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(comments)
                    }
                }
//                DispatchQueue.main.async {
//                    completion(comments)
//                }
                
            } else {
                print(error.debugDescription)
            }
        }
    }
    
    
    
    func getInfo(completion: @escaping (UserInfo) -> ()) {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name"]).start { (connection, result, error) in
            if (error == nil) {
                let fbDetails = result as! NSDictionary
                var userInfo : UserInfo = UserInfo(id: "", name: "", first_name: "")
                userInfo.id = fbDetails["id"] as? String ?? ""
                userInfo.name = fbDetails["name"] as? String ?? ""
                userInfo.first_name = fbDetails["first_name"] as? String ?? ""

                completion(userInfo)
            }
        }
    }
    
    
    func writeData(comment: Comment) {
        let filePath = "/tmp/vinhndt.txt";
        let fileUrl = URL(fileURLWithPath: filePath)
        
        var str = ""
        
//        str = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        
        do {
            try str = String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        } catch {
            // handle exception
        }
        
        
//        do {
//            str = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
//        } catch {
//            print("User creation failed with error: \(error)")
//        }
        
        

        let strToWrite = "_\(comment.id),\(comment.text),\(comment.timestamp),\(comment.username)\n"
        
        if (str.count < 1000000) {
            str += strToWrite
        } else {
            str = strToWrite;
        }
        
        do {
            try str.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
