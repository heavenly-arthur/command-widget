import AppKit
import CommandWidgetCore
import SwiftUI

struct CommandLibraryView: View {
    @ObservedObject var viewModel: CommandLibraryViewModel
    @State private var expandedCategories: Set<CommandCategory> = []

    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedID) {
                ForEach(CommandCategory.allCases) { category in
                    Section {
                        if expandedCategories.contains(category) {
                            let categoryEntries = viewModel.entries(in: category)
                            ForEach(Array(categoryEntries.enumerated()), id: \.element.id) { index, entry in
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
                                .padding(.vertical, 3)
                                .tag(entry.id)
                                .moveDisabled(!viewModel.query.isEmpty)
                            }
                            .onMove { source, destination in
                                viewModel.move(in: category, from: source, to: destination)
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
                } else {
                    expandedCategories = Set(
                        CommandCategory.allCases.filter { !viewModel.entries(in: $0).isEmpty }
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
}

private struct CommandDetailView: View {
    let entry: CommandEntry
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.category.rawValue.uppercased())
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
