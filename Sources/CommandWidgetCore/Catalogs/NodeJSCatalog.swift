enum NodeJSCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .nodeJS, tags, summary,
            "\(summary) Команду запускайте из каталога проекта; доступность флагов зависит от установленной версии Node.js.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Версия Node.js", "node --version", ["version", "runtime"], "Показывает активную версию среды выполнения.", ["node --version"]),
        ("Запустить JavaScript-файл", "node <file.js>", ["run", "script"], "Выполняет JavaScript-файл через Node.js.", ["node server.js"]),
        ("Перезапуск при изменениях", "node --watch <file.js>", ["watch", "development"], "Перезапускает процесс после изменения импортированных файлов.", ["node --watch src/server.js"]),
        ("Запустить встроенные тесты", "node --test [pattern]", ["test", "runner"], "Запускает тесты через встроенный test runner Node.js.", ["node --test 'test/**/*.test.js'"]),
        ("Выполнить выражение", "node --eval '<javascript>'", ["eval", "snippet"], "Выполняет короткое JavaScript-выражение без отдельного файла.", ["node --eval 'console.log(process.platform)'"]),
        ("Загрузить переменные окружения", "node --env-file=<file> <script.js>", ["env", "configuration"], "Загружает переменные из env-файла перед запуском скрипта.", ["node --env-file=.env src/server.js"]),
        ("Запустить инспектор", "node --inspect <file.js>", ["inspect", "debug"], "Открывает порт отладчика для подключения DevTools.", ["node --inspect src/server.js"]),
        ("Проверить синтаксис", "node --check <file.js>", ["check", "syntax"], "Проверяет синтаксис файла без его выполнения.", ["node --check scripts/release.js"])
    ]
}
