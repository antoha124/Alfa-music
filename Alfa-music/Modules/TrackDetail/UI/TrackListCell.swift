import UIKit

final class TrackListCell: UITableViewCell {

    static let reuseIdentifier = "TrackListCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let rightLabel: UILabel = {
        let l = UILabel()
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.ds_apply(.bodyMedium)
        subtitleLabel.ds_apply(.captionSecondary)
        rightLabel.font = DS.Typography.captionMonospaced()
        rightLabel.textColor = DS.Colors.textSecondary
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
        vStack.spacing = DS.Layout.TrackDetail.trackCellTitleSubtitleSpacing
        vStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(vStack)
        contentView.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.Layout.TrackDetail.trackCellHorizontalInset),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DS.Layout.TrackDetail.trackCellVerticalInset),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DS.Layout.TrackDetail.trackCellVerticalInset),

            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: vStack.trailingAnchor, constant: DS.Layout.TrackDetail.trackCellRightGap),
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DS.Layout.TrackDetail.trackCellHorizontalInset),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
