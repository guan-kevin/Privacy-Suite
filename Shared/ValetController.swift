//
//  ValetController.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import Foundation
import Valet

class ValetController {
    private static var identifier: SharedGroupIdentifier?
    private static var enableBiometrics: Bool?
    private static var checkPasteboard: Bool?
    private static var password: String?

    internal static func getPassword() -> (String?, KeychainError?) {
        var keychainError: KeychainError?

        if password == nil {
            let secureValet = SecureEnclaveValet.valet(with: Identifier(nonEmpty: "SecureValet")!, accessControl: .biometricCurrentSet)
            do {
                let result = try secureValet.string(forKey: "password", withPrompt: "get your previous password from Secure Enclave")
                password = result
            } catch {
                if let error = error as? KeychainError {
                    keychainError = error
                }
            }
        }

        return (password, keychainError)
    }

    internal static func setPassword(new_password: String, save: Bool = true) -> Bool {
        guard save else {
            password = new_password
            return true
        }

        let secureValet = SecureEnclaveValet.valet(with: Identifier(nonEmpty: "SecureValet")!, accessControl: .biometricCurrentSet)
        do {
            try secureValet.setString(new_password, forKey: "password")
            password = new_password
            return true
        } catch {
            print(error)
            return false
        }
    }

    internal static func reset() {
        password = nil
    }

    internal static func getSharedGroupIdentifier() -> SharedGroupIdentifier {
        if identifier == nil {
            if let id = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
                identifier = SharedGroupIdentifier(appIDPrefix: String(id.dropLast()), nonEmptyGroup: "com.kevinguan.RecoverKeysManager")
            }
        }

        assert(identifier != nil)

        return identifier!
    }

    internal static func getValet() -> Valet {
        return Valet.iCloudSharedGroupValet(with: ValetController.getSharedGroupIdentifier(), accessibility: .whenUnlocked)
    }
}
