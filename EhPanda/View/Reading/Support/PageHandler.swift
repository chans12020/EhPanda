//
//  PageHandler.swift
//  EhPanda
//

import SwiftUI

final class PageHandler: ObservableObject {
    @Published var sliderValue: Float = 1 {
        didSet {
            Logger.info("sliderValue.didSet", context: ["sliderValue": sliderValue])
        }
    }

    func mapFromPager(index: Int, pageCount: Int, setting: Setting, dualPage: Bool) -> Int {
        ReadingPagination.page(
            index: index, pageCount: pageCount, dualPage: dualPage, exceptCover: setting.exceptCover
        )
    }

    func mapToPager(index: Int, setting: Setting, dualPage: Bool) -> Int {
        ReadingPagination.pagerIndex(page: index, dualPage: dualPage, exceptCover: setting.exceptCover)
    }
}
