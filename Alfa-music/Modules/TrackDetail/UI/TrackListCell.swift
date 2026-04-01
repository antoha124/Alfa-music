import UIKit

final class TrackListCell: UITableViewCell {

    static let reuseIdentifier = "TrackListCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let rightLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        rightLabel.text = nil
    }

    func configure(with vm: TrackCellViewModel) {
        titleLabel.text = vm.title
        subtitleLabel.text = vm.subtitle
        rightLabel.text = vm.rightText
    }

    private func setup() {
        let vStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(vStack)
        contentView.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: vStack.trailingAnchor, constant: 12),
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
