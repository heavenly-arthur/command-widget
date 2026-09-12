enum TypeScriptCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .typescript, tags, summary,
            "\(summary) Используется локальная версия TypeScript из проекта; перед запуском проверьте выбранный tsconfig.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Проверить типы", "npx tsc --noEmit", ["types", "check"], "Проверяет типы, не создавая JavaScript-файлы.", ["npx tsc --noEmit"]),
        ("Создать tsconfig", "npx tsc --init", ["init", "config"], "Создаёт начальный файл конфигурации TypeScript.", ["npx tsc --init"]),
        ("Собрать проект", "npx tsc --project <tsconfig.json>", ["build", "project"], "Компилирует проект по указанной конфигурации.", ["npx tsc --project tsconfig.build.json"]),
        ("Следить за изменениями", "npx tsc --watch --noEmit", ["watch", "types"], "Повторяет проверку типов при изменении файлов.", ["npx tsc --watch --noEmit"]),
        ("Показать итоговую конфигурацию", "npx tsc --showConfig", ["config", "diagnostics"], "Выводит конфигурацию после применения extends и значений по умолчанию.", ["npx tsc --showConfig"]),
        ("Диагностика поиска модулей", "npx tsc --traceResolution", ["modules", "diagnostics"], "Показывает, как TypeScript разрешает импорты и типы.", ["npx tsc --noEmit --traceResolution"]),
        ("Запустить TypeScript-файл", "npx tsx <file.ts>", ["tsx", "run"], "Выполняет TypeScript-файл без отдельного этапа сборки.", ["npx tsx scripts/seed.ts"]),
        ("Создать декларации типов", "npx tsc --declaration --emitDeclarationOnly", ["declaration", "library"], "Генерирует только файлы деклараций d.ts.", ["npx tsc --project tsconfig.build.json --declaration --emitDeclarationOnly"])
    ]
}
