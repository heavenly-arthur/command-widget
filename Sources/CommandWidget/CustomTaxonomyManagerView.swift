import CommandWidgetCore
import SwiftUI

struct CustomTaxonomyManagerView: View {
    @State private var draft: CustomCommandTaxonomy
    @State private var expandedCategories: Set<UUID> = []
    @State private var editor: TaxonomyEditor?
    @State private var deletionTarget: TaxonomyDeletionTarget?
    @State private var mutationError: String?

    let onCancel: () -> Void
    let onSave: (CustomCommandTaxonomy) -> Bool

    init(
        taxonomy: CustomCommandTaxonomy,
        onCancel: @escaping () -> Void,
        onSave: @escaping (CustomCommandTaxonomy) -> Bool
    ) {
        _draft = State(initialValue: taxonomy)
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Мои категории")
                        .font(.title2.weight(.semibold))
                    Text("Создавайте собственные разделы и инструменты. Они хранятся только на этом Mac.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    editor = .newCategory
                } label: {
                    Label("Категория", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            GroupBox("Пользовательская таксономия") {
                if draft.categories.isEmpty {
                    ContentUnavailableView {
                        Label("Нет своих категорий", systemImage: "folder.badge.plus")
                    } description: {
                        Text("Добавьте категорию, а затем создайте внутри неё нужные подкатегории.")
                    } actions: {
                        Button("Добавить категорию") {
                            editor = .newCategory
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(draft.categories) { category in
                                categoryRow(category)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(minHeight: 280, maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)

            if let mutationError {
                Label(mutationError, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            HStack {
                Text("\(draft.categories.count) категорий · \(subcategoryCount) подкатегорий")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Отмена") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                Button("Сохранить") {
                    _ = onSave(draft)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
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
        .sheet(item: $editor) { editor in
            TaxonomyNameEditor(editor: editor) { title in
                commit(editor: editor, title: title)
            }
        }
        .alert(item: $deletionTarget) { target in
            Alert(
                title: Text(target.title),
                message: Text(target.message),
                primaryButton: .destructive(Text("Удалить")) {
                    delete(target)
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }

    private var subcategoryCount: Int {
        draft.categories.reduce(0) { $0 + $1.subcategories.count }
    }

    private func categoryRow(_ category: CustomCommandCategory) -> some View {
        DisclosureGroup(isExpanded: expansionBinding(category.id)) {
            VStack(alignment: .leading, spacing: 8) {
                if category.subcategories.isEmpty {
                    Text("Подкатегорий пока нет")
                        .foregroundStyle(.secondary)
                        .padding(.leading, 28)
                } else {
                    ForEach(category.subcategories) { subcategory in
                        HStack(spacing: 10) {
                            Toggle("", isOn: subcategoryEnabledBinding(
                                categoryID: category.id,
                                subcategoryID: subcategory.id
                            ))
                            .labelsHidden()
                            .toggleStyle(.checkbox)

                            Image(systemName: "terminal")
                                .foregroundStyle(.secondary)
                            Text(subcategory.title)
                            Spacer()
                            Menu {
                                Button("Переименовать") {
                                    editor = .renameSubcategory(
                                        categoryID: category.id,
                                        subcategoryID: subcategory.id,
                                        currentTitle: subcategory.title
                                    )
                                }
                                Button("Удалить", role: .destructive) {
                                    deletionTarget = .subcategory(
                                        categoryID: category.id,
                                        subcategoryID: subcategory.id,
                                        title: subcategory.title
                                    )
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .menuStyle(.borderlessButton)
                            .fixedSize()
                        }
                        .padding(.leading, 28)
                    }
                }

                Button {
                    editor = .newSubcategory(categoryID: category.id)
                } label: {
                    Label("Добавить подкатегорию", systemImage: "plus")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .padding(.leading, 28)
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        } label: {
            HStack(spacing: 10) {
                Toggle("", isOn: categoryEnabledBinding(category.id))
                    .labelsHidden()
                    .toggleStyle(.checkbox)
                Image(systemName: "folder")
                    .foregroundStyle(.secondary)
                Text(category.title)
                    .font(.headline)
                Spacer()
                Text("\(category.subcategories.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Menu {
                    Button("Переименовать") {
                        editor = .renameCategory(id: category.id, currentTitle: category.title)
                    }
                    Button("Удалить", role: .destructive) {
                        deletionTarget = .category(
                            id: category.id,
                            title: category.title,
                            subcategoryCount: category.subcategories.count
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
    }

    private func expansionBinding(_ id: UUID) -> Binding<Bool> {
        Binding(
            get: { expandedCategories.contains(id) },
            set: { isExpanded in
                if isExpanded {
                    expandedCategories.insert(id)
                } else {
                    expandedCategories.remove(id)
                }
            }
        )
    }

    private func categoryEnabledBinding(_ id: UUID) -> Binding<Bool> {
        Binding(
            get: { draft.categories.first(where: { $0.id == id })?.isEnabled ?? false },
            set: { isEnabled in
                do {
                    try draft.setCategoryEnabled(id: id, isEnabled: isEnabled)
                    mutationError = nil
                } catch {
                    mutationError = error.localizedDescription
                }
            }
        )
    }

    private func subcategoryEnabledBinding(
        categoryID: UUID,
        subcategoryID: UUID
    ) -> Binding<Bool> {
        Binding(
            get: {
                draft.categories
                    .first(where: { $0.id == categoryID })?
                    .subcategories
                    .first(where: { $0.id == subcategoryID })?
                    .isEnabled ?? false
            },
            set: { isEnabled in
                do {
                    try draft.setSubcategoryEnabled(
                        categoryID: categoryID,
                        subcategoryID: subcategoryID,
                        isEnabled: isEnabled
                    )
                    mutationError = nil
                } catch {
                    mutationError = error.localizedDescription
                }
            }
        )
    }

    private func commit(editor: TaxonomyEditor, title: String) -> String? {
        do {
            switch editor {
            case .newCategory:
                let id = try draft.addCategory(title: title)
                expandedCategories.insert(id)
            case let .renameCategory(id, _):
                try draft.renameCategory(id: id, title: title)
            case let .newSubcategory(categoryID):
                _ = try draft.addSubcategory(categoryID: categoryID, title: title)
                expandedCategories.insert(categoryID)
            case let .renameSubcategory(categoryID, subcategoryID, _):
                try draft.renameSubcategory(
                    categoryID: categoryID,
                    subcategoryID: subcategoryID,
                    title: title
                )
            }
            mutationError = nil
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    private func delete(_ target: TaxonomyDeletionTarget) {
        do {
            switch target {
            case let .category(id, _, _):
                try draft.removeCategory(id: id)
                expandedCategories.remove(id)
            case let .subcategory(categoryID, subcategoryID, _):
                try draft.removeSubcategory(
                    categoryID: categoryID,
                    subcategoryID: subcategoryID
                )
            }
            mutationError = nil
        } catch {
            mutationError = error.localizedDescription
        }
    }
}

private enum TaxonomyEditor: Identifiable {
    case newCategory
    case renameCategory(id: UUID, currentTitle: String)
    case newSubcategory(categoryID: UUID)
    case renameSubcategory(categoryID: UUID, subcategoryID: UUID, currentTitle: String)

    var id: String {
        switch self {
        case .newCategory:
            return "new-category"
        case let .renameCategory(id, _):
            return "rename-category-\(id)"
        case let .newSubcategory(categoryID):
            return "new-subcategory-\(categoryID)"
        case let .renameSubcategory(_, subcategoryID, _):
            return "rename-subcategory-\(subcategoryID)"
        }
    }

    var heading: String {
        switch self {
        case .newCategory: return "Новая категория"
        case .renameCategory: return "Переименовать категорию"
        case .newSubcategory: return "Новая подкатегория"
        case .renameSubcategory: return "Переименовать подкатегорию"
        }
    }

    var fieldLabel: String {
        switch self {
        case .newCategory, .renameCategory: return "Название категории"
        case .newSubcategory, .renameSubcategory: return "Название подкатегории"
        }
    }

    var initialTitle: String {
        switch self {
        case .newCategory, .newSubcategory:
            return ""
        case let .renameCategory(_, currentTitle),
             let .renameSubcategory(_, _, currentTitle):
            return currentTitle
        }
    }
}

private struct TaxonomyNameEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var errorMessage: String?

    let editor: TaxonomyEditor
    let onCommit: (String) -> String?

    init(editor: TaxonomyEditor, onCommit: @escaping (String) -> String?) {
        self.editor = editor
        self.onCommit = onCommit
        _title = State(initialValue: editor.initialTitle)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editor.heading)
                .font(.title3.weight(.semibold))

            TextField(editor.fieldLabel, text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit(commit)

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            Spacer()

            HStack {
                Spacer()
                Button("Отмена") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Сохранить") {
                    commit()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 440, height: 190)
    }

    private func commit() {
        if let error = onCommit(title) {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}

private enum TaxonomyDeletionTarget: Identifiable {
    case category(id: UUID, title: String, subcategoryCount: Int)
    case subcategory(categoryID: UUID, subcategoryID: UUID, title: String)

    var id: String {
        switch self {
        case let .category(id, _, _): return "category-\(id)"
        case let .subcategory(_, id, _): return "subcategory-\(id)"
        }
    }

    var title: String {
        switch self {
        case .category: return "Удалить категорию?"
        case .subcategory: return "Удалить подкатегорию?"
        }
    }

    var message: String {
        switch self {
        case let .category(_, title, count):
            if count == 0 {
                return "Категория «\(title)» будет удалена."
            }
            return "Категория «\(title)» и все её подкатегории (\(count)) будут удалены."
        case let .subcategory(_, _, title):
            return "Подкатегория «\(title)» будет удалена."
        }
    }
}
