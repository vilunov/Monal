//
//  RegisterAccount.swift
//  Monal
//
//  Created by CC on 22.04.22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import SwiftUI
import SafariServices
import WebKit
import monalxmpp

struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct RegisterAccount: View {
    static let XMPPServer: [Dictionary<String, String>] = [
        ["XMPPServer": "Input", "TermsSite_default": ""],
        ["XMPPServer": "yax.im", "TermsSite_default": "https://yaxim.org/yax.im/"],
        ["XMPPServer": "jabber.de", "TermsSite_default": "https://www.jabber.de/impressum/datenschutz/"],
        ["XMPPServer": "xabber.de", "TermsSite_default": "https://www.draugr.de"],
        ["XMPPServer": "trashserver.net", "TermsSite_default": "https://trashserver.net/en/privacy/", "TermsSite_de": "https://trashserver.net/datenschutz/"]
    ]

    private let xmppServerInputSelectLabel = Text("Manual input")
    
    static private let xmppFaultyPattern = ".+\\..{2,}$"
    static private let credFaultyPattern = ".*@.*"

    @State private var username: String = ""
    @State private var password: String = ""

    @State private var providedServer: String = ""
    @State private var selectedServerIndex = 1

    @State private var showAlert = false

    @State private var alertPrompt = AlertPrompt(dismissLabel: Text("Close"))

    @State private var showWebView = false

    private var serverSelectedAlert: Bool {
        alertPrompt.title = Text("No XMPP server!")
        alertPrompt.message = Text("Please select a XMPP server or provide one.")

        return serverSelected
    }

    private var serverProvidedAlert: Bool {
        alertPrompt.title = Text("No XMPP server!")
        alertPrompt.message = Text("Please select a XMPP server or provide one.")

        return serverProvided
    }

    private var xmppServerFaultyAlert: Bool {
        alertPrompt.title = Text("XMPP server domain not valid!")
        alertPrompt.message = Text("Please provide a valid XMPP server domain or select one.")

        return xmppServerFaulty
    }

    private var credentialsEnteredAlert: Bool {
        alertPrompt.title = Text("No Empty Values!")
        alertPrompt.message = Text("Please make sure you have entered a username, password.")
        
        return credentialsEntered
    }

    private var credentialsFaultyAlert: Bool {
        alertPrompt.title = Text("Invalid Username!")
        alertPrompt.message = Text("The username does not need to have an @ symbol. Please try again.")

        return credentialsFaulty
    }

    private var credentialsExistAlert: Bool {
        alertPrompt.title = Text("Duplicate Account!")
        alertPrompt.message = Text("This account already exists on this instance.")
        
        return credentialsExist
    }

    private var actualServer: String {
        let tmp = RegisterAccount.XMPPServer[$selectedServerIndex.wrappedValue]["XMPPServer"]
        return (tmp != nil && tmp != "Input") ? tmp! : serverProvided && !xmppServerFaulty ? providedServer : "?"
    }

    private var actualServerText: Text {
        return Text(" with \(actualServer)")
    }

   private var serverSelected: Bool {
        return selectedServerIndex != 0
    }

    private var serverProvided: Bool {
        return providedServer != ""
    }

    private var xmppServerFaulty: Bool {
        return providedServer.range(of: RegisterAccount.xmppFaultyPattern, options:.regularExpression) == nil
    }

    private var credentialsEntered: Bool {
        return !username.isEmpty && !password.isEmpty
    }

    private var credentialsFaulty: Bool {
        return username.range(of: RegisterAccount.credFaultyPattern, options: .regularExpression) != nil
    }

    private var credentialsExist: Bool {
        return DataLayer.sharedInstance().doesAccountExistUser(username, andDomain:actualServer)
    }

    private var buttonColor: Color {
        return (!serverSelected && (!serverProvided || xmppServerFaulty)) || (!credentialsEntered || credentialsFaulty || credentialsExist) ? Color(UIColor.systemGray) : Color(UIColor.systemBlue)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Like email, you can register your account on many sites and talk to anyone. You can use this page to register an account with a selected or provided XMPP server. You also have to choose a username and a password.")
                            .padding()
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    Form {
                        Menu {
                            Picker("", selection: $selectedServerIndex) {
                                ForEach (RegisterAccount.XMPPServer.indices, id: \.self) {
                                    if ($0 == 0) {
                                        xmppServerInputSelectLabel.tag(0)
                                    }
                                    else {
                                        Text(RegisterAccount.XMPPServer[$0]["XMPPServer"] ?? "").tag($0)
                                    }
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.inline)
                        }
                        label: {
                            HStack {
                            if (selectedServerIndex != 0) {
                                Text(RegisterAccount.XMPPServer[selectedServerIndex]["XMPPServer"]!).font(.system(size: 17)).frame(maxWidth: .infinity)
                                Image(systemName: "checkmark")
                            }
                            else {
                                xmppServerInputSelectLabel.font(.system(size: 17)).frame(maxWidth: .infinity)
                            }
                            }
                            .padding(9.0)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        }
                        

                        if (selectedServerIndex == 0) {
                            TextField("Provide XMPP-Server", text: Binding(get: { self.providedServer }, set: { string in self.providedServer = string.lowercased() }))
                                .disableAutocorrection(true)
                        }

                        TextField("Username", text: Binding(get: { self.username }, set: { string in self.username = string.lowercased() }))
                            .disableAutocorrection(true)
                        SecureField("Password", text: $password)
                        
                        Button(action: {
                            showAlert = (!serverSelectedAlert && (!serverProvidedAlert || xmppServerFaultyAlert)) || (!credentialsEnteredAlert || credentialsFaultyAlert || credentialsExistAlert)
                            
                            if (!showAlert) {
                                // TODO: Code/Action for registration and jump to whatever view after successful registration
                            }
                        }){
                            Text("Register\(actualServerText)")
                                .frame(maxWidth: .infinity)
                                .padding(9.0)
                                .background(Color(UIColor.tertiarySystemFill))
                                .foregroundColor(buttonColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert(isPresented: $showAlert) {
                            Alert(title: alertPrompt.title, message: alertPrompt.message, dismissButton: .default(alertPrompt.dismissLabel))
                        }
                        Text("The selectable XMPP servers are public servers which are not affiliated to Monal. This registration page is provided for convenience only.")
                        .font(.system(size: 10))
                        .padding(.vertical, 8)
                        
                        if (selectedServerIndex != 0) {
                            Button (action: {
                                showWebView.toggle()
                            }){
                                Text("Terms of use for \(RegisterAccount.XMPPServer[$selectedServerIndex.wrappedValue]["XMPPServer"]!)")
                                    .font(.system(size: 10))
                            }
                            .frame(maxWidth: .infinity)
                            .sheet(isPresented: $showWebView) {
                                Text("Terms of\n\(RegisterAccount.XMPPServer[$selectedServerIndex.wrappedValue]["XMPPServer"]!)")
                                    .font(.largeTitle.weight(.bold))
                                    .multilineTextAlignment(.center)
                                WebView(url: URL(string: (RegisterAccount.XMPPServer[$selectedServerIndex.wrappedValue]["TermsSite_\(Locale.current.languageCode ?? "default")"] ?? RegisterAccount.XMPPServer[$selectedServerIndex.wrappedValue]["TermsSite_default"])!)!)
                                Button (action: {
                                    showWebView.toggle()
                                }){
                                    Text("Close")
                                        .padding(9.0)
                                        .background(Color(UIColor.tertiarySystemFill))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.top, 10.0)
                                .padding(.bottom, 9.0)
                            }
                        }
                    }
                    .frame(height: 370)
                    .textFieldStyle(.roundedBorder)
                }
            }
        }

        .navigationTitle("Register")
    }
}

struct RegisterAccount_Previews: PreviewProvider {
    static var previews: some View {
        RegisterAccount()
    }
}



 