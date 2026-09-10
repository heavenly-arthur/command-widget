enum OllamaCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(title, command, .ollama, tags, summary,
            "\(summary) Значения в угловых скобках замените своими; перед автоматизацией проверьте результат локально.",
            examples, bundledVersion: 4)
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Запустить модель", "ollama run <model>", ["run", "chat"], "Запускает интерактивный диалог с локальной моделью.", ["ollama run llama3.2"]),
        ("Запустить с запросом", "ollama run <model> '<prompt>'", ["run", "prompt"], "Отправляет модели один запрос из командной строки.", ["ollama run llama3.2 'Объясни DNS простыми словами'"]),
        ("Скачать модель", "ollama pull <model>", ["pull", "model"], "Скачивает модель или обновляет её локальную копию.", ["ollama pull qwen2.5:7b"]),
        ("Список моделей", "ollama list", ["list", "models"], "Показывает установленные модели, размер и дату изменения.", ["ollama list"]),
        ("Удалить модель", "ollama rm <model>", ["remove", "disk"], "Удаляет локальные файлы выбранной модели.", ["ollama rm qwen2.5:7b"]),
        ("Скопировать модель", "ollama cp <source> <destination>", ["copy", "model"], "Создаёт локальную копию модели под новым именем.", ["ollama cp llama3.2 my-assistant"]),
        ("Информация о модели", "ollama show <model>", ["show", "metadata"], "Показывает шаблон, параметры и метаданные модели.", ["ollama show llama3.2"]),
        ("Показать Modelfile", "ollama show --modelfile <model>", ["show", "modelfile"], "Выводит Modelfile, из которого можно сделать производную модель.", ["ollama show --modelfile llama3.2"]),
        ("Создать модель", "ollama create <model> -f <Modelfile>", ["create", "modelfile"], "Создаёт модель по локальному Modelfile.", ["ollama create support-bot -f ./Modelfile"]),
        ("Запустить сервер", "ollama serve", ["serve", "api"], "Запускает локальный HTTP-сервис Ollama.", ["OLLAMA_HOST=127.0.0.1:11434 ollama serve"]),
        ("Активные модели", "ollama ps", ["ps", "memory"], "Показывает модели, загруженные в CPU или GPU-память.", ["ollama ps"]),
        ("Остановить модель", "ollama stop <model>", ["stop", "memory"], "Выгружает запущенную модель из памяти.", ["ollama stop llama3.2"]),
        ("Версия Ollama", "ollama --version", ["version", "diagnostics"], "Показывает установленную версию Ollama.", ["ollama --version"]),
        ("Справка команды", "ollama <command> --help", ["help", "cli"], "Показывает доступные флаги выбранной подкоманды.", ["ollama run --help"]),
        ("Запрос к API generate", "curl http://localhost:11434/api/generate -d '{\"model\":\"<model>\",\"prompt\":\"<prompt>\",\"stream\":false}'", ["api", "generate"], "Генерирует ответ через локальный API без потоковой выдачи.", ["curl http://localhost:11434/api/generate -d '{\"model\":\"llama3.2\",\"prompt\":\"Why is the sky blue?\",\"stream\":false}'"]),
        ("Чат через API", "curl http://localhost:11434/api/chat -d '{\"model\":\"<model>\",\"messages\":[{\"role\":\"user\",\"content\":\"<message>\"}],\"stream\":false}'", ["api", "chat"], "Отправляет историю сообщений в локальный chat API.", ["curl http://localhost:11434/api/chat -d '{\"model\":\"llama3.2\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"stream\":false}'"]),
        ("Список моделей через API", "curl http://localhost:11434/api/tags", ["api", "tags"], "Возвращает JSON со списком локальных моделей.", ["curl -s http://localhost:11434/api/tags | jq ."]),
        ("Состояние API", "curl http://localhost:11434/api/ps", ["api", "ps"], "Возвращает сведения о загруженных моделях через API.", ["curl -s http://localhost:11434/api/ps | jq ."]),
        ("Создать embeddings", "curl http://localhost:11434/api/embed -d '{\"model\":\"<model>\",\"input\":\"<text>\"}'", ["api", "embed"], "Получает векторное представление текста от embedding-модели.", ["curl http://localhost:11434/api/embed -d '{\"model\":\"nomic-embed-text\",\"input\":\"Документ для поиска\"}'"]),
        ("Задать контекст Modelfile", "printf 'FROM <base>\\nSYSTEM <instruction>\\n' > Modelfile", ["modelfile", "system"], "Создаёт минимальный Modelfile с базовой моделью и системной инструкцией.", ["printf 'FROM llama3.2\\nSYSTEM Ты краткий помощник.\\n' > Modelfile\nollama create concise -f Modelfile"])
    ]
}
