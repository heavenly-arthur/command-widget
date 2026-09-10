import Foundation

public struct StoredCommandCatalog: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var bundledCatalogVersion: Int?
    public var entries: [CommandEntry]

    public init(
        schemaVersion: Int = 2,
        bundledCatalogVersion: Int? = nil,
        entries: [CommandEntry]
    ) {
        self.schemaVersion = schemaVersion
        self.bundledCatalogVersion = bundledCatalogVersion
        self.entries = entries
    }
}

public final class JSONCommandStore {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> StoredCommandCatalog {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(StoredCommandCatalog.self, from: data)
    }

    @discardableResult
    public func loadOrSeed(
        with entries: [CommandEntry],
        bundledVersion: Int = 1
    ) throws -> StoredCommandCatalog {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            var catalog = try load()
            let installedVersion = catalog.bundledCatalogVersion ?? 1

            guard installedVersion < bundledVersion else {
                return catalog
            }

            let existingIDs = Set(catalog.entries.map(\.id))
            let additions = entries.filter { entry in
                let introducedIn = entry.bundledVersion ?? 1
                return introducedIn > installedVersion
                    && introducedIn <= bundledVersion
                    && !existingIDs.contains(entry.id)
            }

            catalog.entries.append(contentsOf: additions)
            catalog.entries = CommandOrdering.normalized(catalog.entries)
            catalog.schemaVersion = 2
            catalog.bundledCatalogVersion = bundledVersion
            try save(catalog)
            return catalog
        }

        let eligibleEntries = entries.filter { ($0.bundledVersion ?? 1) <= bundledVersion }
        let catalog = StoredCommandCatalog(
            bundledCatalogVersion: bundledVersion,
            entries: CommandOrdering.normalized(eligibleEntries)
        )
        try save(catalog)
        return catalog
    }

    public func save(_ catalog: StoredCommandCatalog) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(catalog)
        try data.write(to: fileURL, options: .atomic)
    }
}
