//
//  DialogTextField.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import Introspect
import SwiftUI

struct DialogTextField: View {
    @Environment(\.presentationMode) private var presentationMode
    let title: String
    let textFieldTitle: String
    
    @State private var textField = ""
    var onCommit: (String) -> Void = { _ in }
    
    var body: some View {
        #if os(iOS)
        VStack(alignment: .center, spacing: 10) {
            Text(title)
            
            TextField(textFieldTitle, text: $textField)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300, height: 50)
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
                }

            VStack {
                Button(action: {
                    finished()
                }) {
                    HStack {
                        Spacer()
                        Text("OK")
                            .padding(.vertical)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .font(.headline)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                .frame(width: 300, height: 50)
                
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                            .padding(.vertical)
                        Spacer()
                    }
                    .
                    contentShape(Rectangle())
                }
                .font(.headline)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                .frame(width: 300, height: 50)
            }
            .padding()
        }
        .padding()
        #elseif os(macOS)
        VStack(alignment: .center, spacing: 5) {
            Text(title)
            
            TextField(textFieldTitle, text: $textField) { _ in } onCommit: {
                finished()
            }
            
            HStack {
                Button(action: {
                    finished()
                }) {
                    Text("OK")
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
            }
            .padding()
        }
        .padding()
        #endif
    }
    
    func finished() {
        onCommit(textField)
        dismiss()
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
        #if os(macOS)
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // macOS need this to show dismiss animation
        #endif
    }
}
