import CryptoKit
import Foundation

public enum StarterCatalog {
    public static let currentVersion = 2
    public static let entries: [CommandEntry] = CommandOrdering.normalized(baseEntries + expandedEntries)

    private static let baseEntries: [CommandEntry] = [
        entry("Поды во всех namespace", "kubectl get pods -A", .kubernetes,
              ["pods", "list"], "Показывает все поды кластера.",
              "Флаг -A — сокращение для --all-namespaces. Полезно для быстрого обзора состояния workload во всём кластере.",
              ["kubectl get pods -A -o wide"]),
        entry("Логи контейнера", "kubectl logs -f <pod> -n <namespace>", .kubernetes,
              ["logs", "debug"], "Показывает и продолжает выводить логи пода.",
              "Флаг -f следит за новым выводом. Если в поде несколько контейнеров, добавьте -c <container>.",
              ["kubectl logs -f api-7d9c -n production -c api"]),
        entry("Обновить репозитории", "helm repo update", .helm,
              ["repo", "update"], "Обновляет локальный индекс Helm-репозиториев.",
              "Команда скачивает актуальные индексы уже добавленных репозиториев, но не обновляет установленные releases.",
              ["helm repo list\nhelm repo update"]),
        entry("История release", "helm history <release> -n <namespace>", .helm,
              ["release", "rollback"], "Показывает ревизии Helm release.",
              "В истории видны номера ревизий и их статусы. Номер можно передать в helm rollback.",
              ["helm history ingress-nginx -n ingress\nhelm rollback ingress-nginx 2 -n ingress"]),
        entry("Состояние Flux", "flux get all -A", .flux,
              ["status", "reconcile"], "Показывает состояние ресурсов Flux.",
              "Вывод объединяет основные Flux controllers и помогает найти suspended или not ready ресурсы.",
              ["flux get all -A --status-selector ready=false"]),
        entry("Принудительная сверка", "flux reconcile kustomization <name> -n <namespace> --with-source", .flux,
              ["reconcile", "kustomization"], "Запускает reconciliation немедленно.",
              "Флаг --with-source сначала обновляет связанный source, затем применяет Kustomization.",
              ["flux reconcile kustomization apps -n flux-system --with-source"]),
        entry("Занятое место", "du -sh ./* | sort -h", .linux,
              ["disk", "files"], "Сортирует элементы каталога по размеру.",
              "du вычисляет размер, -s суммирует каждый аргумент, -h выводит читаемые единицы. sort -h понимает эти единицы.",
              ["du -sh /var/log/* | sort -h"]),
        entry("Поиск текста", "grep -RIn --exclude-dir=.git '<text>' .", .linux,
              ["search", "grep"], "Рекурсивно ищет текст в файлах.",
              "-R следует по дереву, -I пропускает бинарные файлы, -n показывает строку. Значение в кавычках может содержать пробелы.",
              ["grep -RIn --exclude-dir=.git 'listen 443' /etc"]),
        entry("Проверить playbook", "ansible-playbook <playbook.yml> --check --diff", .ansible,
              ["check", "dry-run"], "Показывает предполагаемые изменения playbook.",
              "Check mode не гарантирует отсутствие побочных эффектов для модулей без полной поддержки check mode. --diff показывает изменения файлов.",
              ["ansible-playbook site.yml -i inventory --check --diff"]),
        entry("Ограничить hosts", "ansible-playbook <playbook.yml> --limit '<pattern>'", .ansible,
              ["limit", "hosts"], "Запускает playbook только для выбранных hosts.",
              "Pattern сопоставляется с inventory. Перед реальным запуском полезно проверить выбор через ansible --list-hosts.",
              ["ansible all -i inventory --list-hosts --limit 'web:&production'"]),
        entry("План изменений", "terraform plan -out=tfplan", .terraform,
              ["plan", "safe"], "Создаёт и сохраняет план Terraform.",
              "Сохранённый plan позволяет применить именно просмотренный набор изменений командой terraform apply tfplan.",
              ["terraform plan -out=tfplan\nterraform apply tfplan"]),
        entry("Форматирование конфигурации", "terraform fmt -recursive", .terraform,
              ["fmt", "hcl"], "Форматирует Terraform-файлы рекурсивно.",
              "Команда изменяет файлы на месте в канонический формат. Перед commit проверьте diff.",
              ["terraform fmt -check -recursive"])
    ]

    static func entry(
        _ title: String,
        _ command: String,
        _ category: CommandCategory,
        _ tags: [String],
        _ summary: String,
        _ details: String,
        _ examples: [String],
        bundledVersion: Int = 1
    ) -> CommandEntry {
        CommandEntry(
            id: stableID(for: "\(category.rawValue):\(title)", bundledVersion: bundledVersion),
            title: title,
            command: command,
            category: category,
            tags: tags,
            summary: summary,
            details: details,
            examples: examples,
            modifiedAt: Date(timeIntervalSince1970: 0),
            bundledVersion: bundledVersion
        )
    }

    private static func stableID(for value: String, bundledVersion: Int) -> UUID {
        if bundledVersion > 1 {
            return hashedStableID(for: value)
        }

        var bytes = Array(value.utf8.prefix(16))
        bytes.append(contentsOf: repeatElement(0, count: max(0, 16 - bytes.count)))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }

    private static func hashedStableID(for value: String) -> UUID {
        var bytes = Array(SHA256.hash(data: Data(value.utf8)).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}
