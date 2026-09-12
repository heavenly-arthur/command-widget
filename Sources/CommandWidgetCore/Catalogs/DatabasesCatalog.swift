enum DatabasesCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .databases, tags, summary,
            "\(summary) Перед изменяющими запросами перепроверьте окружение, базу и права подключения.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Подключиться к PostgreSQL", "psql '<connection-url>'", ["postgresql", "connect"], "Открывает интерактивную сессию PostgreSQL.", ["psql 'postgresql://localhost/app_dev'"]),
        ("Список баз PostgreSQL", "psql '<connection-url>' -c '\\l'", ["postgresql", "list"], "Показывает доступные базы данных PostgreSQL.", ["psql 'postgresql://localhost/postgres' -c '\\l'"]),
        ("Структура таблицы", "psql '<connection-url>' -c '\\d <table>'", ["postgresql", "schema"], "Показывает столбцы, индексы и ограничения таблицы.", ["psql 'postgresql://localhost/app_dev' -c '\\d users'"]),
        ("Резервная копия PostgreSQL", "pg_dump '<connection-url>' --format=custom --file=<backup.dump>", ["postgresql", "backup"], "Создаёт архивную резервную копию базы PostgreSQL.", ["pg_dump 'postgresql://localhost/app' --format=custom --file=app.dump"]),
        ("Открыть SQLite", "sqlite3 <database.sqlite>", ["sqlite", "connect"], "Открывает локальную SQLite-базу в интерактивной оболочке.", ["sqlite3 var/app.sqlite"]),
        ("Подключиться к MySQL", "mysql --host=<host> --user=<user> --password <database>", ["mysql", "connect"], "Открывает сессию MySQL и запрашивает пароль безопасно.", ["mysql --host=127.0.0.1 --user=app --password app_dev"]),
        ("Проверить Redis", "redis-cli -u '<redis-url>' PING", ["redis", "health"], "Проверяет доступность Redis командой PING.", ["redis-cli -u 'redis://127.0.0.1:6379/0' PING"]),
        ("Подключиться к MongoDB", "mongosh '<mongodb-url>'", ["mongodb", "connect"], "Открывает интерактивную оболочку MongoDB.", ["mongosh 'mongodb://127.0.0.1:27017/app_dev'"])
    ]
}
