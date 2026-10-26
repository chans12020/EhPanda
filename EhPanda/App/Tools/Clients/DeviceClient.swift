//
//  DeviceClient.swift
//  EhPanda
//

import SwiftUI
import Dependencies

struct DeviceClient {
    let touchPoint: () -> CGPoint?
}

extension DeviceClient {
    static let live: Self = .init(
        touchPoint: {
            TouchHandler.shared.currentPoint
        }
    )
}

// MARK: API
enum DeviceClientKey: DependencyKey {
    static let liveValue = DeviceClient.live
    static let previewValue = DeviceClient.noop
    static let testValue = DeviceClient.unimplemented
}

extension DependencyValues {
    var deviceClient: DeviceClient {
        get { self[DeviceClientKey.self] }
        set { self[DeviceClientKey.self] = newValue }
    }
}

// MARK: Test
extension DeviceClient {
    static let noop: Self = .init(
        touchPoint: { .zero }
    )

    static func placeholder<Result>() -> Result { fatalError() }

    static let unimplemented: Self = .init(
        touchPoint: IssueReporting.unimplemented(placeholder: placeholder())
    )
}
