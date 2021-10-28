//
//  ContentView.swift
//  IG Manager
//
//  Created by apple on 7/13/21.
//

import SwiftUI
import FBSDKLoginKit

let token = AccessToken.current

struct ContentView: View {
    @State var isLogin = !(AccessToken.current?.isExpired ?? true) as Bool
    @State var userInfo : UserInfo = UserInfo(id: "", name: "", first_name: "")
    @State var comments : [Comment] = []

    @ObservedObject var fbmanager = UserLoginManager()
    
    var body: some View {
//        fetchUserInfo()
        if (isLogin) {
            ScrollView(showsIndicators: false){
                VStack(){
                    Button(action: {
                        self.fbmanager.facebookLogout()
                        isLogin = self.fbmanager.isLogin
                        print("logout")
                    }) {
                        Text("Facebook logout")
                    }
                    Text("First Name: " + userInfo.first_name)
                    Text("Id: " + userInfo.id)
                    Text("Full Name: " + userInfo.name)
                    
                    Button(action: {
                        API().getCommentIGMediaWithPath(path: "", after: "") { commentsIgMedia in
                            comments = commentsIgMedia
                        }
                    }) {
                        Text("getCommentIGMediaWithPath")
                    }
                    
//                    VStack(){
//                        ForEach(comments, id: \.self) { comment in
//                            Text("id: " + comment.id)
//                            Text("text: " + comment.text)
//                            Text("timestamp: " + comment.timestamp)
//                            Text("username: " + comment.username)
//                            Capsule().frame(width: 10, height: 10, alignment: .center)
//                        }
//                    }
                }.onAppear {
                    API().getInfo { (info) in
                        userInfo = info
                    }
//                    API().getCommentIGMediaWithPath(path: "", after: "") { commentsIgMedia in
//                        comments = commentsIgMedia
//                    }
                }
            }
        } else {
            Button(action: {
                self.fbmanager.facebookLogin()
                isLogin = self.fbmanager.isLogin
            }) {
                Text("Continue with Facebook")
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class UserLoginManager: ObservableObject {
    @Published var isLogin = false
    
    let loginManager = LoginManager()
    func facebookLogin() {
        let permissions = ["email", "public_profile", "instagram_basic", "instagram_content_publish", "instagram_manage_comments", "pages_read_engagement", "pages_show_list", "ads_management", "business_management"]
        loginManager.logIn(permissions: permissions, from: nil) { (result, error) in
            if error != nil {
                print("login failure")
                self.isLogin = false
                // deal with failure
            }
            else if result?.isCancelled != true {
//                let token = result!.token
                // store token
                self.isLogin = true
            } else {
                print("Facebook login cancelled")
                self.isLogin = false
                // handle cancel
            }
        }
    }
    
    func facebookLogout() {
        loginManager.logOut()
        self.isLogin = false
    }
}
