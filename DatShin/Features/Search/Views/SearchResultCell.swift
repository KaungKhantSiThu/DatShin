import UIKit
import Nuke
import NukeExtensions

class SearchResultCell: UICollectionViewListCell {
    static let reuseIdentifier = "SearchResultCell"

    private var imageTask: Task<Void, Never>?
    private let imageSize = CGSize(width: 70, height: 105)

    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
        accessories = []
        imageTask?.cancel()
        imageTask = nil
    }

    func configure(with media: Media, imagesConfiguration: ImagesConfiguration?) {
        let name: String
        
        switch media {
        case .movie(let movieListItem):
            name = movieListItem.title
        case .tvSeries(let tVSeriesListItem):
            name = tVSeriesListItem.name
        case .person(let personListItem):
            name = personListItem.name
        }
        
        var content = UIListContentConfiguration.cell()
        content.text = name
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = buildSubtitle(for: media)
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        
        // Create a placeholder image with the same size as the poster
        let placeholderImage = createPlaceholderImage(size: imageSize)
        content.image = placeholderImage
        content.imageProperties.cornerRadius = 8
        content.imageProperties.maximumSize = imageSize
        content.imageProperties.tintColor = .systemGray4
        content.imageToTextPadding = 12
        content.textToSecondaryTextVerticalPadding = 4
        self.contentConfiguration = content
        
        // Cancel any existing image task
        imageTask?.cancel()
        imageTask = nil
        
        // Async image loading
        if let posterPath = posterPath(for: media), let imagesConfig = imagesConfiguration {
            let idealWidth = Int(imageSize.width * UIScreen.main.scale)
            
            if let posterURL = imagesConfig.posterURL(for: posterPath, idealWidth: idealWidth) {
                imageTask = Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        let response = try await ImagePipeline.shared.image(for: posterURL)
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            var updatedContent = self.contentConfiguration as? UIListContentConfiguration
                            updatedContent?.image = response
                            self.contentConfiguration = updatedContent
                        }
                    } catch {
                        if !Task.isCancelled {
                            print("Failed to load image: \(error)")
                        }
                    }
                }
            }
        }
        
        // Trailing accessory button
        let queueButton = UIButton(type: .system)
        queueButton.setTitle("+", for: .normal)
        queueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        queueButton.backgroundColor = UIColor.systemGray5
        queueButton.layer.cornerRadius = 8
        queueButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.accessories = [
            .customView(configuration: .init(customView: queueButton, placement: .trailing(displayed: .always)))
        ]
    }
    
    private func createPlaceholderImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let image = UIImage(systemName: "photo")!
            let imageSize = CGSize(width: size.width * 0.4, height: size.width * 0.4)
            let imageRect = CGRect(
                x: (size.width - imageSize.width) / 2,
                y: (size.height - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
            image.draw(in: imageRect)
        }
    }
    
    private func buildSubtitle(for media: Media) -> String {
        let year: String
        let genre: String = "" // Add genre extraction if available
        switch media {
        case .movie(let movie):
            year = movie.releaseDate?.formatted(.dateTime) ?? ""
        case .tvSeries(let tv):
            year = tv.firstAirDate?.formatted(.dateTime) ?? ""
        case .person(let person):
            year = ""
        }
        return [year, genre].filter { !$0.isEmpty }.joined(separator: "  ")
    }
    
    private func posterPath(for media: Media) -> URL? {
        switch media {
        case .movie(let movie):
            return movie.posterPath
        case .tvSeries(let tv):
            return tv.posterPath
        case .person(let person):
            return person.profilePath
        }
    }
}
