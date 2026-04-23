import UIKit

@MainActor
class BDUIScreenHostingViewController: UIViewController {
    private let loader: BDUIScreenLoading
    private let registry: BDUIMapperRegistry
    private let actionBinder: BDUIActionBinding
    private let actionHandler: BDUIActionHandler

    private var renderedRootView = UIView()
    private var mappingContext: BDUINodeMappingContext?

    var onAction: ((BDUIActionDTO) -> Void)? {
        didSet {
            actionHandler.onAction = onAction
        }
    }

    init(
        loader: BDUIScreenLoading,
        registry: BDUIMapperRegistry,
        actionBinder: BDUIActionBinding,
        actionHandler: BDUIActionHandler
    ) {
        self.loader = loader
        self.registry = registry
        self.actionBinder = actionBinder
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.background
    }

    func render(templateName: String, context: [String: String]) {
        do {
            let screen = try loader.loadScreen(named: templateName, context: context)
            render(screen: screen)
        } catch {
            renderFallbackError("BDUI error: \(error.localizedDescription)")
        }
    }

    func render(screen: BDUIScreenDTO) {
        renderedRootView.removeFromSuperview()

        let mappingContext = BDUINodeMappingContext(
            registry: registry,
            actionBinder: actionBinder,
            actionHandler: actionHandler
        )
        self.mappingContext = mappingContext

        let rootView = registry.map(node: screen.root, context: mappingContext) ?? UIView()
        rootView.translatesAutoresizingMaskIntoConstraints = false
        renderedRootView = rootView

        view.addSubview(rootView)
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    func renderedView(withID id: String) -> UIView? {
        mappingContext?.view(for: id)
    }

    private func renderFallbackError(_ message: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.ds_apply(.errorBanner)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center

        renderedRootView.removeFromSuperview()
        renderedRootView = label
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Spacing.m),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Spacing.m)
        ])
    }
}
