//
//  LockedView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import SwiftUI

struct LockedView: View {
    @ObservedObject var model: LockedViewModel
    @State var passwordInput = ""
    @State var passwordConfirm = ""
    @State var incorrectAlert = false

    var body: some View {
        Group {
            if model.reason == .waiting {
                appLocked
            } else if model.reason == .success {
                Text("Success!")
            } else if model.reason == .unavailable || model.reason == .cancelled {
                waitingPassword
            } else if model.reason == .unset {
                waitingSetPassword
            } else if model.reason == .error {
                Text("Unknown error")
            }
        }
    }

    var appLocked: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.doc.fill")
                .font(.system(size: 50))

            Text("App Locked")
                .font(.system(.title, design: .rounded))

            Text("You need to unlock the app to decrypt your data")
                .multilineTextAlignment(.center)
                .font(.headline)
        }
    }

    var waitingPassword: some View {
        VStack(spacing: 5) {
            Image(systemName: "lock.fill")
                .font(.system(size: 50))

            Text("App Locked")
                .font(.system(.title, design: .rounded))

            Text("You need to enter the password to decrypt your data")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .font(.headline)

            if model.reason == .cancelled {
                Button(action: {
                    model.requested = false
                    model.unlock()
                }) {
                    Text("Try again")
                        .font(.headline)
                        .frame(width: 300, height: 50)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical, 3)
            }

            SecureField("Password", text: $passwordInput) {}
                .frame(width: 300)
                .padding()

            Button(action: {
                if passwordInput != "" {
                    if PersistenceController.shared.checkPassword(password: passwordInput) {
                        if ValetController.setPassword(new_password: passwordInput, save: model.reason == .unavailable) {
                            passwordInput = ""
                            model.appLocked = false
                            model.reason = .success
                            return
                        }
                    }
                }

                incorrectAlert = true
            }) {
                Text("Decrypt")
                    .font(.headline)
                    .frame(width: 300, height: 50)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .alert(isPresented: $incorrectAlert) {
            Alert(
                title: Text("Incorrect password"),
                message: Text("Check your password and try again!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    var waitingSetPassword: some View {
        VStack(spacing: 10) {
            Image(systemName: "key.fill")
                .font(.system(size: 50))

            Text("Welcome")
                .font(.system(.title, design: .rounded))

            Text("Set a password to encrypt your data")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .font(.headline)

            SecureField("Password", text: $passwordInput)
                .frame(width: 300)
                .padding()
            SecureField("Confirm Password", text: $passwordConfirm)
                .frame(width: 300)
                .padding()

            Button(action: {
                guard passwordInput != "" else {
                    incorrectAlert = true
                    return
                }

                if passwordInput == passwordConfirm {
                    if ValetController.setPassword(new_password: passwordInput, save: true) {
                        PersistenceController.shared.savePassword(password: passwordInput)
                        passwordInput = ""
                        passwordConfirm = ""

                        model.appLocked = false
                        model.reason = .success
                    }
                    return
                }

                incorrectAlert = true
            }) {
                Text("Start")
                    .font(.headline)
                    .frame(width: 300, height: 50)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .alert(isPresented: $incorrectAlert) {
            Alert(
                title: Text("Bad passwords"),
                message: Text("Check your passwords and try again!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
