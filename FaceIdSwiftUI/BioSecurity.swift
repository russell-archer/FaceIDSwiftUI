//
//  BioSecurity.swift
//  FaceIdSwiftUI
//
//  Created by Russell Archer on 03/08/2022.
//

import LocalAuthentication

enum BioAuthenticationError: Error {
    case notSupported, failed
}

class BioSecurity {
    private var context = LAContext()
    
    func isSupported() -> Bool {
        switch typeSupported() {
            case .faceID: return true
            case .touchID: return true
            default: return false
        }
    }
    
    func typeSupported() -> LABiometryType {
        // LAContext().biometryType is always none until you call canEvaluatePolicy(_:error:)
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }
        
        return context.biometryType
    }
    
    func typeSupportedDescription() -> String {
        switch typeSupported() {
            case .faceID: return "FaceID"
            case .touchID: return "TouchID"
            default: return "None"
        }
    }
    
    func authenticate(result: @escaping (Result<String, BioAuthenticationError>) -> Void) {
        // Get a fresh context for each login. If you use the same context on multiple attempts
        // then a previously successful authentication causes the next policy evaluation to succeed
        // without testing biometry again
        context = LAContext()
        
        
        // Is Biometric security supported?
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            print("Biometric security is not supported")
            result(.failure(.notSupported))
            return
        }
               
        let bioType = typeSupportedDescription()
        
        // Use Biometry to authenticate the user
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication required") { success, error in
            // Note: Return all results on the main thread
            
            guard success else {
                Task { @MainActor in
                    print("Error authenticating: \(error?.localizedDescription ?? "unknown error")")
                    result(.failure(BioAuthenticationError.failed))
                }
                
                return
            }
            
            Task { @MainActor in
                result(.success(bioType))
            }
        }
    }
}

