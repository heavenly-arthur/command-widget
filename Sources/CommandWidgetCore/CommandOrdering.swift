import Foundation

public enum CommandOrdering {
    public static func sorted(
        _ entries: [CommandEntry],
        in category: CommandCategory
    ) -> [CommandEntry] {
        entries.enumerated()
            .filter { $0.element.category == category }
            .sorted { lhs, rhs in
                let leftOrder = lhs.element.order ?? lhs.offset
                let rightOrder = rhs.element.order ?? rhs.offset
                return leftOrder == rightOrder ? lhs.offset < rhs.offset : leftOrder < rightOrder
            }
            .map(\.element)
    }

    public static func normalized(_ entries: [CommandEntry]) -> [CommandEntry] {
        var result = entries
        for category in CommandCategory.allCases {
            let positions = result.indices.filter { result[$0].category == category }
            let ordered = sorted(result, in: category)
            for (order, pair) in zip(positions, ordered).enumerated() {
                let position = pair.0
                var entry = pair.1
                entry.order = order
                result[position] = entry
            }
        }
        return result
    }

    public static func moving(
        _ entries: [CommandEntry],
        in category: CommandCategory,
        fromOffsets source: IndexSet,
        toOffset destination: Int
    ) -> [CommandEntry] {
        let positions = entries.indices.filter { entries[$0].category == category }
        var categoryEntries = sorted(entries, in: category)
        let validSource = source.filter { categoryEntries.indices.contains($0) }.sorted()
        guard !validSource.isEmpty else { return entries }

        let movingEntries = validSource.map { categoryEntries[$0] }
        for index in validSource.reversed() {
            categoryEntries.remove(at: index)
        }

        let removedBeforeDestination = validSource.filter { $0 < destination }.count
        let insertion = max(0, min(destination - removedBeforeDestination, categoryEntries.count))
        categoryEntries.insert(contentsOf: movingEntries, at: insertion)

        var result = entries
        for (order, pair) in zip(positions, categoryEntries).enumerated() {
            let position = pair.0
            var entry = pair.1
            entry.order = order
            result[position] = entry
        }
        return result
    }

    public static func moving(
        _ entries: [CommandEntry],
        within subcategory: CommandSubcategory,
        fromOffsets source: IndexSet,
        toOffset destination: Int
    ) -> [CommandEntry] {
        let categoryPositions = entries.indices.filter {
            entries[$0].category == subcategory.category
        }
        var categoryEntries = sorted(entries, in: subcategory.category)
        let subcategoryPositions = categoryEntries.indices.filter {
            categoryEntries[$0].subcategory == subcategory
        }
        var subcategoryEntries = subcategoryPositions.map { categoryEntries[$0] }
        let validSource = source.filter { subcategoryEntries.indices.contains($0) }.sorted()
        guard !validSource.isEmpty else { return entries }

        let movingEntries = validSource.map { subcategoryEntries[$0] }
        for index in validSource.reversed() {
            subcategoryEntries.remove(at: index)
        }

        let removedBeforeDestination = validSource.filter { $0 < destination }.count
        let insertion = max(0, min(destination - removedBeforeDestination, subcategoryEntries.count))
        subcategoryEntries.insert(contentsOf: movingEntries, at: insertion)

        for (position, entry) in zip(subcategoryPositions, subcategoryEntries) {
            categoryEntries[position] = entry
        }

        var result = entries
        for (order, pair) in zip(categoryPositions, categoryEntries).enumerated() {
            let position = pair.0
            var entry = pair.1
            entry.order = order
            result[position] = entry
        }
        return result
    }
}
