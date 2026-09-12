import Foundation

public struct CommandSubcategory: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: CommandCategory

    private init(_ id: String, _ title: String, _ category: CommandCategory) {
        self.id = id
        self.title = title
        self.category = category
    }

    public static let kubectl = Self("kubernetes.kubectl", "kubectl", .kubernetes)
    public static let helm = Self("helm.helm", "Helm CLI", .helm)
    public static let flux = Self("flux.flux", "Flux CLI", .flux)

    public static let linuxFiles = Self("linux.files", "Файлы и диски", .linux)
    public static let linuxSearch = Self("linux.search", "Поиск текста", .linux)
    public static let linuxNetwork = Self("linux.network", "Сеть", .linux)
    public static let linuxSystemd = Self("linux.systemd", "systemd", .linux)
    public static let linuxProcesses = Self("linux.processes", "Процессы", .linux)
    public static let linuxPermissions = Self("linux.permissions", "Права доступа", .linux)
    public static let linuxLogsArchives = Self("linux.logs-archives", "Логи и архивы", .linux)

    public static let ansiblePlaybooks = Self("ansible.playbooks", "Playbooks", .ansible)
    public static let ansibleInventory = Self("ansible.inventory", "Inventory и ad-hoc", .ansible)
    public static let ansibleVault = Self("ansible.vault", "Ansible Vault", .ansible)
    public static let terraform = Self("terraform.cli", "Terraform CLI", .terraform)

    public static let ollamaCLI = Self("ollama.cli", "Ollama CLI", .ollama)
    public static let ollamaAPI = Self("ollama.api", "Ollama API", .ollama)
    public static let ollamaModelfile = Self("ollama.modelfile", "Modelfile", .ollama)

    public static let crowdSecDecisions = Self("crowdsec.decisions", "Решения и алерты", .crowdsec)
    public static let crowdSecHub = Self("crowdsec.hub", "CrowdSec Hub", .crowdsec)
    public static let crowdSecLocalAPI = Self("crowdsec.local-api", "Machines и bouncers", .crowdsec)

    public static let mattermostAuthSystem = Self("mattermost.auth-system", "Авторизация и система", .mattermost)
    public static let mattermostUsers = Self("mattermost.users", "Пользователи", .mattermost)
    public static let mattermostTeamsChannels = Self("mattermost.teams-channels", "Команды и каналы", .mattermost)
    public static let mattermostContentPlugins = Self("mattermost.content-plugins", "Сообщения и плагины", .mattermost)

    public static let gitRepository = Self("git.repository", "Репозиторий", .git)
    public static let gitChanges = Self("git.changes", "Изменения и коммиты", .git)
    public static let gitBranchesRemotes = Self("git.branches-remotes", "Ветки и remotes", .git)
    public static let gitRecovery = Self("git.recovery", "Stash и восстановление", .git)

    public static let nodeRuntime = Self("node.runtime", "Node.js runtime", .nodeJS)
    public static let typescriptCompiler = Self("typescript.tsc", "TypeScript compiler", .typescript)
    public static let tsx = Self("typescript.tsx", "tsx", .typescript)
    public static let npm = Self("frontend-tooling.npm", "npm", .frontendTooling)
    public static let pnpm = Self("frontend-tooling.pnpm", "pnpm", .frontendTooling)
    public static let vite = Self("frontend-tooling.vite", "Vite", .frontendTooling)
    public static let vitest = Self("frontend-testing.vitest", "Vitest", .frontendTesting)
    public static let frontendPlaywright = Self("frontend-testing.playwright", "Playwright", .frontendTesting)
    public static let frontendCypress = Self("frontend-testing.cypress", "Cypress", .frontendTesting)

    public static let pythonRuntime = Self("python.runtime", "Python runtime", .python)
    public static let pip = Self("python.pip", "pip", .python)
    public static let uv = Self("python.uv", "uv", .python)
    public static let goToolchain = Self("go.toolchain", "Go toolchain", .go)
    public static let gofmt = Self("go.gofmt", "gofmt", .go)

    public static let postgresql = Self("databases.postgresql", "PostgreSQL", .databases)
    public static let mysql = Self("databases.mysql", "MySQL", .databases)
    public static let sqlite = Self("databases.sqlite", "SQLite", .databases)
    public static let redis = Self("databases.redis", "Redis", .databases)
    public static let mongodb = Self("databases.mongodb", "MongoDB", .databases)

    public static let curlAPI = Self("api.curl", "cURL", .apiAndGRPC)
    public static let httpie = Self("api.httpie", "HTTPie", .apiAndGRPC)
    public static let grpcurlAPI = Self("api.grpcurl", "gRPCurl", .apiAndGRPC)

    public static let newman = Self("api-testing.newman", "Newman", .apiTesting)
    public static let hurl = Self("api-testing.hurl", "Hurl", .apiTesting)
    public static let schemathesis = Self("api-testing.schemathesis", "Schemathesis", .apiTesting)
    public static let grpcurlTesting = Self("api-testing.grpcurl", "gRPCurl", .apiTesting)
    public static let qaPlaywright = Self("ui-testing.playwright", "Playwright", .uiTesting)
    public static let qaCypress = Self("ui-testing.cypress", "Cypress", .uiTesting)
    public static let selenium = Self("ui-testing.selenium", "Selenium", .uiTesting)

    public static let k6 = Self("load-testing.k6", "k6", .loadTesting)
    public static let artillery = Self("load-testing.artillery", "Artillery", .loadTesting)
    public static let wrk = Self("load-testing.wrk", "wrk", .loadTesting)
    public static let apacheBench = Self("load-testing.ab", "ApacheBench", .loadTesting)

    public static let androidADB = Self("mobile-accessibility.adb", "Android / adb", .mobileAccessibility)
    public static let iosSimulator = Self("mobile-accessibility.simctl", "iOS Simulator", .mobileAccessibility)
    public static let lighthouse = Self("mobile-accessibility.lighthouse", "Lighthouse", .mobileAccessibility)
    public static let axe = Self("mobile-accessibility.axe", "axe-core", .mobileAccessibility)
    public static let pa11y = Self("mobile-accessibility.pa11y", "Pa11y", .mobileAccessibility)

    public static let all: [CommandSubcategory] = [
        .kubectl, .helm, .flux,
        .linuxFiles, .linuxSearch, .linuxNetwork, .linuxSystemd, .linuxProcesses, .linuxPermissions, .linuxLogsArchives,
        .ansiblePlaybooks, .ansibleInventory, .ansibleVault, .terraform,
        .ollamaCLI, .ollamaAPI, .ollamaModelfile,
        .crowdSecDecisions, .crowdSecHub, .crowdSecLocalAPI,
        .mattermostAuthSystem, .mattermostUsers, .mattermostTeamsChannels, .mattermostContentPlugins,
        .gitRepository, .gitChanges, .gitBranchesRemotes, .gitRecovery,
        .nodeRuntime, .typescriptCompiler, .tsx,
        .npm, .pnpm, .vite, .vitest, .frontendPlaywright, .frontendCypress,
        .pythonRuntime, .pip, .uv, .goToolchain, .gofmt,
        .postgresql, .mysql, .sqlite, .redis, .mongodb,
        .curlAPI, .httpie, .grpcurlAPI,
        .newman, .hurl, .schemathesis, .grpcurlTesting,
        .qaPlaywright, .qaCypress, .selenium,
        .k6, .artillery, .wrk, .apacheBench,
        .androidADB, .iosSimulator, .lighthouse, .axe, .pa11y
    ]

    public static func all(in category: CommandCategory) -> [CommandSubcategory] {
        all.filter { $0.category == category }
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        guard let subcategory = Self.all.first(where: { $0.id == value }) else {
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Unknown command subcategory: \(value)"
            )
        }
        self = subcategory
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }

    public static func == (lhs: CommandSubcategory, rhs: CommandSubcategory) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum CommandTaxonomy {
    public static func subcategory(for entry: CommandEntry) -> CommandSubcategory {
        let tags = Set(entry.tags.map { $0.lowercased() })
        let command = entry.command.lowercased()

        switch entry.category {
        case .kubernetes: return .kubectl
        case .helm: return .helm
        case .flux: return .flux
        case .linux:
            if tags.contains("systemd") { return .linuxSystemd }
            if !tags.isDisjoint(with: ["process", "cpu", "memory", "load"]) { return .linuxProcesses }
            if !tags.isDisjoint(with: ["network", "ports", "port", "http", "curl", "nc"]) { return .linuxNetwork }
            if !tags.isDisjoint(with: ["permissions", "acl"]) { return .linuxPermissions }
            if !tags.isDisjoint(with: ["search", "grep"]) { return .linuxSearch }
            if !tags.isDisjoint(with: ["logs", "tail", "archive", "tar"]) { return .linuxLogsArchives }
            return .linuxFiles
        case .ansible:
            if command.contains("ansible-vault") { return .ansibleVault }
            if command.contains("ansible-inventory") || command.hasPrefix("ansible ") { return .ansibleInventory }
            return .ansiblePlaybooks
        case .terraform: return .terraform
        case .ollama:
            if tags.contains("api") { return .ollamaAPI }
            if tags.contains("modelfile") { return .ollamaModelfile }
            return .ollamaCLI
        case .crowdsec:
            if !tags.isDisjoint(with: ["hub", "scenarios", "collections", "parsers"]) { return .crowdSecHub }
            if !tags.isDisjoint(with: ["lapi", "machines", "bouncers"]) { return .crowdSecLocalAPI }
            return .crowdSecDecisions
        case .mattermost:
            if !tags.isDisjoint(with: ["auth", "system", "version"]) { return .mattermostAuthSystem }
            if tags.contains("user") { return .mattermostUsers }
            if !tags.isDisjoint(with: ["team", "channel"]) { return .mattermostTeamsChannels }
            return .mattermostContentPlugins
        case .git:
            if !tags.isDisjoint(with: ["stash", "reflog", "recovery", "cherry-pick", "blame"]) { return .gitRecovery }
            if !tags.isDisjoint(with: ["branch", "switch", "remote", "fetch", "pull", "push"]) { return .gitBranchesRemotes }
            if !tags.isDisjoint(with: ["add", "staging", "commit", "diff", "log", "history"]) { return .gitChanges }
            return .gitRepository
        case .nodeJS: return .nodeRuntime
        case .typescript: return command.contains("tsx ") ? .tsx : .typescriptCompiler
        case .frontendTooling:
            if command.hasPrefix("pnpm ") { return .pnpm }
            if command.contains("vite") { return .vite }
            return .npm
        case .frontendTesting:
            if tags.contains("playwright") { return .frontendPlaywright }
            if tags.contains("cypress") { return .frontendCypress }
            return .vitest
        case .python:
            if tags.contains("uv") { return .uv }
            if tags.contains("pip") { return .pip }
            return .pythonRuntime
        case .go: return command.hasPrefix("gofmt ") ? .gofmt : .goToolchain
        case .databases:
            if tags.contains("mysql") { return .mysql }
            if tags.contains("sqlite") { return .sqlite }
            if tags.contains("redis") { return .redis }
            if tags.contains("mongodb") { return .mongodb }
            return .postgresql
        case .apiAndGRPC:
            if tags.contains("grpc") { return .grpcurlAPI }
            if tags.contains("httpie") { return .httpie }
            return .curlAPI
        case .apiTesting:
            if tags.contains("hurl") { return .hurl }
            if tags.contains("schemathesis") { return .schemathesis }
            if tags.contains("grpcurl") { return .grpcurlTesting }
            return .newman
        case .uiTesting:
            if tags.contains("cypress") { return .qaCypress }
            if tags.contains("selenium") { return .selenium }
            return .qaPlaywright
        case .loadTesting:
            if tags.contains("artillery") { return .artillery }
            if tags.contains("wrk") { return .wrk }
            if tags.contains("ab") { return .apacheBench }
            return .k6
        case .mobileAccessibility:
            if tags.contains("adb") { return .androidADB }
            if tags.contains("simctl") { return .iosSimulator }
            if tags.contains("lighthouse") { return .lighthouse }
            if tags.contains("axe") { return .axe }
            return .pa11y
        }
    }
}

public extension CommandEntry {
    var subcategory: CommandSubcategory {
        CommandTaxonomy.subcategory(for: self)
    }
}
