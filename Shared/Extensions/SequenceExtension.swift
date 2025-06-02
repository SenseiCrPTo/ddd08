// Shared/Extensions/SequenceExtension.swift
import Foundation

extension Sequence where Element: Hashable {
    /// Returns an array containing only the unique elements of this sequence, in the order of their first appearance.
    func removingDuplicates() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

// Опционально, если вам также нужен .unique как свойство, а не метод:
// extension Sequence where Element: Hashable {
//     var unique: [Element] {
//         var set = Set<Element>()
//         return filter { set.insert($0).inserted }
//     }
// }
// Если вы добавите .unique, то в ClearChartView можно будет писать .unique.sorted()
// Но .removingDuplicates().sorted() тоже отлично работает.
