//
//  LockedViewModel.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import Foundation

enum AppLockReason: Int {
    case waiting, unavailable, success, error, cancelled, unset
}

class LockedViewModel: ObservableObject {
    var requested = false
    @Published var appLocked = true
    @Published var reason: AppLockReason = .waiting

    func unlock() {
        guard !requested else { return }
        requested = true

        print("Unlocking...")
        DispatchQueue.global(qos: .userInteractive).async {
            let (password, error) = ValetController.getPassword()
            DispatchQueue.main.async {
                if password != nil, error == nil {
                    self.appLocked = false
                    self.reason = .success
                } else if error == .emptyKey || error == .emptyValue || error == .itemNotFound {
                    if PersistenceController.shared.isAvailable() {
                        // password is set
                        self.reason = .unavailable
                    } else {
                        self.reason = .unset
                    }
                } else if error == .userCancelled {
                    self.reason = .cancelled
                } else {
                    self.reason = .error
                }
            }
        }
    }
}
