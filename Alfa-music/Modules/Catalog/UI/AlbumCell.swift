import UIKit

final class AlbumCell: UITableViewCell {

    static let reuseIdentifier = "AlbumCell"

    private let artworkImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        artworkImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with vm: AlbumCellViewModel, imageLoader: ImageLoaderProtocol?) {
        titleLabel.text = vm.title
        subtitleLabel.text = "\(vm.artistName) • \(vm.releaseYear)"

        guard
            let urlString = vm.artworkUrl,
            let url = URL(string: urlString)
        else {
            artworkImageView.image = UIImage(systemName: "music.note")
            return
        }

        artworkImageView.image = UIImage(systemName: "photo")

        guard let imageLoader else { return }

        imageTask = Task { @MainActor in
            do {
                let image = try await imageLoader.loadImage(url: url)
                artworkImageView.image = image
            } catch {
            }
        }
    }

    private func setupLayout() {
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            artworkImageView.widthAnchor.constraint(equalToConstant: 56),
            artworkImageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
