import Foundation

public enum CommandSearch {
    public static func filter(_ entries: [CommandEntry], query: String) -> [CommandEntry] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return entries }

        return entries.filter { entry in
            [
                entry.title,
                entry.command,
                entry.category.rawValue,
                entry.tags.joined(separator: " "),
                entry.summary,
                entry.details,
                entry.examples.joined(separator: " ")
            ].contains { $0.localizedCaseInsensitiveContains(normalized) }
        }
    }
}
