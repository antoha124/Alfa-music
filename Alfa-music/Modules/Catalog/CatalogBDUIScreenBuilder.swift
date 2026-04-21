import Foundation

@MainActor
final class CatalogBDUIScreenBuilder {
    func makeScreen(items: [AlbumCellViewModel]) -> BDUIScreenDTO {
        let nodes: [BDUINodeDTO] = [
            makeHeaderTitle(itemsCount: items.count)
        ] + items.map(makeAlbumNode) + [
            makeLoadMoreNode()
        ]

        return BDUIScreenDTO(
            root: BDUINodeDTO(
                id: "catalog_root",
                type: .scroll,
                content: .stack(
                    BDUIStackContentDTO(
                        spacing: .m,
                        padding: .m,
                        backgroundColor: .background,
                        cornerRadius: nil
                    )
                ),
                subviews: nodes,
                action: nil,
                isVisible: true
            )
        )
    }

    private func makeHeaderTitle(itemsCount: Int) -> BDUINodeDTO {
        BDUINodeDTO(
            id: "catalog_header_stack",
            type: .vStack,
            content: .stack(
                BDUIStackContentDTO(
                    spacing: .xs,
                    padding: nil,
                    backgroundColor: nil,
                    cornerRadius: nil
                )
            ),
            subviews: [
                makeLabel(id: "catalog_title", text: "Каталог", style: .titleLarge),
                makeLabel(id: "catalog_subtitle", text: "Найдено: \(itemsCount)", style: .captionSecondary)
            ],
            action: nil,
            isVisible: true
        )
    }

    private func makeAlbumNode(_ item: AlbumCellViewModel) -> BDUINodeDTO {
        BDUINodeDTO(
            id: "catalog_album_\(item.id)",
            type: .container,
            content: .container(
                BDUIContainerContentDTO(
                    backgroundColor: .elevated,
                    padding: .m,
                    cornerRadius: .m
                )
            ),
            subviews: [
                BDUINodeDTO(
                    id: "catalog_album_row_\(item.id)",
                    type: .hStack,
                    content: .stack(
                        BDUIStackContentDTO(
                            spacing: .m,
                            padding: nil,
                            backgroundColor: nil,
                            cornerRadius: nil
                        )
                    ),
                    subviews: [
                        BDUINodeDTO(
                            id: "catalog_album_image_\(item.id)",
                            type: .image,
                            content: .image(
                                BDUIImageContentDTO(
                                    url: item.artworkUrl,
                                    width: Double(DS.Layout.AlbumCell.artworkSize),
                                    height: Double(DS.Layout.AlbumCell.artworkSize),
                                    cornerRadius: .s,
                                    contentMode: .scaleAspectFill
                                )
                            ),
                            subviews: [],
                            action: nil,
                            isVisible: true
                        ),
                        BDUINodeDTO(
                            id: "catalog_album_text_\(item.id)",
                            type: .vStack,
                            content: .stack(
                                BDUIStackContentDTO(
                                    spacing: .xs,
                                    padding: nil,
                                    backgroundColor: nil,
                                    cornerRadius: nil
                                )
                            ),
                            subviews: [
                                makeLabel(
                                    id: "catalog_album_title_\(item.id)",
                                    text: item.title,
                                    style: .listTitle
                                ),
                                makeLabel(
                                    id: "catalog_album_subtitle_\(item.id)",
                                    text: "\(item.artistName) • \(item.releaseYear)",
                                    style: .listSubtitle
                                )
                            ],
                            action: nil,
                            isVisible: true
                        )
                    ],
                    action: nil,
                    isVisible: true
                )
            ],
            action: .callback(id: "catalog_open_\(item.id)"),
            isVisible: true
        )
    }

    private func makeLoadMoreNode() -> BDUINodeDTO {
        BDUINodeDTO(
            id: "catalog_load_more",
            type: .button,
            content: .button(
                BDUIButtonContentDTO(
                    title: "Загрузить еще",
                    style: .secondary,
                    isEnabled: true
                )
            ),
            subviews: [],
            action: .callback(id: "catalog_load_more_tap"),
            isVisible: true
        )
    }

    private func makeLabel(
        id: String,
        text: String,
        style: BDUITextStyleToken
    ) -> BDUINodeDTO {
        BDUINodeDTO(
            id: id,
            type: .label,
            content: .label(
                BDUILabelContentDTO(
                    text: text,
                    textStyle: style,
                    color: style == .titleLarge || style == .listTitle ? .textPrimary : .textSecondary,
                    alignment: "left",
                    numberOfLines: 0
                )
            ),
            subviews: [],
            action: nil,
            isVisible: true
        )
    }
}
