import CommandWidgetCore
import Foundation

@MainActor
final class CommandLibraryViewModel: ObservableObject {
    @Published private(set) var entries: [CommandEntry] = []
    @Published var selectedID: CommandEntry.ID?
    @Published var query = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var preferences = LibraryPreferences.initial
    @Published private(set) var customTaxonomy = CustomCommandTaxonomy()
    @Published var isPresentingPreferences = false
    @Published var isPresentingCustomTaxonomy = false
    @Published private(set) var requiresInitialSetup = false
    private let store: JSONCommandStore
    private let preferencesStore: JSONLibraryPreferencesStore
    private let customTaxonomyStore: JSONCustomTaxonomyStore
    private var catalog: StoredCommandCatalog?

    init(
        store: JSONCommandStore,
        preferencesStore: JSONLibraryPreferencesStore,
        customTaxonomyStore: JSONCustomTaxonomyStore
    ) {
        self.store = store
        self.preferencesStore = preferencesStore
        self.customTaxonomyStore = customTaxonomyStore
        do {
            let catalog = try store.loadOrSeed(
                with: StarterCatalog.entries,
                bundledVersion: StarterCatalog.currentVersion
            )
            self.catalog = catalog
            entries = catalog.entries
        } catch {
            errorMessage = "Не удалось прочитать локальный каталог: \(error.localizedDescription)"
        }

        do {
            if let storedPreferences = try preferencesStore.load() {
                let migratedPreferences = storedPreferences.migrated(
                    to: StarterCatalog.currentVersion
                ).migratedTaxonomy()
                if migratedPreferences != storedPreferences {
                    try preferencesStore.save(migratedPreferences)
                }
                preferences = migratedPreferences
            } else {
                requiresInitialSetup = true
                isPresentingPreferences = true
            }
        } catch {
            requiresInitialSetup = true
            isPresentingPreferences = true
            errorMessage = "Не удалось прочитать настройки: \(error.localizedDescription)"
        }

        do {
            customTaxonomy = try customTaxonomyStore.load() ?? CustomCommandTaxonomy()
        } catch {
            errorMessage = "Не удалось прочитать пользовательские категории: \(error.localizedDescription)"
        }
    }

    var selectedEntry: CommandEntry? {
        filteredEntries.first { $0.id == selectedID }
    }

    var filteredEntries: [CommandEntry] {
        let configuredEntries = entries.filter(preferences.includes)
        return CommandSearch.filter(configuredEntries, query: query)
    }

    var visibleCategories: [CommandCategory] {
        CommandCategory.allCases.filter { preferences.selectedCategories.contains($0) }
    }

    var visibleCustomCategories: [CustomCommandCategory] {
        let enabled = customTaxonomy.categories.filter(\.isEnabled)
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return enabled }
        return enabled.filter { category in
            category.title.localizedCaseInsensitiveContains(normalized)
                || category.subcategories.contains {
                    $0.isEnabled && $0.title.localizedCaseInsensitiveContains(normalized)
                }
        }
    }

    var hasVisibleContent: Bool {
        !filteredEntries.isEmpty || !visibleCustomCategories.isEmpty
    }

    func subcategories(in category: CustomCommandCategory) -> [CustomCommandSubcategory] {
        let enabled = category.subcategories.filter(\.isEnabled)
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return enabled }
        if category.title.localizedCaseInsensitiveContains(normalized) {
            return enabled
        }
        return enabled.filter { $0.title.localizedCaseInsensitiveContains(normalized) }
    }

    func entries(in category: CommandCategory) -> [CommandEntry] {
        CommandOrdering.sorted(filteredEntries, in: category)
    }

    func subcategories(in category: CommandCategory) -> [CommandSubcategory] {
        CommandSubcategory.all(in: category).filter { subcategory in
            !entries(in: subcategory).isEmpty
        }
    }

    func entries(in subcategory: CommandSubcategory) -> [CommandEntry] {
        CommandOrdering.sorted(filteredEntries, in: subcategory.category).filter {
            $0.subcategory == subcategory
        }
    }

    func selectFirstVisibleEntryIfNeeded() {
        guard !filteredEntries.contains(where: { $0.id == selectedID }) else { return }
        selectedID = filteredEntries.first?.id
    }

    func showPreferences() {
        isPresentingPreferences = true
    }

    func hidePreferences() {
        guard !requiresInitialSetup else { return }
        isPresentingPreferences = false
    }

    func showCustomTaxonomy() {
        isPresentingCustomTaxonomy = true
    }

    func hideCustomTaxonomy() {
        isPresentingCustomTaxonomy = false
    }

    @discardableResult
    func saveCustomTaxonomy(_ updated: CustomCommandTaxonomy) -> Bool {
        do {
            try customTaxonomyStore.save(updated)
            customTaxonomy = updated
            isPresentingCustomTaxonomy = false
            return true
        } catch {
            errorMessage = "Не удалось сохранить пользовательские категории: \(error.localizedDescription)"
            return false
        }
    }

    @discardableResult
    func savePreferences(
        roles: Set<CommandRole>,
        categories: Set<CommandCategory>,
        subcategories: Set<CommandSubcategory>
    ) -> Bool {
        guard !roles.isEmpty, !categories.isEmpty, !subcategories.isEmpty else {
            errorMessage = "Выберите хотя бы одну роль, категорию и подкатегорию."
            return false
        }

        let updated = LibraryPreferences(
            selectedRoles: roles,
            selectedCategories: categories,
            selectedSubcategories: subcategories,
            bundledCatalogVersion: StarterCatalog.currentVersion
        )
        do {
            try preferencesStore.save(updated)
            preferences = updated
            requiresInitialSetup = false
            isPresentingPreferences = false
            selectFirstVisibleEntryIfNeeded()
            return true
        } catch {
            errorMessage = "Не удалось сохранить настройки: \(error.localizedDescription)"
            return false
        }
    }

    func move(in category: CommandCategory, from source: IndexSet, to destination: Int) {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let previous = entries
        entries = CommandOrdering.moving(
            entries,
            in: category,
            fromOffsets: source,
            toOffset: destination
        )

        guard var catalog else { return }
        catalog.entries = entries
        do {
            try store.save(catalog)
            self.catalog = catalog
        } catch {
            entries = previous
            errorMessage = "Не удалось сохранить порядок: \(error.localizedDescription)"
        }
    }

    func move(in subcategory: CommandSubcategory, from source: IndexSet, to destination: Int) {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let previous = entries
        entries = CommandOrdering.moving(
            entries,
            within: subcategory,
            fromOffsets: source,
            toOffset: destination
        )

        guard var catalog else { return }
        catalog.entries = entries
        do {
            try store.save(catalog)
            self.catalog = catalog
        } catch {
            entries = previous
            errorMessage = "Не удалось сохранить порядок: \(error.localizedDescription)"
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
