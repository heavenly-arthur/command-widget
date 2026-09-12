import Foundation

public enum CommandRole: String, Codable, CaseIterable, Identifiable, Sendable {
    case devOps = "DevOps"
    case frontend = "Frontend"
    case backend = "Backend"
    case qa = "QA"

    public var id: String { rawValue }

    public var recommendedCategories: Set<CommandCategory> {
        switch self {
        case .devOps:
            return [.kubernetes, .helm, .flux, .linux, .ansible, .terraform, .crowdsec, .mattermost, .git]
        case .frontend:
            return [.nodeJS, .typescript, .frontendTooling, .frontendTesting, .git]
        case .backend:
            return [.python, .go, .databases, .apiAndGRPC, .linux, .ollama, .kubernetes, .git]
        case .qa:
            return [.apiTesting, .uiTesting, .loadTesting, .mobileAccessibility, .git, .linux]
        }
    }
}

public struct LibraryPreferences: Codable, Equatable, Sendable {
    public var selectedRoles: Set<CommandRole>
    public var selectedCategories: Set<CommandCategory>
    public var selectedSubcategories: Set<CommandSubcategory>?
    public var bundledCatalogVersion: Int?

    public init(
        selectedRoles: Set<CommandRole>,
        selectedCategories: Set<CommandCategory>,
        selectedSubcategories: Set<CommandSubcategory>? = nil,
        bundledCatalogVersion: Int? = StarterCatalog.currentVersion
    ) {
        self.selectedRoles = selectedRoles
        self.selectedCategories = selectedCategories
        self.selectedSubcategories = selectedSubcategories
        self.bundledCatalogVersion = bundledCatalogVersion
    }

    public static let initial = LibraryPreferences(
        selectedRoles: Set(CommandRole.allCases),
        selectedCategories: Set(CommandCategory.allCases),
        selectedSubcategories: Set(CommandSubcategory.all),
        bundledCatalogVersion: StarterCatalog.currentVersion
    )

    public static func recommended(for roles: Set<CommandRole>) -> Set<CommandCategory> {
        roles.reduce(into: Set<CommandCategory>()) { result, role in
            result.formUnion(role.recommendedCategories)
        }
    }

    public static func subcategories(for categories: Set<CommandCategory>) -> Set<CommandSubcategory> {
        Set(CommandSubcategory.all.filter { categories.contains($0.category) })
    }

    public var effectiveSelectedSubcategories: Set<CommandSubcategory> {
        selectedSubcategories ?? Self.subcategories(for: selectedCategories)
    }

    public mutating func setRole(_ role: CommandRole, isSelected: Bool) {
        var subcategories = effectiveSelectedSubcategories
        if isSelected {
            selectedRoles.insert(role)
            selectedCategories.formUnion(role.recommendedCategories)
            subcategories.formUnion(Self.subcategories(for: role.recommendedCategories))
            selectedSubcategories = subcategories
            return
        }

        selectedRoles.remove(role)
        let categoriesNeededByRemainingRoles = Self.recommended(for: selectedRoles)
        let categoriesExclusiveToRemovedRole = role.recommendedCategories.subtracting(
            categoriesNeededByRemainingRoles
        )
        selectedCategories.subtract(categoriesExclusiveToRemovedRole)
        subcategories.subtract(Self.subcategories(for: categoriesExclusiveToRemovedRole))
        selectedSubcategories = subcategories
    }

    public mutating func setCategory(_ category: CommandCategory, isSelected: Bool) {
        var subcategories = effectiveSelectedSubcategories
        let categorySubcategories = Set(CommandSubcategory.all(in: category))

        if isSelected {
            selectedCategories.insert(category)
            subcategories.formUnion(categorySubcategories)
        } else {
            selectedCategories.remove(category)
            subcategories.subtract(categorySubcategories)
        }
        selectedSubcategories = subcategories
    }

    public mutating func setSubcategory(_ subcategory: CommandSubcategory, isSelected: Bool) {
        var subcategories = effectiveSelectedSubcategories
        if isSelected {
            subcategories.insert(subcategory)
            selectedCategories.insert(subcategory.category)
        } else {
            subcategories.remove(subcategory)
            let hasSelectedSibling = subcategories.contains { $0.category == subcategory.category }
            if !hasSelectedSibling {
                selectedCategories.remove(subcategory.category)
            }
        }
        selectedSubcategories = subcategories
    }

    public func includes(_ entry: CommandEntry) -> Bool {
        selectedCategories.contains(entry.category)
            && effectiveSelectedSubcategories.contains(entry.subcategory)
    }

    public func migratedTaxonomy() -> LibraryPreferences {
        guard selectedSubcategories == nil else { return self }
        return LibraryPreferences(
            selectedRoles: selectedRoles,
            selectedCategories: selectedCategories,
            selectedSubcategories: Self.subcategories(for: selectedCategories),
            bundledCatalogVersion: bundledCatalogVersion
        )
    }

    public func migrated(to version: Int) -> LibraryPreferences {
        let installedVersion = bundledCatalogVersion ?? 4
        guard installedVersion < version else { return self }

        let newRecommendedCategories = Self.recommended(for: selectedRoles).filter {
            $0.bundledVersion > installedVersion && $0.bundledVersion <= version
        }
        return LibraryPreferences(
            selectedRoles: selectedRoles,
            selectedCategories: selectedCategories.union(newRecommendedCategories),
            selectedSubcategories: effectiveSelectedSubcategories.union(
                Self.subcategories(for: Set(newRecommendedCategories))
            ),
            bundledCatalogVersion: version
        )
    }
}

public final class JSONLibraryPreferencesStore {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> LibraryPreferences? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(LibraryPreferences.self, from: data)
    }

    public func save(_ preferences: LibraryPreferences) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(preferences)
        try data.write(to: fileURL, options: .atomic)
    }
}
