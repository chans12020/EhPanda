import Foundation
import CoreGraphics

var checks = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    checks += 1
    guard condition() else { fatalError(message) }
}

// These are container sizes, not a device-model table. Include near-square open layouts,
// short landscape panes, split windows, and unmeasured startup geometry.
let sizes: [CGSize] = [
    .zero, .init(width: 280, height: 600), .init(width: 375, height: 720),
    .init(width: 600, height: 800), .init(width: 640, height: 600),
    .init(width: 720, height: 720), .init(width: 900, height: 650),
    .init(width: 1024, height: 250), .init(width: 1366, height: 1024)
]
for size in sizes {
    let layout = LayoutMetrics(size: size)
    check(layout.width > 0 && layout.height > 0, "Empty geometry must not cause division by zero")
    check(layout.cardWidth > 0 && layout.cardWidth <= layout.width, "Cards must fit their container")
    check(layout.thumbnailColumns >= 1, "A narrow window still needs a grid column")
    check(layout.previewWidth.isFinite, "Preview dimensions must stay finite")
}
check(!LayoutMetrics(size: .init(width: 375, height: 720)).supportsTwoPages, "Outer-size panes use one page")
check(LayoutMetrics(size: .init(width: 720, height: 720)).supportsTwoPages, "A square open pane supports a spread")
check(!LayoutMetrics(size: .init(width: 1024, height: 250)).supportsTwoPages, "Short panes keep readable single pages")
let columns = stride(from: 280, through: 1400, by: 20).map {
    LayoutMetrics(size: .init(width: $0, height: 800)).thumbnailColumns
}
check(zip(columns, columns.dropFirst()).allSatisfy { $0 <= $1 }, "More space must not remove grid columns")

check(ReadingPagination.pages(pageCount: 0, dualPage: true, exceptCover: true).isEmpty, "Empty gallery must not create an invalid range")
check(ReadingPagination.spread(firstPage: 1, pageCount: 5, dualPage: true, exceptCover: true, rightToLeft: true) == [nil, 1], "RTL cover belongs on the right")
check(ReadingPagination.spread(firstPage: 5, pageCount: 5, dualPage: true, exceptCover: false, rightToLeft: true) == [nil, 5], "RTL final odd page needs a blank leading slot")
check(ReadingPagination.spread(firstPage: 2, pageCount: 5, dualPage: true, exceptCover: true, rightToLeft: false) == [2, 3], "Cover exclusion must pair pages two and three")

for count in 1...100 {
    for dualPage in [false, true] {
        for exceptCover in [false, true] {
            let starts = ReadingPagination.pages(pageCount: count, dualPage: dualPage, exceptCover: exceptCover)
            for rightToLeft in [false, true] {
                let displayed = starts.flatMap {
                    ReadingPagination.spread(firstPage: $0, pageCount: count, dualPage: dualPage,
                                             exceptCover: exceptCover, rightToLeft: rightToLeft).compactMap { $0 }
                }
                check(displayed.sorted() == Array(1...count), "Every page must appear exactly once, including cover and tail")
            }
            for exactPage in 1...count {
                let index = ReadingPagination.pagerIndex(page: exactPage, dualPage: dualPage, exceptCover: exceptCover)
                check(starts.indices.contains(index), "Resizing must keep the pager in bounds")
                let spread = ReadingPagination.spread(firstPage: starts[index], pageCount: count,
                    dualPage: dualPage, exceptCover: exceptCover, rightToLeft: false)
                check(spread.contains(exactPage), "The selected page must remain visible after a spread change")
                let folded = ReadingPagination.pagerIndex(page: exactPage, dualPage: false, exceptCover: exceptCover)
                check(folded + 1 == exactPage, "Folding back must preserve the exact page, including an even page")
            }
            check(ReadingPagination.page(index: -1, pageCount: count, dualPage: dualPage, exceptCover: exceptCover) == 1,
                  "Stale negative pager positions must be clamped")
            check(ReadingPagination.page(index: Int.max, pageCount: count, dualPage: dualPage, exceptCover: exceptCover) == starts.last,
                  "Stale oversized pager positions must be clamped")
        }
    }
}
print("Passed \(checks) Duo layout and pagination checks")
