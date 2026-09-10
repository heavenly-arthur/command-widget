enum GitCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(title, command, .git, tags, summary,
            "\(summary) Проверьте текущую ветку и выбранные пути; команды, меняющие историю или файлы, применяйте осознанно.",
            examples, bundledVersion: 4)
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Состояние репозитория", "git status --short --branch", ["status", "working-tree"], "Кратко показывает ветку и изменения рабочей копии.", ["git status --short --branch"]),
        ("Создать репозиторий", "git init <path>", ["init", "repository"], "Инициализирует Git-репозиторий в каталоге.", ["git init ./service"]),
        ("Клонировать репозиторий", "git clone <url> [directory]", ["clone", "remote"], "Создаёт локальную копию удалённого репозитория.", ["git clone https://github.com/org/project.git project"]),
        ("Добавить изменения", "git add <path>", ["add", "staging"], "Помещает выбранные изменения в индекс.", ["git add Sources/App.swift"]),
        ("Интерактивный индекс", "git add -p", ["add", "patch"], "Позволяет выбрать отдельные фрагменты для следующего коммита.", ["git add -p"]),
        ("Создать коммит", "git commit -m '<message>'", ["commit", "history"], "Создаёт коммит из содержимого индекса.", ["git commit -m 'Add health endpoint'"]),
        ("История одной строкой", "git log --oneline --graph --decorate --all", ["log", "history"], "Показывает компактный граф истории и ссылки.", ["git log --oneline --graph --decorate --all -20"]),
        ("Разница рабочей копии", "git diff", ["diff", "working-tree"], "Показывает неиндексированные изменения.", ["git diff -- Sources/App.swift"]),
        ("Разница индекса", "git diff --staged", ["diff", "staging"], "Показывает изменения, подготовленные к коммиту.", ["git diff --staged"]),
        ("Список веток", "git branch --all", ["branch", "list"], "Показывает локальные и remote-tracking ветки.", ["git branch --all"]),
        ("Создать и перейти", "git switch -c <branch>", ["branch", "switch"], "Создаёт новую ветку от текущего коммита и переключается на неё.", ["git switch -c feature/search"]),
        ("Переключить ветку", "git switch <branch>", ["branch", "switch"], "Переключает рабочую копию на существующую ветку.", ["git switch main"]),
        ("Получить remote-ссылки", "git fetch --all --prune", ["fetch", "remote"], "Обновляет remote-tracking ветки и удаляет устаревшие ссылки.", ["git fetch --all --prune"]),
        ("Подтянуть изменения", "git pull --ff-only", ["pull", "remote"], "Обновляет ветку только безопасным fast-forward.", ["git pull --ff-only origin main"]),
        ("Отправить ветку", "git push -u origin <branch>", ["push", "remote"], "Публикует ветку и настраивает upstream.", ["git push -u origin feature/search"]),
        ("Временно убрать изменения", "git stash push -m '<message>'", ["stash", "working-tree"], "Сохраняет незакоммиченные изменения во временный стек.", ["git stash push -m 'WIP search'"]),
        ("Вернуть stash", "git stash pop", ["stash", "restore"], "Применяет последний stash и удаляет его из стека при успехе.", ["git stash pop"]),
        ("Перенести коммит", "git cherry-pick <commit>", ["cherry-pick", "commit"], "Применяет изменение выбранного коммита поверх текущей ветки.", ["git cherry-pick a1b2c3d"]),
        ("Найти автора строки", "git blame <file>", ["blame", "history"], "Показывает последний коммит и автора для каждой строки файла.", ["git blame -L 20,40 Sources/App.swift"]),
        ("Найти потерянные действия", "git reflog", ["reflog", "recovery"], "Показывает локальную историю перемещений HEAD для восстановления.", ["git reflog --date=local -20"])
    ]
}
