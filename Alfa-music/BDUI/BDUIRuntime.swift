import UIKit

@MainActor
protocol BDUIScreenLoading {
    func loadScreen(named name: String, context: [String: String]) throws -> BDUIScreenDTO
}

@MainActor
final class BundleBDUIScreenLoader: BDUIScreenLoading {
    private let decoder = JSONDecoder()
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadScreen(named name: String, context: [String: String]) throws -> BDUIScreenDTO {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "BDUI",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Resource \(name).json not found"]
            )
        }

        let rawData = try Data(contentsOf: url)
        guard var rawString = String(data: rawData, encoding: .utf8) else {
            throw NSError(
                domain: "BDUI",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 in \(name).json"]
            )
        }

        context.forEach { key, value in
            rawString = rawString.replacingOccurrences(of: "{{\(key)}}", with: value)
        }

        guard let finalData = rawString.data(using: .utf8) else {
            throw NSError(
                domain: "BDUI",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode substituted template"]
            )
        }

        return try decoder.decode(BDUIScreenDTO.self, from: finalData)
    }
}

@MainActor
protocol BDUIActionHandling: AnyObject {
    func handle(_ action: BDUIActionDTO)
}

@MainActor
final class BDUIActionHandler: BDUIActionHandling {
    var onCallback: ((String) -> Void)?

    func handle(_ action: BDUIActionDTO) {
        switch action {
        case .callback(let id):
            onCallback?(id)
        }
    }
}

@MainActor
protocol BDUIActionBinding: AnyObject {
    func bind(action: BDUIActionDTO?, to view: UIView, handler: BDUIActionHandling)
}

@MainActor
final class BDUIActionBinder: BDUIActionBinding {
    private var buttonHandlers: [DSButtonActionProxy] = []
    private var tapHandlers: [ViewTapActionProxy] = []

    func bind(action: BDUIActionDTO?, to view: UIView, handler: BDUIActionHandling) {
        guard let action else { return }

        if let button = view as? DSButton {
            let proxy = DSButtonActionProxy(action: action, handler: handler)
            buttonHandlers.append(proxy)
            button.addTouchUpInside(proxy, action: #selector(DSButtonActionProxy.invoke))
            return
        }

        if let field = view as? DSFormTextField {
            field.onEditingChanged = { [weak field, weak handler] in
                guard field != nil else { return }
                handler?.handle(action)
            }
            return
        }

        let proxy = ViewTapActionProxy(action: action, handler: handler)
        tapHandlers.append(proxy)
        let tap = UITapGestureRecognizer(target: proxy, action: #selector(ViewTapActionProxy.invoke))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
}

@MainActor
private final class DSButtonActionProxy: NSObject {
    private let action: BDUIActionDTO
    private weak var handler: BDUIActionHandling?

    init(action: BDUIActionDTO, handler: BDUIActionHandling) {
        self.action = action
        self.handler = handler
    }

    @objc
    func invoke() {
        handler?.handle(action)
    }
}

@MainActor
private final class ViewTapActionProxy: NSObject {
    private let action: BDUIActionDTO
    private weak var handler: BDUIActionHandling?

    init(action: BDUIActionDTO, handler: BDUIActionHandling) {
        self.action = action
        self.handler = handler
    }

    @objc
    func invoke() {
        handler?.handle(action)
    }
}
