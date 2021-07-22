//
//  EncryptionHelper.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import CryptoKit
import Foundation
import RNCryptor

class EncryptionHelper {
    static func encryptString(input: String?, withPassword password: String?) -> String? {
        guard let input = input, let password = password else { return nil }
        if let data = input.data(using: .utf8) {
            let encrypted = RNCryptor.encrypt(data: data, withPassword: password)
            return encrypted.base64EncodedString()
        }

        return nil
    }

    static func decryptString(encrypted: String?, withPassword password: String?) -> String? {
        guard let encrypted = encrypted, let password = password else { return nil }
        if let data = Data(base64Encoded: encrypted) {
            do {
                let stringData = try RNCryptor.decrypt(data: data, withPassword: password)
                return String(data: stringData, encoding: .utf8)
            } catch {}
        }

        return nil
    }

    static func encryptData<T: Codable>(_ object: T, key: String) -> String? {
        if let data = encodeData(object) {
            if let encryptedData = try? ChaChaPoly.seal(data, using: getSymmetricKey(password: key)) {
                return encryptedData.combined.base64EncodedString()
            }
        }
        return nil
    }

    static func decryptData<T: Codable>(data: String, key: String, as type: T.Type) -> T? {
        do {
            let box = try ChaChaPoly.SealedBox(combined: Data(base64Encoded: data) ?? Data())
            let decryptedData = try ChaChaPoly.open(box, using: getSymmetricKey(password: key))
            if let result = decodeData(data: decryptedData, as: type) {
                return result
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    static func getSymmetricKey(password: String) -> SymmetricKey {
        return SymmetricKey(data: SHA256.hash(data: password.data(using: .utf8)!))
    }

    static func decodeData<T: Decodable>(data: Data, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(type, from: data)
            return result
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    static func encodeData<T: Encodable>(_ object: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }
}
