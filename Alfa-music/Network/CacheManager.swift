import Foundation


struct CacheEntry<Value> {
    let value: Value
    let expirationTime: Date
    
    func isExpired() -> Bool {
        return Date() > expirationTime
    }
}


final class CacheManager<Key: Hashable, Value> {
    private var cache: [Key: CacheEntry<Value>] = [:]
    private let ttl: TimeInterval
    
    init(ttl: TimeInterval = 300) {
        self.ttl = ttl
    }
    
    func set(_ value: Value, forKey key: Key) {
        let expirationTime = Date().addingTimeInterval(ttl)
        cache[key] = CacheEntry(value: value, expirationTime: expirationTime)
    }
    
    func get(forKey key: Key) -> Value? {
        guard let entry = cache[key] else { return nil }
        
        if entry.isExpired() {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    func clear() {
        cache.removeAll()
    }
    
    func clearExpired() {
        cache = cache.filter { !$0.value.isExpired() }
    }
}
