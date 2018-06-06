#  Swift EventHub

Simple implementation of an EventHub in Swift.
Supports callbacks and listeners.

## Installation
With CocoaPods:
```
pod 'SwiftEventHub'
```

## Requirements
Swift 4.1

## Examples

### Callback

```swift 
struct CounterEvent: Event {
    let currentCount: Int
}

let eventHub = EventHub(queue: .global())
eventHub.subscribe { (event: CounterEvent)
    print(event.currentCount) // => 5
}

eventHub.trigger(CounterEvent(currentCount: 5))
```

### Listener
```swift 
struct SomeErrorEvent: Event {
    let message: String
    let code: Int 
}

class NotifyAdminListener: Listener<SomeErrorEvent> {
    override func handle(event: SomeErrorEvent) {
        print("Oh no! We got error \(error.code) with the message '\(error.message)'")
    }
}

let eventHub = EventHub(queue: .global())
eventHub.subscribe(NotifyAdminListener())
eventHub.trigger(SomeErrorEvent(message: "Fatal and dangerous error", code: 500))
```

## Usage
1. Import the library
```swift
import SwiftEventHub
```
2. Initialize the EventHub class on a `DispatchQueue`. Add the `EventHub` to a global scope (e.g. shared instance), for cross-events/listeners, or use it in an internal scope
```swift 
let hub = EventHub(queue: .global())
```
3. Define events by making them comply to the `Event` protocol

```swift
struct MyEvent: Event {}
```

4. Subscribe to the events either by callback or listener (see examples above)
```swift 
hub.subscribe { (event: MyEvent) in 
    // Do something with the event
}
```

5. Trigger events by calling the method `.trigger(event: Event)`
```swift
hub.trigger(MyEvent())
```

6. The events triggered are distributed to all listeners attached to the hub, listening for that specific event.

7. To unsubscribe, the returned UUID from the `.subscribe` method, can be used
```swift 
let subscription = hub.subscribe { // ... }
hub.unsubscribe(subscription)
```


