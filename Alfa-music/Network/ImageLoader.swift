import UIKit

protocol ImageLoaderProtocol {
    func loadImage(url: URL) async throws -> UIImage
    func prefetch(urls: [URL])
    func cancelPrefetch(urls: [URL])
}

final class ImageLoader: ImageLoaderProtocol {

    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private var tasks: [URL: Task<UIImage, Error>] = [:]

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 300
    }

    func loadImage(url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        if let existing = tasks[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw NetworkError.badServerResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            guard let image = UIImage(data: data) else {
                throw NetworkError.decodingError("Не удалось декодировать изображение")
            }
            return image
        }

        tasks[url] = task
        do {
            let image = try await task.value
            cache.setObject(image, forKey: url as NSURL)
            tasks[url] = nil
            return image
        } catch {
            tasks[url] = nil
            throw error
        }
    }

    func prefetch(urls: [URL]) {
        for url in urls {
            guard cache.object(forKey: url as NSURL) == nil else { continue }
            if tasks[url] != nil { continue }

            let task = Task<UIImage, Error> {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    throw NetworkError.badServerResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
                }
                guard let image = UIImage(data: data) else {
                    throw NetworkError.decodingError("Не удалось декодировать изображение")
                }
                return image
            }
            tasks[url] = task

            Task { [weak self] in
                guard let self else { return }
                if let image = try? await task.value {
                    self.cache.setObject(image, forKey: url as NSURL)
                }
                self.tasks[url] = nil
            }
        }
    }

    func cancelPrefetch(urls: [URL]) {
        for url in urls {
            tasks[url]?.cancel()
            tasks[url] = nil
        }
    }
}
