import CommandWidgetCore
import Foundation

@MainActor
final class CommandLibraryViewModel: ObservableObject {
    @Published private(set) var entries: [CommandEntry] = []
    @Published var selectedID: CommandEntry.ID?
    @Published var query = ""
    @Published private(set) var errorMessage: String?
    private let store: JSONCommandStore
    private var catalog: StoredCommandCatalog?

    init(store: JSONCommandStore) {
        self.store = store
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
    }

    var selectedEntry: CommandEntry? {
        filteredEntries.first { $0.id == selectedID }
    }

    var filteredEntries: [CommandEntry] {
        CommandSearch.filter(entries, query: query)
    }

    func entries(in category: CommandCategory) -> [CommandEntry] {
        CommandOrdering.sorted(filteredEntries, in: category)
    }

    func selectFirstVisibleEntryIfNeeded() {
        guard !filteredEntries.contains(where: { $0.id == selectedID }) else { return }
        selectedID = filteredEntries.first?.id
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

    func dismissError() {
        errorMessage = nil
    }
}
