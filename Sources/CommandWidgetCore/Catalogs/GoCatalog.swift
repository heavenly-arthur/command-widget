enum GoCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .go, tags, summary,
            "\(summary) Запускайте команду внутри Go-модуля и проверяйте изменения go.mod и go.sum перед коммитом.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Версия Go", "go version", ["version", "runtime"], "Показывает установленную версию и целевую платформу Go.", ["go version"]),
        ("Запустить пакет", "go run <package>", ["run", "package"], "Компилирует и запускает указанный пакет без сохранения бинарника.", ["go run ./cmd/server"]),
        ("Собрать бинарник", "go build -o <output> <package>", ["build", "binary"], "Собирает исполняемый файл выбранного пакета.", ["go build -o ./bin/server ./cmd/server"]),
        ("Запустить тесты", "go test ./...", ["test", "all"], "Выполняет тесты всех пакетов текущего модуля.", ["go test -race ./..."]),
        ("Упорядочить зависимости", "go mod tidy", ["modules", "dependencies"], "Добавляет необходимые и удаляет неиспользуемые зависимости модуля.", ["go mod tidy"]),
        ("Показать зависимости", "go list -m all", ["modules", "list"], "Выводит основной модуль и выбранные версии зависимостей.", ["go list -m all"]),
        ("Статический анализ", "go vet ./...", ["vet", "lint"], "Ищет подозрительные конструкции во всех пакетах.", ["go vet ./..."]),
        ("Форматировать код", "gofmt -w <path>", ["format", "source"], "Форматирует Go-файлы на месте.", ["gofmt -w ./cmd ./internal"])
    ]
}
