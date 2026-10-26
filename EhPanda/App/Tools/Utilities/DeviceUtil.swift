//
//  DeviceUtil.swift
//  EhPanda
//

import SwiftUI
import Foundation

struct DeviceUtil {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene }).last?
            .windows.filter({ $0.isKeyWindow }).last
    }
    static var anyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).last?
            .windows.last
    }

}
