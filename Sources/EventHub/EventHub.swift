import Foundation

final class EventHub {
    
    typealias Callback<T: Event> = (T) -> ()
    
    private let queue: DispatchQueue
    private var subscriptions: [Subscriber]
    
    init(queue: DispatchQueue) {
        self.queue = queue
        self.subscriptions = [Subscriber]()
    }
    
    public func subscribe<T: Event>(with callback: @escaping Callback<T>) -> String {
        return self.observe(with: callback, as: .callback)
    }
    
    public func subscribe<T: Event>(with listener: Listener<T>) -> String {
        return self.observe(with: listener, as: .listener)
    }
    
    public func unsubscribe(identifier: String) {
        self.subscriptions = self.subscriptions.filter { $0.identifier != identifier }
    }
    
    public func trigger<T: Event>(event: T) {
        self.subscriptions.forEach { subscriber in
            self.queue.async {
                self.notify(a: subscriber, of: event)
            }
        }
    }
    
    private func observe(with handler: Any, as type: SubscriptionType) -> String {
        let uuid: String = UUID().uuidString
        
        self.subscriptions.append(Subscriber(identifier: uuid, handler: handler, type: type))
        
        return uuid
    }
    
    private func notify<T: Event>(a subscriber: Subscriber, of event: T) {
        if subscriber.type == .listener {
            guard let handler = subscriber.handler as? Listener<T> else {
                return
            }
            
            handler.handle(event: event)
            
            return
        }
        
        // If the subscriber handler is a callback, try to unwrap it as a callback
        guard let handler = subscriber.handler as? Callback<T> else {
            return
        }
        
        handler(event)
    }
}
