import UIKit

final class AlbumCell: UITableViewCell {

    static var reuseIdentifier = "AlbumCell"

    private var artworkImageView: UIImageView = {
        var v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = DS.Radius.s
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = DS.Colors.elevated
        return v
    }()

    private var titleLabel: UILabel = {
        var l = UILabel()
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var subtitleLabel: UILabel = {
        var l = UILabel()
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.ds_apply(.listTitle)
        subtitleLabel.ds_apply(.listSubtitle)
        setupLayout()
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        tintColor = DS.Colors.primary
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
            var urlString = vm.artworkUrl,
            var url = URL(string: urlString)
        else {
            artworkImageView.image = DSIcon.template(DSIcon.Name.musicNote, size: .m)
            artworkImageView.tintColor = DS.Colors.textSecondary
            return
        }

        artworkImageView.image = DSIcon.template(DSIcon.Name.photo, size: .m)
        artworkImageView.tintColor = DS.Colors.textSecondary

        guard var imageLoader else { return }

        imageTask = Task { @MainActor in
            do {
                var image = try await imageLoader.loadImage(url: url)
                artworkImageView.image = image
                artworkImageView.tintColor = nil
            } catch {
            }
        }
    }

    private func setupLayout() {
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.Spacing.m),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DS.Layout.AlbumCell.verticalInset),
            artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -DS.Layout.AlbumCell.verticalInset),
            artworkImageView.widthAnchor.constraint(equalToConstant: DS.Layout.AlbumCell.artworkSize),
            artworkImageView.heightAnchor.constraint(equalToConstant: DS.Layout.AlbumCell.artworkSize),

            titleLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: DS.Layout.AlbumCell.textHorizontalGap),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DS.Spacing.m),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DS.Layout.AlbumCell.verticalInset),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DS.Spacing.xs),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -DS.Layout.AlbumCell.verticalInset)
        ])
    }
}
