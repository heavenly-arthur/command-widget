enum UITestingCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .uiTesting, tags, summary,
            "\(summary) Перед запуском поднимите тестовое приложение и убедитесь, что base URL указывает на нужное окружение.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Один Playwright-тест", "npx playwright test <spec>", ["playwright", "spec"], "Запускает выбранный файл браузерных тестов.", ["npx playwright test tests/login.spec.ts"]),
        ("Playwright по проекту", "npx playwright test --project=<project>", ["playwright", "browser", "project"], "Запускает тесты только для указанного проекта браузера.", ["npx playwright test --project=chromium"]),
        ("Playwright с браузером", "npx playwright test --headed", ["playwright", "headed", "debug"], "Показывает окно браузера во время выполнения тестов.", ["npx playwright test --headed tests/checkout.spec.ts"]),
        ("Отладить Playwright", "npx playwright test --debug <spec>", ["playwright", "debug", "inspector"], "Открывает Playwright Inspector для пошаговой отладки.", ["npx playwright test --debug tests/login.spec.ts"]),
        ("Открыть Playwright trace", "npx playwright show-trace <trace.zip>", ["playwright", "trace", "report"], "Открывает сохранённую трассировку упавшего теста.", ["npx playwright show-trace test-results/login/trace.zip"]),
        ("Один Cypress spec", "npx cypress run --spec <spec>", ["cypress", "spec", "headless"], "Выполняет выбранный Cypress spec без интерактивного runner.", ["npx cypress run --spec 'cypress/e2e/login.cy.ts'"]),
        ("Cypress в выбранном браузере", "npx cypress run --browser <browser>", ["cypress", "browser"], "Запускает Cypress suite в указанном браузере.", ["npx cypress run --browser chrome"]),
        ("Запустить Selenium IDE suite", "selenium-side-runner <project.side>", ["selenium", "side", "runner"], "Выполняет экспортированный проект Selenium IDE из CLI.", ["selenium-side-runner tests/regression.side"])
    ]
}
