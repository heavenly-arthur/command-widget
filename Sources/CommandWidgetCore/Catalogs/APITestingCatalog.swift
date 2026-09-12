enum APITestingCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .apiTesting, tags, summary,
            "\(summary) Используйте тестовое окружение и не помещайте секреты непосредственно в командную строку.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Запустить Postman-коллекцию", "newman run <collection.json>", ["newman", "postman", "collection"], "Выполняет Postman-коллекцию из CLI.", ["newman run tests/postman/collection.json"]),
        ("Коллекция с environment", "newman run <collection.json> --environment <environment.json>", ["newman", "environment"], "Подставляет переменные из Postman environment.", ["newman run collection.json --environment local.json"]),
        ("Коллекция с тестовыми данными", "newman run <collection.json> --iteration-data <data.json>", ["newman", "data", "iterations"], "Повторяет коллекцию для строк тестового набора данных.", ["newman run collection.json --iteration-data users.json"]),
        ("JUnit-отчёт Newman", "newman run <collection.json> --reporters cli,junit --reporter-junit-export <report.xml>", ["newman", "junit", "report"], "Создаёт консольный и JUnit-отчёты выполнения.", ["newman run collection.json --reporters cli,junit --reporter-junit-export reports/newman.xml"]),
        ("Запустить Hurl-тесты", "hurl --test <files...>", ["hurl", "http", "test"], "Выполняет HTTP-сценарии Hurl с assertions.", ["hurl --test tests/api/*.hurl"]),
        ("Hurl с переменными", "hurl --test --variables-file <variables.env> <file.hurl>", ["hurl", "variables"], "Передаёт сценарию Hurl значения из локального файла.", ["hurl --test --variables-file tests/local.env tests/health.hurl"]),
        ("Проверить OpenAPI", "schemathesis run <openapi-url>", ["schemathesis", "openapi", "property-testing"], "Генерирует проверки API по OpenAPI-схеме.", ["schemathesis run http://127.0.0.1:8080/openapi.json"]),
        ("Проверить gRPC-ответ", "grpcurl -plaintext -d '<json>' <host:port> <service/method>", ["grpcurl", "grpc", "smoke"], "Выполняет smoke-проверку выбранного gRPC-метода.", ["grpcurl -plaintext -d '{}' 127.0.0.1:9090 health.v1.Health/Check"])
    ]
}
