# Наполнение встроенного каталога

Каждая категория принадлежит отдельному файлу:

| Категория | Файл |
|---|---|
| Kubernetes | `Sources/CommandWidgetCore/Catalogs/KubernetesCatalog.swift` |
| Helm | `Sources/CommandWidgetCore/Catalogs/HelmCatalog.swift` |
| Flux | `Sources/CommandWidgetCore/Catalogs/FluxCatalog.swift` |
| Linux | `Sources/CommandWidgetCore/Catalogs/LinuxCatalog.swift` |
| Ansible | `Sources/CommandWidgetCore/Catalogs/AnsibleCatalog.swift` |
| Terraform | `Sources/CommandWidgetCore/Catalogs/TerraformCatalog.swift` |
| Ollama | `Sources/CommandWidgetCore/Catalogs/OllamaCatalog.swift` |
| CrowdSec | `Sources/CommandWidgetCore/Catalogs/CrowdSecCatalog.swift` |
| Mattermost | `Sources/CommandWidgetCore/Catalogs/MattermostCatalog.swift` |
| Git | `Sources/CommandWidgetCore/Catalogs/GitCatalog.swift` |
| Node.js | `Sources/CommandWidgetCore/Catalogs/NodeJSCatalog.swift` |
| TypeScript | `Sources/CommandWidgetCore/Catalogs/TypeScriptCatalog.swift` |
| Frontend Tooling | `Sources/CommandWidgetCore/Catalogs/FrontendToolingCatalog.swift` |
| Frontend Testing | `Sources/CommandWidgetCore/Catalogs/FrontendTestingCatalog.swift` |
| Python | `Sources/CommandWidgetCore/Catalogs/PythonCatalog.swift` |
| Go | `Sources/CommandWidgetCore/Catalogs/GoCatalog.swift` |
| Databases | `Sources/CommandWidgetCore/Catalogs/DatabasesCatalog.swift` |
| API & gRPC | `Sources/CommandWidgetCore/Catalogs/APIAndGRPCCatalog.swift` |
| API Testing | `Sources/CommandWidgetCore/Catalogs/APITestingCatalog.swift` |
| UI Testing | `Sources/CommandWidgetCore/Catalogs/UITestingCatalog.swift` |
| Load Testing | `Sources/CommandWidgetCore/Catalogs/LoadTestingCatalog.swift` |
| Mobile & Accessibility | `Sources/CommandWidgetCore/Catalogs/MobileAccessibilityCatalog.swift` |

## Контракт записи

Новая запись создаётся через `BundledCatalogEntry.make` и должна содержать:

1. Короткое уникальное название.
2. Безопасный шаблон команды с placeholders в угловых скобках.
3. Категорию, совпадающую с файлом.
4. Поисковые теги.
5. Одно предложение краткого назначения.
6. Подробное объяснение поведения, важных флагов, ограничений и рисков.
7. Хотя бы один реалистичный пример.
8. `bundledVersion`, равный версии релиза каталога, в котором запись впервые появилась.

## Правила миграции

- Уже выпущенным записям нельзя менять `category`, `title` или первоначальный `bundledVersion`: эти поля участвуют в стабильной идентичности и миграции.
- Текст команды, теги, объяснение и примеры можно улучшать в исходном каталоге, но существующий пользовательский JSON намеренно не перезаписывается автоматически.
- При добавлении записей для следующего релиза один интегрирующий агент увеличивает `StarterCatalog.currentVersion`; агенты категорий используют это новое значение в `bundledVersion`.
- Не переиспользуйте старую версию для новых записей: существующая установка их не получит.
- Не редактируйте другие category-файлы в той же задаче без явной необходимости.

## Проверка задачи агента

Перед передачей результата:

```zsh
swift test --disable-sandbox
```

Обязательные инварианты тестов: уникальные ID, минимум одна команда и пример у каждой записи, корректная категория, отсутствие сетевых/AI-зависимостей, успешная миграция без восстановления удалённых записей.

## Пример задания небольшому агенту

> Расширь только `LinuxCatalog.swift` командами диагностики диска и сети. Для каждой записи добавь объяснение, риски и пример. Используй `bundledVersion: 3`, не меняй существующие записи и не редактируй другие категории. Запусти тесты и перечисли добавленные команды.
