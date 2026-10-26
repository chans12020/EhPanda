//
//  ToolbarItems.swift
//  EhPanda
//

import SwiftUI

struct CustomToolbarItem<Content: View>: ToolbarContent {
    private let placement: ToolbarItemPlacement
    private let tint: Color?
    private let disabled: Bool
    private let content: Content

    init(placement: ToolbarItemPlacement = .primaryAction,
         tint: Color? = nil, disabled: Bool = false,
         @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.tint = tint
        self.disabled = disabled
        self.content = content()
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: placement) {
            content
                .foregroundColor(tint)
                .disabled(disabled)
        }
    }
}

struct ToolbarFeaturesMenu<Content: View>: View {
    private let content: Content
    private let symbolRenderingMode: SymbolRenderingMode

    init(symbolRenderingMode: SymbolRenderingMode = .monochrome, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.symbolRenderingMode = symbolRenderingMode
    }

    var body: some View {
        Menu {
            content
        } label: {
            Label("toolbar_item.button.more", systemSymbol: .ellipsisCircle)
                .symbolRenderingMode(symbolRenderingMode)
        }
    }
}

struct FiltersButton: View {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(L10n.Localizable.ToolbarItem.Button.filters, systemSymbol: .line3HorizontalDecrease)
        }
    }
}

struct QuickSearchButton: View {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(L10n.Localizable.ToolbarItem.Button.quickSearch, systemSymbol: .magnifyingglass)
        }
    }
}

struct JumpPageButton: View {
    private let pageNumber: PageNumber
    private let action: () -> Void

    init(pageNumber: PageNumber, action: @escaping () -> Void) {
        self.pageNumber = pageNumber
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(L10n.Localizable.ToolbarItem.Button.jumpPage, systemSymbol: .arrowshapeBounceForward)
        }
        .disabled(pageNumber.isSinglePage)
    }
}

struct FavoritesIndexMenu: View {
    private let user: User
    private let index: Int
    private let action: (Int) -> Void

    init(user: User, index: Int, action: @escaping (Int) -> Void) {
        self.user = user
        self.index = index
        self.action = action
    }

    var body: some View {
        Menu {
            ForEach(-1..<10) { index in
                Button {
                    action(index)
                } label: {
                    Text(user.getFavoriteCategory(index: index))
                    if index == self.index {
                        Image(systemSymbol: .checkmark)
                    }
                }
            }
        } label: {
            Image(systemSymbol: .dialLow)
                .symbolRenderingMode(.hierarchical)
        }
    }
}

struct ToplistsTypeMenu: View {
    private let type: ToplistsType
    private let action: (ToplistsType) -> Void

    init(type: ToplistsType, action: @escaping (ToplistsType) -> Void) {
        self.type = type
        self.action = action
    }

    var body: some View {
        Menu {
            ForEach(ToplistsType.allCases) { type in
                Button {
                    action(type)
                } label: {
                    Text(type.value)
                    if type == self.type {
                        Image(systemSymbol: .checkmark)
                    }
                }
            }
        } label: {
            Image(systemSymbol: .dialLow)
                .symbolRenderingMode(.hierarchical)
        }
    }
}

struct SortOrderMenu: View {
    private let sortOrder: FavoritesSortOrder?
    private let action: (FavoritesSortOrder) -> Void

    init(sortOrder: FavoritesSortOrder?, action: @escaping (FavoritesSortOrder) -> Void) {
        self.sortOrder = sortOrder
        self.action = action
    }

    var body: some View {
        Menu {
            ForEach(FavoritesSortOrder.allCases) { order in
                Button {
                    action(order)
                } label: {
                    Text(order.value)
                    if order == sortOrder {
                        Image(systemSymbol: .checkmark)
                    }
                }
            }
        } label: {
            Image(systemSymbol: .arrowUpArrowDownCircle)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
