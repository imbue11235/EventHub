open class Listener<T: Event> {
    public func handle(event: T) {
        fatalError("Subclasses must implement the handle method")
    }
}
