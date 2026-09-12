enum FrontendTestingCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .frontendTesting, tags, summary,
            "\(summary) Команда использует конфигурацию и зависимости текущего frontend-проекта.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Vitest в watch-режиме", "npx vitest", ["vitest", "watch"], "Запускает быстрый цикл unit-тестов при разработке.", ["npx vitest src/components"]),
        ("Однократный запуск Vitest", "npx vitest run", ["vitest", "ci"], "Выполняет тесты один раз и завершает процесс.", ["npx vitest run --reporter=verbose"]),
        ("Покрытие Vitest", "npx vitest run --coverage", ["vitest", "coverage"], "Запускает тесты и формирует отчёт покрытия.", ["npx vitest run --coverage"]),
        ("Запустить Playwright", "npx playwright test", ["playwright", "e2e"], "Выполняет браузерные тесты Playwright.", ["npx playwright test tests/login.spec.ts"]),
        ("Playwright в UI-режиме", "npx playwright test --ui", ["playwright", "ui", "debug"], "Открывает интерактивный интерфейс запуска и отладки тестов.", ["npx playwright test --ui"]),
        ("Сгенерировать Playwright-сценарий", "npx playwright codegen <url>", ["playwright", "codegen"], "Записывает действия в браузере и предлагает код теста.", ["npx playwright codegen http://127.0.0.1:3000"]),
        ("Запустить Cypress без UI", "npx cypress run", ["cypress", "e2e", "ci"], "Выполняет Cypress-тесты в headless-режиме.", ["npx cypress run --browser chrome"]),
        ("Открыть Cypress", "npx cypress open", ["cypress", "ui", "debug"], "Открывает интерактивный Cypress runner.", ["npx cypress open --e2e"])
    ]
}
