enum APIAndGRPCCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .apiAndGRPC, tags, summary,
            "\(summary) Подставьте локальный или разрешённый endpoint; токены не сохраняйте в истории shell.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("GET-запрос", "curl --fail-with-body --silent --show-error '<url>'", ["curl", "http", "get"], "Выполняет GET-запрос и показывает тело ошибки.", ["curl --fail-with-body --silent --show-error 'http://127.0.0.1:8080/health'"]),
        ("POST JSON", "curl --fail-with-body -X POST '<url>' -H 'Content-Type: application/json' -d '<json>'", ["curl", "http", "post", "json"], "Отправляет JSON-тело методом POST.", ["curl --fail-with-body -X POST 'http://127.0.0.1:8080/users' -H 'Content-Type: application/json' -d '{\"name\":\"Ada\"}'"]),
        ("Показать заголовки ответа", "curl --include '<url>'", ["curl", "headers", "diagnostics"], "Выводит статус и HTTP-заголовки вместе с телом.", ["curl --include 'http://127.0.0.1:8080/health'"]),
        ("Измерить время ответа", "curl --output /dev/null --silent --write-out '%{http_code} %{time_total}\\n' '<url>'", ["curl", "timing", "status"], "Показывает HTTP-код и общее время запроса.", ["curl --output /dev/null --silent --write-out '%{http_code} %{time_total}\\n' 'http://127.0.0.1:8080/health'"]),
        ("HTTPie GET", "http GET <url>", ["httpie", "http", "get"], "Выполняет читаемый HTTP-запрос через HTTPie.", ["http GET http://127.0.0.1:8080/health"]),
        ("Список gRPC-сервисов", "grpcurl -plaintext <host:port> list", ["grpc", "reflection", "list"], "Получает список сервисов через gRPC reflection.", ["grpcurl -plaintext 127.0.0.1:9090 list"]),
        ("Описание gRPC-сервиса", "grpcurl -plaintext <host:port> describe <service>", ["grpc", "describe"], "Показывает методы и типы выбранного gRPC-сервиса.", ["grpcurl -plaintext 127.0.0.1:9090 describe users.v1.UserService"]),
        ("Вызвать gRPC-метод", "grpcurl -plaintext -d '<json>' <host:port> <service/method>", ["grpc", "call", "json"], "Вызывает gRPC-метод с JSON-представлением сообщения.", ["grpcurl -plaintext -d '{\"id\":\"42\"}' 127.0.0.1:9090 users.v1.UserService/GetUser"])
    ]
}
