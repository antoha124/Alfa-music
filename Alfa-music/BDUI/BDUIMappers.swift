import UIKit

@MainActor
protocol BDUINodeMapping {
    var supportedType: BDUIComponentType { get }
    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView?
}

@MainActor
final class BDUIMapperRegistry {
    private var storage: [BDUIComponentType: any BDUINodeMapping] = [:]

    func register(_ mapper: any BDUINodeMapping) {
        storage[mapper.supportedType] = mapper
    }

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard node.isVisible else { return nil }
        guard let mapper = storage[node.type] else { return nil }
        guard let view = mapper.map(node: node, context: context) else { return nil }
        context.register(view: view, for: node.id)
        if node.type != .state {
            context.bindAction(node.action, to: view)
        }
        return view
    }

    static func makeDefault() -> BDUIMapperRegistry {
        let registry = BDUIMapperRegistry()
        registry.register(ScrollNodeMapper())
        registry.register(VerticalStackNodeMapper())
        registry.register(HorizontalStackNodeMapper())
        registry.register(ContainerNodeMapper())
        registry.register(ImageNodeMapper())
        registry.register(LabelNodeMapper())
        registry.register(ButtonNodeMapper())
        registry.register(TextFieldNodeMapper())
        registry.register(SpacerNodeMapper())
        registry.register(StateNodeMapper())
        return registry
    }
}

@MainActor
final class BDUINodeMappingContext {
    let registry: BDUIMapperRegistry
    let actionBinder: BDUIActionBinding
    weak var actionHandler: BDUIActionHandling?

    private(set) var renderedViewsByID: [String: UIView] = [:]

    init(
        registry: BDUIMapperRegistry,
        actionBinder: BDUIActionBinding,
        actionHandler: BDUIActionHandling
    ) {
        self.registry = registry
        self.actionBinder = actionBinder
        self.actionHandler = actionHandler
    }

    func register(view: UIView, for id: String) {
        renderedViewsByID[id] = view
    }

    func view(for id: String) -> UIView? {
        renderedViewsByID[id]
    }

    func bindAction(_ action: BDUIActionDTO?, to view: UIView) {
        guard let actionHandler else { return }
        actionBinder.bind(action: action, to: view, handler: actionHandler)
    }

    func mapChildren(_ nodes: [BDUINodeDTO]) -> [UIView] {
        nodes.compactMap { registry.map(node: $0, context: self) }
    }
}

@MainActor
private enum BDUIMapperUtils {
    static func makeStack(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat,
        arrangedSubviews: [UIView]
    ) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = axis
        stack.spacing = spacing
        arrangedSubviews.forEach { stack.addArrangedSubview($0) }
        return stack
    }

    static func wrapIfNeeded(
        stack: UIStackView,
        padding: BDUISpacingToken?,
        backgroundColor: BDUIColorToken?,
        cornerRadius: BDUICornerRadiusToken?
    ) -> UIView {
        guard padding != nil || backgroundColor != nil || cornerRadius != nil else {
            return stack
        }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = backgroundColor?.uiColor ?? .clear
        container.layer.cornerRadius = cornerRadius?.value ?? 0
        container.layer.masksToBounds = true
        container.addSubview(stack)

        let inset = padding?.value ?? 0
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: inset),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset)
        ])
        return container
    }
}

@MainActor
final class ScrollNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .scroll

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .stack(let content)? = node.content else { return nil }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.backgroundColor = content.backgroundColor?.uiColor ?? DS.Colors.background

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = content.spacing?.value ?? 0

        scrollView.addSubview(contentView)
        contentView.addSubview(stack)
        context.mapChildren(node.subviews).forEach { stack.addArrangedSubview($0) }

        let inset = content.padding?.value ?? 0
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
        ])

        return scrollView
    }
}

@MainActor
final class VerticalStackNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .vStack

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .stack(let content)? = node.content else { return nil }
        let children = context.mapChildren(node.subviews)
        let stack = BDUIMapperUtils.makeStack(
            axis: .vertical,
            spacing: content.spacing?.value ?? 0,
            arrangedSubviews: children
        )
        return BDUIMapperUtils.wrapIfNeeded(
            stack: stack,
            padding: content.padding,
            backgroundColor: content.backgroundColor,
            cornerRadius: content.cornerRadius
        )
    }
}

@MainActor
final class HorizontalStackNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .hStack

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .stack(let content)? = node.content else { return nil }
        let children = context.mapChildren(node.subviews)
        let stack = BDUIMapperUtils.makeStack(
            axis: .horizontal,
            spacing: content.spacing?.value ?? 0,
            arrangedSubviews: children
        )
        stack.alignment = .center
        return BDUIMapperUtils.wrapIfNeeded(
            stack: stack,
            padding: content.padding,
            backgroundColor: content.backgroundColor,
            cornerRadius: content.cornerRadius
        )
    }
}

@MainActor
final class ContainerNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .container

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .container(let content)? = node.content else { return nil }
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = content.backgroundColor?.uiColor ?? .clear
        container.layer.cornerRadius = content.cornerRadius?.value ?? 0
        container.layer.masksToBounds = true

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        context.mapChildren(node.subviews).forEach { stack.addArrangedSubview($0) }
        container.addSubview(stack)

        let inset = content.padding?.value ?? 0
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: inset),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset)
        ])

        return container
    }
}

@MainActor
final class ImageNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .image
    private let imageLoader: ImageLoaderProtocol = ImageLoader()

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .image(let content)? = node.content else { return nil }

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = content.contentMode?.value ?? .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = content.cornerRadius?.value ?? 0
        imageView.backgroundColor = DS.Colors.elevated
        imageView.tintColor = DS.Colors.textSecondary
        imageView.image = DSIcon.template(DSIcon.Name.photo, size: .m)

        if let width = content.width {
            imageView.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        }
        if let height = content.height {
            imageView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        }

        if
            let urlString = content.url,
            let url = URL(string: urlString)
        {
            Task { @MainActor in
                if let image = try? await imageLoader.loadImage(url: url) {
                    imageView.image = image
                    imageView.tintColor = nil
                }
            }
        } else {
            imageView.image = DSIcon.template(DSIcon.Name.musicNote, size: .m)
        }

        return imageView
    }
}

@MainActor
final class LabelNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .label

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .label(let content)? = node.content else { return nil }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = content.text
        label.ds_apply(content.textStyle.style)
        label.numberOfLines = content.numberOfLines ?? 0
        label.textColor = content.color?.uiColor ?? label.textColor

        switch content.alignment {
        case "center":
            label.textAlignment = .center
        case "right":
            label.textAlignment = .right
        default:
            label.textAlignment = .left
        }
        return label
    }
}

@MainActor
final class ButtonNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .button

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .button(let content)? = node.content else { return nil }
        return DSButton(
            model: DSButton.Model(
                title: content.title,
                style: content.style.dsStyle,
                isEnabled: content.isEnabled ?? true
            )
        )
    }
}

@MainActor
final class TextFieldNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .textField

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .textField(let content)? = node.content else { return nil }
        let field = DSFormTextField(
            model: DSFormTextField.Model(
                title: content.title,
                placeholder: content.placeholder,
                text: content.text,
                errorMessage: content.errorMessage,
                isSecure: content.isSecure ?? false,
                keyboardType: .default,
                autocapitalizationType: .none,
                returnKeyType: .default
            )
        )
        return field
    }
}

@MainActor
final class SpacerNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .spacer

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let height: CGFloat
        if case .spacer(let content)? = node.content {
            height = CGFloat(content.height ?? DS.Spacing.m)
        } else {
            height = DS.Spacing.m
        }
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
}

@MainActor
final class StateNodeMapper: BDUINodeMapping {
    let supportedType: BDUIComponentType = .state

    func map(node: BDUINodeDTO, context: BDUINodeMappingContext) -> UIView? {
        guard case .state(let content)? = node.content else { return nil }
        let state: DSStateContainerView.State
        switch content.style {
        case .hidden:
            state = .hidden
        case .loading:
            state = .loading(message: content.message)
        case .empty:
            state = .empty(
                title: content.title ?? "Пусто",
                message: content.message ?? ""
            )
        case .error:
            state = .error(
                message: content.message ?? "Ошибка",
                showsRetry: content.actionTitle != nil
            )
        }

        let view = DSStateContainerView(
            model:
            DSStateContainerView.Model(
                state: state,
                onRetry: { [weak context] in
                    guard
                        let action = node.action,
                        let handler = context?.actionHandler
                    else { return }
                    handler.handle(action)
                }
            )
        )
        return view
    }
}
