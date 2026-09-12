enum FrontendToolingCatalog {
    static let entries: [CommandEntry] = specs.map { title, command, tags, summary, examples in
        BundledCatalogEntry.make(
            title, command, .frontendTooling, tags, summary,
            "\(summary) Запускайте команду в корне frontend-проекта и сверяйте имя script с package.json.",
            examples, bundledVersion: 5
        )
    }

    private static let specs: [(String, String, [String], String, [String])] = [
        ("Установить зависимости npm", "npm install", ["npm", "install"], "Устанавливает зависимости и обновляет lock-файл при необходимости.", ["npm install"]),
        ("Чистая установка npm", "npm ci", ["npm", "ci", "lockfile"], "Устанавливает точные версии из package-lock и очищает node_modules.", ["npm ci"]),
        ("Установить зависимости pnpm", "pnpm install --frozen-lockfile", ["pnpm", "install", "lockfile"], "Устанавливает зависимости без изменения lock-файла.", ["pnpm install --frozen-lockfile"]),
        ("Запустить dev-сервер", "npm run dev", ["dev", "server"], "Запускает локальный сценарий разработки проекта.", ["npm run dev"]),
        ("Собрать frontend", "npm run build", ["build", "production"], "Создаёт production-сборку через настроенный package script.", ["npm run build"]),
        ("Запустить Vite", "npx vite [root]", ["vite", "dev"], "Запускает Vite dev-сервер для выбранного корня.", ["npx vite --host 127.0.0.1"]),
        ("Предпросмотр Vite-сборки", "npx vite preview", ["vite", "preview"], "Локально показывает ранее созданную production-сборку.", ["npx vite preview --port 4173"]),
        ("Показать scripts", "npm pkg get scripts", ["npm", "scripts", "inspect"], "Выводит доступные package scripts без запуска.", ["npm pkg get scripts"])
    ]
}
