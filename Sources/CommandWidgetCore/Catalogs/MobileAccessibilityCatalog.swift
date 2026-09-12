enum MobileAccessibilityCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .mobileAccessibility, tags, summary,
            "\(summary) Команды мобильных устройств выполняйте на тестовом эмуляторе, а accessibility-проверки — на разрешённом URL.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Список Android-устройств", "adb devices -l", ["adb", "android", "devices"], "Показывает подключённые устройства и эмуляторы Android.", ["adb devices -l"]),
        ("Android logcat", "adb logcat", ["adb", "android", "logs"], "Выводит системные и приложенческие логи Android в реальном времени.", ["adb logcat '*:S' MyApp:D"]),
        ("Список Apple-симуляторов", "xcrun simctl list devices", ["simctl", "ios", "devices"], "Показывает доступные и запущенные симуляторы Apple.", ["xcrun simctl list devices available"]),
        ("Снимок iOS Simulator", "xcrun simctl io booted screenshot <output.png>", ["simctl", "ios", "screenshot"], "Сохраняет скриншот активного симулятора.", ["xcrun simctl io booted screenshot artifacts/home.png"]),
        ("Accessibility-аудит Lighthouse", "npx lighthouse <url> --only-categories=accessibility", ["lighthouse", "accessibility", "audit"], "Формирует Lighthouse-оценку доступности страницы.", ["npx lighthouse http://127.0.0.1:3000 --only-categories=accessibility"]),
        ("Проверка axe", "npx @axe-core/cli <url>", ["axe", "accessibility", "wcag"], "Проверяет страницу правилами axe-core из CLI.", ["npx @axe-core/cli http://127.0.0.1:3000"]),
        ("Проверка Pa11y", "pa11y <url>", ["pa11y", "accessibility", "wcag"], "Запускает accessibility-проверку страницы через Pa11y.", ["pa11y http://127.0.0.1:3000 --standard WCAG2AA"]),
        ("Pa11y по конфигурации", "pa11y-ci --config <config.json>", ["pa11y", "ci", "config"], "Проверяет набор URL по локальной конфигурации Pa11y CI.", ["pa11y-ci --config tests/accessibility/pa11y.json"])
    ]
}
