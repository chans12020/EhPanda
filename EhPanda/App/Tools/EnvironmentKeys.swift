//
//  EnvironmentKeys.swift
//  EhPanda
//

import SwiftUI

struct InSheetKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var inSheet: Bool {
        get { self[InSheetKey.self] }
        set { self[InSheetKey.self] = newValue }
    }
}

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics()
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

extension View {
    /// Observe this view's container continuously, including sheet and fold resizing.
    func trackLayout(_ layout: Binding<LayoutMetrics>) -> some View {
        self
            .environment(\.layoutMetrics, layout.wrappedValue)
            .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
                layout.wrappedValue = LayoutMetrics(size: size)
            }
    }
}
