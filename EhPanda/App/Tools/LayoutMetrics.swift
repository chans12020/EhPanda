//
//  LayoutMetrics.swift
//  EhPanda
//

import Foundation
import CoreGraphics

/// Measurements of the current content container, after system bars and safe areas.
/// No device model, physical screen, or interface orientation is involved.
struct LayoutMetrics: Equatable {
    var size: CGSize = .zero

    var width: CGFloat { max(1, size.width) }
    var height: CGFloat { max(1, size.height) }
    var isWide: Bool { width >= 700 }
    var supportsTwoPages: Bool { width >= 640 && height >= 300 }
    var cardWidth: CGFloat { min(480, width * 0.8) }
    var rankingWidth: CGFloat { min(360, width * (isWide ? 0.4 : 0.7)) }
    var archiveWidth: CGFloat { min(175, max(100, (width - 48) / 2)) }
    var previewMinWidth: CGFloat { isWide ? 150 : 100 }
    var previewMaxWidth: CGFloat { isWide ? 190 : 120 }
    var previewWidth: CGFloat { (previewMinWidth + previewMaxWidth) / 2 }
    var thumbnailColumns: Int { max(1, Int((width - 32 + 15) / (150 + 15))) }
    var sliderPreviewCount: Int { width >= 900 ? 7 : width >= 600 ? 5 : 3 }
}

/// Keep the exact page as the source of truth when the container changes its spread count.
struct ReadingPagination {
    static func pages(pageCount: Int, dualPage: Bool, exceptCover: Bool) -> [Int] {
        guard pageCount > 0 else { return [] }
        guard dualPage else { return Array(1...pageCount) }
        return exceptCover
            ? [1] + Array(stride(from: 2, through: pageCount, by: 2))
            : Array(stride(from: 1, through: pageCount, by: 2))
    }

    static func spread(
        firstPage: Int, pageCount: Int, dualPage: Bool, exceptCover: Bool, rightToLeft: Bool
    ) -> [Int?] {
        let first: Int? = (1...max(1, pageCount)).contains(firstPage) && pageCount > 0 ? firstPage : nil
        guard dualPage else { return [first] }
        let isCover = exceptCover && firstPage == 1
        let second: Int? = !isCover && firstPage + 1 <= pageCount ? firstPage + 1 : nil
        let pages = [first, second]
        return rightToLeft ? pages.reversed() : pages
    }

    static func pagerIndex(page: Int, dualPage: Bool, exceptCover: Bool) -> Int {
        let page = max(1, page)
        guard dualPage else { return page - 1 }
        return exceptCover ? page / 2 : (page - 1) / 2
    }

    static func page(index: Int, pageCount: Int, dualPage: Bool, exceptCover: Bool) -> Int {
        let pages = pages(pageCount: pageCount, dualPage: dualPage, exceptCover: exceptCover)
        guard !pages.isEmpty else { return 1 }
        return pages[min(max(0, index), pages.count - 1)]
    }
}
