import Foundation

public struct CustomCommandSubcategory: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isEnabled: Bool

    public init(id: UUID = UUID(), title: String, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
    }
}

public struct CustomCommandCategory: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isEnabled: Bool
    public var subcategories: [CustomCommandSubcategory]

    public init(
        id: UUID = UUID(),
        title: String,
        isEnabled: Bool = true,
        subcategories: [CustomCommandSubcategory] = []
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.subcategories = subcategories
    }
}

public struct CustomCommandTaxonomy: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1
    public static let maximumTitleLength = 80

    public var schemaVersion: Int
    public var categories: [CustomCommandCategory]

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        categories: [CustomCommandCategory] = []
    ) {
        self.schemaVersion = schemaVersion
        self.categories = categories
    }

    @discardableResult
    public mutating func addCategory(title: String) throws -> UUID {
        let normalized = try Self.validatedTitle(title)
        guard !containsCategory(named: normalized) else {
            throw CustomTaxonomyError.duplicateCategory
        }
        guard !CommandCategory.allCases.contains(where: {
            Self.matches($0.rawValue, normalized)
        }) else {
            throw CustomTaxonomyError.duplicateBuiltInCategory
        }

        let category = CustomCommandCategory(title: normalized)
        categories.append(category)
        return category.id
    }

    public mutating func renameCategory(id: UUID, title: String) throws {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        let normalized = try Self.validatedTitle(title)
        guard !categories.contains(where: {
            $0.id != id && Self.matches($0.title, normalized)
        }) else {
            throw CustomTaxonomyError.duplicateCategory
        }
        guard !CommandCategory.allCases.contains(where: {
            Self.matches($0.rawValue, normalized)
        }) else {
            throw CustomTaxonomyError.duplicateBuiltInCategory
        }
        categories[index].title = normalized
    }

    public mutating func setCategoryEnabled(id: UUID, isEnabled: Bool) throws {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        categories[index].isEnabled = isEnabled
    }

    public mutating func removeCategory(id: UUID) throws {
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        categories.remove(at: index)
    }

    @discardableResult
    public mutating func addSubcategory(categoryID: UUID, title: String) throws -> UUID {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        let normalized = try Self.validatedTitle(title)
        guard !categories[categoryIndex].subcategories.contains(where: {
            Self.matches($0.title, normalized)
        }) else {
            throw CustomTaxonomyError.duplicateSubcategory
        }

        let subcategory = CustomCommandSubcategory(title: normalized)
        categories[categoryIndex].subcategories.append(subcategory)
        return subcategory.id
    }

    public mutating func renameSubcategory(
        categoryID: UUID,
        subcategoryID: UUID,
        title: String
    ) throws {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        guard let subcategoryIndex = categories[categoryIndex].subcategories.firstIndex(where: {
            $0.id == subcategoryID
        }) else {
            throw CustomTaxonomyError.subcategoryNotFound
        }
        let normalized = try Self.validatedTitle(title)
        guard !categories[categoryIndex].subcategories.contains(where: {
            $0.id != subcategoryID && Self.matches($0.title, normalized)
        }) else {
            throw CustomTaxonomyError.duplicateSubcategory
        }
        categories[categoryIndex].subcategories[subcategoryIndex].title = normalized
    }

    public mutating func setSubcategoryEnabled(
        categoryID: UUID,
        subcategoryID: UUID,
        isEnabled: Bool
    ) throws {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        guard let subcategoryIndex = categories[categoryIndex].subcategories.firstIndex(where: {
            $0.id == subcategoryID
        }) else {
            throw CustomTaxonomyError.subcategoryNotFound
        }
        categories[categoryIndex].subcategories[subcategoryIndex].isEnabled = isEnabled
    }

    public mutating func removeSubcategory(categoryID: UUID, subcategoryID: UUID) throws {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else {
            throw CustomTaxonomyError.categoryNotFound
        }
        guard let subcategoryIndex = categories[categoryIndex].subcategories.firstIndex(where: {
            $0.id == subcategoryID
        }) else {
            throw CustomTaxonomyError.subcategoryNotFound
        }
        categories[categoryIndex].subcategories.remove(at: subcategoryIndex)
    }

    private func containsCategory(named title: String) -> Bool {
        categories.contains { Self.matches($0.title, title) }
    }

    private static func validatedTitle(_ title: String) throws -> String {
        let normalized = title
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        guard !normalized.isEmpty else { throw CustomTaxonomyError.emptyTitle }
        guard normalized.count <= maximumTitleLength else {
            throw CustomTaxonomyError.titleTooLong(maximum: maximumTitleLength)
        }
        return normalized
    }

    private static func matches(_ lhs: String, _ rhs: String) -> Bool {
        lhs.compare(rhs, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }
}

public enum CustomTaxonomyError: Error, Equatable, LocalizedError {
    case emptyTitle
    case titleTooLong(maximum: Int)
    case duplicateCategory
    case duplicateBuiltInCategory
    case duplicateSubcategory
    case categoryNotFound
    case subcategoryNotFound

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Название не может быть пустым."
        case let .titleTooLong(maximum):
            return "Название не должно быть длиннее \(maximum) символов."
        case .duplicateCategory:
            return "Категория с таким названием уже существует."
        case .duplicateBuiltInCategory:
            return "Такое название уже используется встроенной категорией."
        case .duplicateSubcategory:
            return "Подкатегория с таким названием уже существует в этой категории."
        case .categoryNotFound:
            return "Категория больше не существует."
        case .subcategoryNotFound:
            return "Подкатегория больше не существует."
        }
    }
}
