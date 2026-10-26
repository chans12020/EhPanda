//
//  AlertKit_Extension.swift
//  EhPanda
//

import SwiftUI
import AlertKit

extension View {
    func jumpPageAlert(
        index: Binding<String>, isPresented: Binding<Bool>, isFocused: Binding<Bool>,
        pageNumber: PageNumber, jumpAction: @escaping () -> Void
    ) -> some View {
        JumpPageAlert(
            content: self, index: index, isPresented: isPresented,
            isFocused: isFocused, pageNumber: pageNumber, jumpAction: jumpAction
        )
    }
}

private struct JumpPageAlert<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var layout = LayoutMetrics()

    private let content: Content
    @Binding private var index: String
    @Binding private var isPresented: Bool
    @Binding private var isFocused: Bool
    private let pageNumber: PageNumber
    private let jumpAction: () -> Void

    @FocusState private var focused
    @StateObject private var manager = CustomAlertManager()

    init(
        content: Content,
        index: Binding<String>,
        isPresented: Binding<Bool>,
        isFocused: Binding<Bool>,
        pageNumber: PageNumber,
        jumpAction: @escaping () -> Void
    ) {
        self.content = content
        _index = index
        _isPresented = isPresented
        _isFocused = isFocused
        self.pageNumber = pageNumber
        self.jumpAction = jumpAction
    }

    private var widthFactor: Double {
        Double(min(1, 420 / layout.width))
    }
    private var backgroundOpacity: Double {
        colorScheme == .light ? 0.2 : 0.5
    }

    var body: some View {
        content.customAlert(
            manager: manager,
            widthFactor: widthFactor,
            backgroundOpacity: backgroundOpacity,
            content: {
                PageJumpView(
                    inputText: $index,
                    isFocused: $focused,
                    pageNumber: pageNumber
                )
            },
            buttons: [
                .regular(
                    content: { Text(L10n.Localizable.JumpPageView.Button.confirm) },
                    action: jumpAction
                )
            ]
        )
        .synchronize($isFocused, $focused)
        .synchronize($isPresented, $manager.isPresented)
        .trackLayout($layout)
    }
}
