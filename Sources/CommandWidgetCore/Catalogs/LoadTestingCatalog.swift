enum LoadTestingCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .loadTesting, tags, summary,
            "\(summary) Нагрузку направляйте только на разрешённое тестовое окружение и заранее задавайте безопасные лимиты.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Запустить k6-сценарий", "k6 run <script.js>", ["k6", "run"], "Выполняет локальный сценарий нагрузочного тестирования k6.", ["k6 run tests/load/smoke.js"]),
        ("Фиксированные VU в k6", "k6 run --vus <count> --duration <duration> <script.js>", ["k6", "vus", "duration"], "Запускает заданное число виртуальных пользователей на ограниченное время.", ["k6 run --vus 10 --duration 30s tests/load/api.js"]),
        ("Передать переменную в k6", "k6 run -e <NAME=value> <script.js>", ["k6", "environment"], "Передаёт несекретный параметр в k6-сценарий.", ["k6 run -e BASE_URL=http://127.0.0.1:8080 tests/load/api.js"]),
        ("Проверить k6-сценарий", "k6 inspect <script.js>", ["k6", "inspect"], "Показывает итоговые execution options без генерации нагрузки.", ["k6 inspect tests/load/api.js"]),
        ("Запустить Artillery", "artillery run <config.yml>", ["artillery", "run"], "Выполняет нагрузочный сценарий Artillery.", ["artillery run tests/load/artillery.yml"]),
        ("Отчёт Artillery", "artillery run --output <report.json> <config.yml>", ["artillery", "report", "json"], "Сохраняет результаты Artillery в JSON для анализа.", ["artillery run --output reports/load.json tests/load/artillery.yml"]),
        ("HTTP benchmark через wrk", "wrk -t<threads> -c<connections> -d<duration> <url>", ["wrk", "http", "benchmark"], "Создаёт ограниченную HTTP-нагрузку через wrk.", ["wrk -t2 -c20 -d15s http://127.0.0.1:8080/health"]),
        ("HTTP benchmark через ab", "ab -n <requests> -c <concurrency> <url>", ["ab", "apache", "benchmark"], "Отправляет заданное число HTTP-запросов с ограниченным параллелизмом.", ["ab -n 100 -c 5 http://127.0.0.1:8080/health"])
    ]
}
