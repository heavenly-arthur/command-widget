enum MattermostCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(title, command, .mattermost, tags, summary,
            "\(summary) Аргументы mmctl зависят от прав администратора; имена команд, команд и каналов задаются handle, а не display name.",
            examples, bundledVersion: 4)
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Войти на сервер", "mmctl auth login <server-url>", ["auth", "login"], "Сохраняет профиль подключения после интерактивной аутентификации.", ["mmctl auth login https://chat.example.com"]),
        ("Список подключений", "mmctl auth list", ["auth", "profiles"], "Показывает сохранённые серверы и активный профиль.", ["mmctl auth list"]),
        ("Выбрать подключение", "mmctl auth set <server-name>", ["auth", "profile"], "Делает сохранённый сервер активным для следующих команд.", ["mmctl auth set production"]),
        ("Статус сервера", "mmctl system status", ["system", "health"], "Запускает базовые проверки состояния Mattermost.", ["mmctl system status"]),
        ("Версия сервера", "mmctl version", ["version", "diagnostics"], "Показывает версии mmctl и подключённого сервера.", ["mmctl version"]),
        ("Список пользователей", "mmctl user list", ["user", "list"], "Показывает пользователей сервера постранично.", ["mmctl user list --page 0 --per-page 50"]),
        ("Найти пользователя", "mmctl user search <term>", ["user", "search"], "Ищет пользователей по имени, email или отображаемому имени.", ["mmctl user search alice"]),
        ("Создать пользователя", "mmctl user create --email <email> --username <username> --password '<password>'", ["user", "create"], "Создаёт локальную учётную запись пользователя.", ["mmctl user create --email alice@example.com --username alice --password 'ChangeMe!123'"]),
        ("Активировать пользователя", "mmctl user activate <user>", ["user", "activate"], "Возвращает деактивированному пользователю доступ.", ["mmctl user activate alice"]),
        ("Деактивировать пользователя", "mmctl user deactivate <user>", ["user", "deactivate"], "Запрещает пользователю вход без удаления его данных.", ["mmctl user deactivate former.employee"]),
        ("Сбросить пароль", "mmctl user change-password <user> --password '<password>'", ["user", "password"], "Задаёт пользователю новый пароль.", ["mmctl user change-password alice --password 'NewSecret!456'"]),
        ("Список команд", "mmctl team list", ["team", "list"], "Показывает доступные рабочие команды Mattermost.", ["mmctl team list"]),
        ("Создать команду", "mmctl team create --name <name> --display-name '<display-name>'", ["team", "create"], "Создаёт новую рабочую команду.", ["mmctl team create --name platform --display-name 'Platform Team'"]),
        ("Добавить в команду", "mmctl team users add <team> <users...>", ["team", "user", "add"], "Добавляет одного или нескольких пользователей в команду.", ["mmctl team users add platform alice bob@example.com"]),
        ("Список каналов", "mmctl channel list <team>", ["channel", "list"], "Показывает каналы указанной команды.", ["mmctl channel list platform"]),
        ("Создать канал", "mmctl channel create --team <team> --name <name> --display-name '<display-name>'", ["channel", "create"], "Создаёт публичный канал в выбранной команде.", ["mmctl channel create --team platform --name alerts --display-name 'Alerts'"]),
        ("Добавить в канал", "mmctl channel add <team>:<channel> <users...>", ["channel", "user", "add"], "Добавляет пользователей в канал.", ["mmctl channel add platform:alerts alice bob"]),
        ("Создать сообщение", "mmctl post create <team>:<channel> --message '<message>'", ["post", "create"], "Публикует сообщение в указанном канале.", ["mmctl post create platform:alerts --message 'Deployment completed'"]),
        ("Список плагинов", "mmctl plugin list", ["plugin", "list"], "Показывает установленные плагины и их состояние.", ["mmctl plugin list"]),
        ("Включить плагин", "mmctl plugin enable <plugin-id>", ["plugin", "enable"], "Активирует установленный плагин.", ["mmctl plugin enable com.mattermost.calls"])
    ]
}
