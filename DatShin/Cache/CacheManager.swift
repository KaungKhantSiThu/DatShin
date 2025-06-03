import Foundation

protocol CacheManagerProtocol {
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval?) throws
    func get<T: Decodable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
    func clear()
}

class CacheManager: CacheManagerProtocol {
    private let memoryCache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() throws {
        let cachesDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        cacheDirectory = cachesDirectory.appendingPathComponent("DatShinCache")
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) throws {
        let data = try JSONEncoder().encode(value)
        let nsData = data as NSData
        
        // Store in memory cache
        memoryCache.setObject(nsData, forKey: key as NSString)
        
        // Store on disk
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try data.write(to: fileURL)
        
        if let expiration = expiration {
            let expirationDate = Date().addingTimeInterval(expiration)
            let expirationData = try JSONEncoder().encode(expirationDate)
            try expirationData.write(to: fileURL.appendingPathExtension("expiration"))
        }
    }
    
    func get<T: Decodable>(forKey key: String) throws -> T? {
        // Check memory cache first
        if let cachedData = memoryCache.object(forKey: key as NSString) {
            return try JSONDecoder().decode(T.self, from: cachedData as Data)
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        // Check expiration
        let expirationURL = fileURL.appendingPathExtension("expiration")
        if fileManager.fileExists(atPath: expirationURL.path),
           let expirationData = try? Data(contentsOf: expirationURL),
           let expirationDate = try? JSONDecoder().decode(Date.self, from: expirationData),
           Date() > expirationDate {
            try? fileManager.removeItem(at: fileURL)
            try? fileManager.removeItem(at: expirationURL)
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let value = try JSONDecoder().decode(T.self, from: data)
        
        // Update memory cache
        memoryCache.setObject(data as NSData, forKey: key as NSString)
        
        return value
    }
    
    func remove(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: fileURL.appendingPathExtension("expiration"))
    }
    
    func clear() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
} 