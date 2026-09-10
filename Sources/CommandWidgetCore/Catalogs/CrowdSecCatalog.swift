enum CrowdSecCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(title, command, .crowdsec, tags, summary,
            "\(summary) Для административных операций обычно нужен sudo; перед удалением или блокировкой проверьте выбранный объект.",
            examples, bundledVersion: 4)
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Сводные метрики", "sudo cscli metrics", ["metrics", "diagnostics"], "Показывает обработанные строки, сценарии, парсеры и решения.", ["sudo cscli metrics"]),
        ("Список решений", "sudo cscli decisions list", ["decisions", "ban"], "Показывает действующие решения о блокировке.", ["sudo cscli decisions list -i 203.0.113.10"]),
        ("Добавить блокировку IP", "sudo cscli decisions add --ip <ip> --duration <duration> --reason '<reason>'", ["decisions", "ban", "ip"], "Создаёт временное ручное решение для IP-адреса.", ["sudo cscli decisions add --ip 203.0.113.10 --duration 4h --reason 'manual test'"]),
        ("Удалить блокировку IP", "sudo cscli decisions delete --ip <ip>", ["decisions", "delete", "ip"], "Удаляет решения для указанного IP-адреса.", ["sudo cscli decisions delete --ip 203.0.113.10"]),
        ("Список алертов", "sudo cscli alerts list", ["alerts", "security"], "Показывает алерты, созданные сработавшими сценариями.", ["sudo cscli alerts list --since 24h"]),
        ("Изучить алерт", "sudo cscli alerts inspect <alert-id>", ["alerts", "inspect"], "Выводит события и метаданные конкретного алерта.", ["sudo cscli alerts inspect 42"]),
        ("Удалить алерт", "sudo cscli alerts delete <alert-id>", ["alerts", "delete"], "Удаляет выбранный алерт из Local API.", ["sudo cscli alerts delete 42"]),
        ("Список сценариев", "sudo cscli scenarios list", ["hub", "scenarios"], "Показывает установленные и доступные сценарии обнаружения.", ["sudo cscli scenarios list"]),
        ("Установить сценарий", "sudo cscli scenarios install <author/name>", ["hub", "scenarios", "install"], "Устанавливает сценарий из CrowdSec Hub.", ["sudo cscli scenarios install crowdsecurity/ssh-bf"]),
        ("Удалить сценарий", "sudo cscli scenarios remove <author/name>", ["hub", "scenarios", "remove"], "Удаляет установленный сценарий.", ["sudo cscli scenarios remove crowdsecurity/ssh-bf"]),
        ("Список коллекций", "sudo cscli collections list", ["hub", "collections"], "Показывает наборы парсеров и сценариев.", ["sudo cscli collections list"]),
        ("Установить коллекцию", "sudo cscli collections install <author/name>", ["hub", "collections", "install"], "Устанавливает коллекцию для выбранного сервиса.", ["sudo cscli collections install crowdsecurity/nginx"]),
        ("Список парсеров", "sudo cscli parsers list", ["hub", "parsers"], "Показывает установленные парсеры журналов.", ["sudo cscli parsers list"]),
        ("Обновить индекс Hub", "sudo cscli hub update", ["hub", "update"], "Загружает свежий индекс компонентов CrowdSec Hub.", ["sudo cscli hub update"]),
        ("Обновить компоненты Hub", "sudo cscli hub upgrade", ["hub", "upgrade"], "Обновляет установленные компоненты до доступных версий.", ["sudo cscli hub upgrade"]),
        ("Список машин", "sudo cscli machines list", ["lapi", "machines"], "Показывает агентов, зарегистрированных в Local API.", ["sudo cscli machines list"]),
        ("Добавить машину", "sudo cscli machines add <name> --auto", ["lapi", "machines", "add"], "Регистрирует новую машину и автоматически создаёт учётные данные.", ["sudo cscli machines add edge-agent --auto"]),
        ("Список bouncer", "sudo cscli bouncers list", ["lapi", "bouncers"], "Показывает remediation-компоненты и время их последнего обращения.", ["sudo cscli bouncers list"]),
        ("Добавить bouncer", "sudo cscli bouncers add <name>", ["lapi", "bouncers", "add"], "Регистрирует bouncer и один раз выводит его API-ключ.", ["sudo cscli bouncers add firewall-bouncer"]),
        ("Удалить bouncer", "sudo cscli bouncers delete <name>", ["lapi", "bouncers", "delete"], "Отзывает доступ выбранного bouncer к Local API.", ["sudo cscli bouncers delete old-firewall-bouncer"])
    ]
}
