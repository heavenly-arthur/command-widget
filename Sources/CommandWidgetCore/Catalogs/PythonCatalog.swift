enum PythonCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .python, tags, summary,
            "\(summary) Используйте виртуальное окружение проекта и проверьте активную версию интерпретатора.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Версия Python", "python3 --version", ["version", "runtime"], "Показывает активную версию Python.", ["python3 --version"]),
        ("Запустить модуль", "python3 -m <module> [args]", ["module", "run"], "Запускает установленный модуль как программу.", ["python3 -m http.server 8000"]),
        ("Создать venv", "python3 -m venv <directory>", ["venv", "environment"], "Создаёт изолированное виртуальное окружение.", ["python3 -m venv .venv"]),
        ("Установить зависимости", "python3 -m pip install -r <requirements.txt>", ["pip", "install"], "Устанавливает зависимости из requirements-файла.", ["python3 -m pip install -r requirements.txt"]),
        ("Синхронизировать uv-проект", "uv sync --frozen", ["uv", "dependencies", "lockfile"], "Устанавливает зависимости uv без изменения lock-файла.", ["uv sync --frozen"]),
        ("Запустить через uv", "uv run <command>", ["uv", "run"], "Выполняет команду в окружении uv-проекта.", ["uv run python src/main.py"]),
        ("Проверить байткод", "python3 -m compileall <path>", ["compile", "syntax"], "Компилирует Python-файлы и обнаруживает синтаксические ошибки.", ["python3 -m compileall src"]),
        ("Показать путь модуля", "python3 -c 'import <module>; print(<module>.__file__)'", ["module", "diagnostics"], "Показывает файл, из которого импортируется модуль.", ["python3 -c 'import requests; print(requests.__file__)'"])
    ]
}
