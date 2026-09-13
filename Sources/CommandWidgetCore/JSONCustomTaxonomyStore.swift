import Foundation

public final class JSONCustomTaxonomyStore {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> CustomCommandTaxonomy? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(CustomCommandTaxonomy.self, from: data)
    }

    public func save(_ taxonomy: CustomCommandTaxonomy) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(taxonomy)
        try data.write(to: fileURL, options: .atomic)
    }
}
