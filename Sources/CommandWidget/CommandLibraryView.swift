import AppKit
import CommandWidgetCore
import SwiftUI

struct CommandLibraryView: View {
    @ObservedObject var viewModel: CommandLibraryViewModel
    @State private var expandedCategories: Set<CommandCategory> = []
    @State private var expandedSubcategories: Set<CommandSubcategory> = []

    var body: some View {
        ZStack {
            NavigationSplitView {
                List(selection: $viewModel.selectedID) {
                ForEach(viewModel.visibleCategories) { category in
                    Section {
                        if expandedCategories.contains(category) {
                            ForEach(viewModel.subcategories(in: category)) { subcategory in
                                Button {
                                    toggle(subcategory)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(
                                            systemName: expandedSubcategories.contains(subcategory)
                                                ? "chevron.down"
                                                : "chevron.right"
                                        )
                                        .font(.caption.weight(.semibold))
                                        .frame(width: 10)

                                        Text(subcategory.title)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Text("\(viewModel.entries(in: subcategory).count)")
                                            .font(.caption.monospacedDigit())
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, 8)
                                .accessibilityLabel(
                                    "\(subcategory.title), \(viewModel.entries(in: subcategory).count)"
                                )
                                .accessibilityHint(
                                    expandedSubcategories.contains(subcategory)
                                        ? "Свернуть подкатегорию"
                                        : "Развернуть подкатегорию"
                                )

                                if expandedSubcategories.contains(subcategory) {
                                    let subcategoryEntries = viewModel.entries(in: subcategory)
                                    ForEach(Array(subcategoryEntries.enumerated()), id: \.element.id) { index, entry in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("\(index + 1).")
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.tertiary)
                                                .frame(width: 22, alignment: .trailing)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.title)
                                                    .font(.headline)
                                                Text(entry.command)
                                                    .font(.system(.caption, design: .monospaced))
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.leading, 16)
                                        .padding(.vertical, 3)
                                        .tag(entry.id)
                                        .moveDisabled(!viewModel.query.isEmpty)
                                    }
                                    .onMove { source, destination in
                                        viewModel.move(
                                            in: subcategory,
                                            from: source,
                                            to: destination
                                        )
                                    }
                                }
                            }
                        }
                    } header: {
                        Button {
                            toggle(category)
                        } label: {
                            HStack {
                                Image(systemName: expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .frame(width: 10)
                                Text(category.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.entries(in: category).count)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(category.rawValue), \(viewModel.entries(in: category).count)")
                        .accessibilityHint(expandedCategories.contains(category) ? "Свернуть категорию" : "Развернуть категорию")
                    }
                }
                }
                .navigationTitle("Команды")
                .navigationSplitViewColumnWidth(min: 230, ideal: 270)
                .searchable(text: $viewModel.query, prompt: "Команда, категория или тег")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewModel.showPreferences()
                        } label: {
                            Label("Роли и категории", systemImage: "slider.horizontal.3")
                        }
                        .help("Настроить роли и категории")
                    }
                }
                .overlay {
                    if viewModel.filteredEntries.isEmpty {
                        ContentUnavailableView.search(text: viewModel.query)
                    }
                }
                .onChange(of: viewModel.query) {
                    viewModel.selectFirstVisibleEntryIfNeeded()
                    let normalized = viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
                    if normalized.isEmpty {
                        expandedCategories.removeAll()
                        expandedSubcategories.removeAll()
                    } else {
                        expandedCategories = Set(
                            viewModel.visibleCategories.filter { !viewModel.entries(in: $0).isEmpty }
                        )
                        expandedSubcategories = Set(
                            viewModel.visibleCategories.flatMap(viewModel.subcategories)
                        )
                    }
                }
            } detail: {
                if let entry = viewModel.selectedEntry {
                    CommandDetailView(entry: entry)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Каталог недоступен",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    ContentUnavailableView("Выберите команду", systemImage: "terminal")
                }
            }

            if viewModel.isPresentingPreferences {
                LibraryPreferencesView(
                    preferences: viewModel.preferences,
                    isInitialSetup: viewModel.requiresInitialSetup,
                    onCancel: viewModel.hidePreferences
                ) { roles, categories, subcategories in
                    viewModel.savePreferences(
                        roles: roles,
                        categories: categories,
                        subcategories: subcategories
                    )
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .alert(
            "Ошибка локального каталога",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
    }

    private func toggle(_ category: CommandCategory) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }

    private func toggle(_ subcategory: CommandSubcategory) {
        if expandedSubcategories.contains(subcategory) {
            expandedSubcategories.remove(subcategory)
        } else {
            expandedSubcategories.insert(subcategory)
        }
    }
}

private struct LibraryPreferencesView: View {
    @State private var selectedRoles: Set<CommandRole>
    @State private var selectedCategories: Set<CommandCategory>
    @State private var selectedSubcategories: Set<CommandSubcategory>
    @State private var expandedCategories: Set<CommandCategory> = []
    let isInitialSetup: Bool
    let onCancel: () -> Void
    let onSave: (Set<CommandRole>, Set<CommandCategory>, Set<CommandSubcategory>) -> Bool

    init(
        preferences: LibraryPreferences,
        isInitialSetup: Bool,
        onCancel: @escaping () -> Void,
        onSave: @escaping (Set<CommandRole>, Set<CommandCategory>, Set<CommandSubcategory>) -> Bool
    ) {
        _selectedRoles = State(initialValue: preferences.selectedRoles)
        _selectedCategories = State(initialValue: preferences.selectedCategories)
        _selectedSubcategories = State(initialValue: preferences.effectiveSelectedSubcategories)
        self.isInitialSetup = isInitialSetup
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(isInitialSetup ? "Настройте Command Widget" : "Роли и категории")
                    .font(.title2.weight(.semibold))
                Text("Роль выбирает категории, а внутри категории можно оставить только нужные инструменты.")
                    .foregroundStyle(.secondary)
            }

            GroupBox("Роли") {
                roleGrid
                    .padding(.top, 6)
            }

            GroupBox("Категории CLI") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button("Выбрать все") {
                            selectedCategories = Set(CommandCategory.allCases)
                            selectedSubcategories = Set(CommandSubcategory.all)
                        }
                        Button("По ролям") {
                            selectedCategories = LibraryPreferences.recommended(for: selectedRoles)
                            selectedSubcategories = LibraryPreferences.subcategories(for: selectedCategories)
                        }
                        Spacer()
                        Text("\(selectedCategories.count) категорий · \(selectedSubcategories.count) инструментов")
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    ScrollView {
                        categoryList
                    }
                    .frame(minHeight: 280, maxHeight: .infinity)
                }
                .padding(.top, 6)
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)

            HStack {
                if !isInitialSetup {
                    Button("Отмена") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)
                }
                Spacer()
                Button(isInitialSetup ? "Начать работу" : "Сохранить") {
                    _ = onSave(selectedRoles, selectedCategories, selectedSubcategories)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(selectedRoles.isEmpty || selectedCategories.isEmpty || selectedSubcategories.isEmpty)
            }
        }
        .padding(24)
        .frame(
            minWidth: 680,
            maxWidth: .infinity,
            minHeight: 520,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(.background)
    }

    private var roleGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading)], alignment: .leading) {
            ForEach(CommandRole.allCases) { role in
                Toggle(role.rawValue, isOn: roleBinding(role))
                    .toggleStyle(.checkbox)
            }
        }
    }

    private var categoryList: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(CommandCategory.allCases) { category in
                DisclosureGroup(isExpanded: expansionBinding(category)) {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 155), alignment: .leading)],
                        alignment: .leading,
                        spacing: 8
                    ) {
                        ForEach(CommandSubcategory.all(in: category)) { subcategory in
                            Toggle(subcategory.title, isOn: subcategoryBinding(subcategory))
                                .toggleStyle(.checkbox)
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.vertical, 6)
                } label: {
                    HStack(spacing: 8) {
                        Button {
                            toggleCategorySelection(category)
                        } label: {
                            Image(systemName: categorySelectionImage(category))
                                .foregroundStyle(
                                    categorySelectedCount(category) == 0 ? Color.secondary : Color.accentColor
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Выбрать категорию \(category.rawValue)")

                        Text(category.rawValue)
                            .font(.headline)
                        Spacer()
                        Text("\(categorySelectedCount(category))/\(CommandSubcategory.all(in: category).count)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func roleBinding(_ role: CommandRole) -> Binding<Bool> {
        Binding(
            get: { selectedRoles.contains(role) },
            set: { isSelected in
                var draft = LibraryPreferences(
                    selectedRoles: selectedRoles,
                    selectedCategories: selectedCategories,
                    selectedSubcategories: selectedSubcategories
                )
                draft.setRole(role, isSelected: isSelected)
                selectedRoles = draft.selectedRoles
                selectedCategories = draft.selectedCategories
                selectedSubcategories = draft.effectiveSelectedSubcategories
            }
        )
    }

    private func subcategoryBinding(_ subcategory: CommandSubcategory) -> Binding<Bool> {
        Binding(
            get: { selectedSubcategories.contains(subcategory) },
            set: { isSelected in
                var draft = LibraryPreferences(
                    selectedRoles: selectedRoles,
                    selectedCategories: selectedCategories,
                    selectedSubcategories: selectedSubcategories
                )
                draft.setSubcategory(subcategory, isSelected: isSelected)
                selectedCategories = draft.selectedCategories
                selectedSubcategories = draft.effectiveSelectedSubcategories
            }
        )
    }

    private func expansionBinding(_ category: CommandCategory) -> Binding<Bool> {
        Binding(
            get: { expandedCategories.contains(category) },
            set: { isExpanded in
                if isExpanded {
                    expandedCategories.insert(category)
                } else {
                    expandedCategories.remove(category)
                }
            }
        )
    }

    private func toggleCategorySelection(_ category: CommandCategory) {
        let available = Set(CommandSubcategory.all(in: category))
        let allSelected = available.isSubset(of: selectedSubcategories)
        var draft = LibraryPreferences(
            selectedRoles: selectedRoles,
            selectedCategories: selectedCategories,
            selectedSubcategories: selectedSubcategories
        )
        draft.setCategory(category, isSelected: !allSelected)
        selectedCategories = draft.selectedCategories
        selectedSubcategories = draft.effectiveSelectedSubcategories
    }

    private func categorySelectedCount(_ category: CommandCategory) -> Int {
        CommandSubcategory.all(in: category).filter(selectedSubcategories.contains).count
    }

    private func categorySelectionImage(_ category: CommandCategory) -> String {
        let selectedCount = categorySelectedCount(category)
        let total = CommandSubcategory.all(in: category).count
        if selectedCount == 0 { return "square" }
        if selectedCount == total { return "checkmark.square.fill" }
        return "minus.square.fill"
    }
}

private struct CommandDetailView: View {
    let entry: CommandEntry
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(entry.category.rawValue) / \(entry.subcategory.title)".uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                    Text(entry.title)
                        .font(.title2.weight(.semibold))
                    Text(entry.summary)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(entry.command)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(entry.command, forType: .string)
                        copied = true
                    } label: {
                        Label(copied ? "Скопировано" : "Копировать", systemImage: copied ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(12)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                Text(entry.details)
                    .textSelection(.enabled)

                if !entry.examples.isEmpty {
                    Text("Примеры")
                        .font(.headline)
                    ForEach(entry.examples, id: \.self) { example in
                        Text(example)
                            .font(.system(.callout, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                    }
                }

                Text(entry.tags.map { "#\($0)" }.joined(separator: "  "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(entry.title)
        .onChange(of: entry.id) {
            copied = false
        }
    }
}
