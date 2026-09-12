import Foundation

public enum CommandCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case kubernetes = "Kubernetes"
    case helm = "Helm"
    case flux = "Flux"
    case linux = "Linux"
    case ansible = "Ansible"
    case terraform = "Terraform"
    case ollama = "Ollama"
    case crowdsec = "CrowdSec"
    case mattermost = "Mattermost"
    case git = "Git"
    case nodeJS = "Node.js"
    case typescript = "TypeScript"
    case frontendTooling = "Frontend Tooling"
    case frontendTesting = "Frontend Testing"
    case python = "Python"
    case go = "Go"
    case databases = "Databases"
    case apiAndGRPC = "API & gRPC"
    case apiTesting = "API Testing"
    case uiTesting = "UI Testing"
    case loadTesting = "Load Testing"
    case mobileAccessibility = "Mobile & Accessibility"

    public var id: String { rawValue }

    public var bundledVersion: Int {
        switch self {
        case .nodeJS, .typescript, .frontendTooling, .frontendTesting,
             .python, .go, .databases, .apiAndGRPC,
             .apiTesting, .uiTesting, .loadTesting, .mobileAccessibility:
            return 5
        default:
            return 4
        }
    }
}

public struct CommandEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var command: String
    public var category: CommandCategory
    public var tags: [String]
    public var summary: String
    public var details: String
    public var examples: [String]
    public var modifiedAt: Date
    public var order: Int?
    public var bundledVersion: Int?

    public init(
        id: UUID = UUID(),
        title: String,
        command: String,
        category: CommandCategory,
        tags: [String] = [],
        summary: String,
        details: String,
        examples: [String] = [],
        modifiedAt: Date = Date(),
        order: Int? = nil,
        bundledVersion: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.command = command
        self.category = category
        self.tags = tags
        self.summary = summary
        self.details = details
        self.examples = examples
        self.modifiedAt = modifiedAt
        self.order = order
        self.bundledVersion = bundledVersion
    }
}
