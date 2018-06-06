import XCTest
@testable import EventHub

final class EventHubTests: XCTestCase {
    
    private var eventHub: EventHub = EventHub(queue: .global())
    
    struct IncrementCounterEvent: Event {
        var incrementation: Int
    }
    
    struct DeductingCounterEvent: Event {
        var deduct: Int
    }
    
    class CounterWasIncrementedListener: Listener<IncrementCounterEvent> {
        
        private var callback: (IncrementCounterEvent) -> ()
        
        init(callback: @escaping (IncrementCounterEvent) -> ()) {
            self.callback = callback
        }
        
        override func handle(event: EventHubTests.IncrementCounterEvent) {
            self.callback(event)
        }
    }
    
    override func setUp() {
        // Overwriting on each test, to clear it
        self.eventHub = EventHub(queue: .global())
    }

    func testCallbackWasCalledAfterEventFire() {
        let expectation = self.expectation(description: "Should recieve event on trigger")
        
        var count: Int = 0
        let incrementBy: Int = 5
        var recievedIncrementation: Int = 0
        
        let _ = eventHub.subscribe { (event: IncrementCounterEvent) in
            count += event.incrementation
            recievedIncrementation = event.incrementation
            
            expectation.fulfill()
        }
        
        eventHub.trigger(event: IncrementCounterEvent(incrementation: incrementBy))
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(recievedIncrementation, incrementBy)
        XCTAssertEqual(count, incrementBy)
    }
    
    func testEventsWasDistributedToAllCallbacks() {
        var count: Int = 0
        let incrementBy: Int = 20
        let iterations: Int = 3
        
        for i in 1...iterations {
            let expectation = self.expectation(description: "Can fire event to multiple callbacks - Iteration \(i)")
            
            let _ = eventHub.subscribe { (event: IncrementCounterEvent) in
                count += event.incrementation
                
                expectation.fulfill()
            }
        }
        
        eventHub.trigger(event: IncrementCounterEvent(incrementation: incrementBy))
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(count, incrementBy * iterations)
    }
    
    func testMultipleTypesOfEvents() {
        var count: Int = 0
        
        let incrementBy: Int = 20
        let incrementEvent = IncrementCounterEvent(incrementation: incrementBy)
        var recievedIncrementation: Int = 0
        let incrementExpectation = self.expectation(description: "Should recieve IncrementEvent")
        
        let deductBy: Int = -10
        let deductEvent = DeductingCounterEvent(deduct: deductBy)
        var recievedDeductation: Int = 0
        let deductExpectation = self.expectation(description: "Should recieve DeductingEvent")
        
        let _ = eventHub.subscribe { (event: IncrementCounterEvent) in
            recievedIncrementation = event.incrementation
            count += event.incrementation
            
            incrementExpectation.fulfill()
        }
        
        let _ = eventHub.subscribe { (event: DeductingCounterEvent) in
            recievedDeductation = event.deduct
            count += event.deduct
            
            deductExpectation.fulfill()
        }
        
        eventHub.trigger(event: incrementEvent)
        eventHub.trigger(event: deductEvent)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(count, incrementBy + deductBy)
        XCTAssertEqual(recievedIncrementation, incrementBy)
        XCTAssertEqual(recievedDeductation, deductBy)
    }
    
    func testListenerWasCalledAfterEventFire() {
        let expectation = self.expectation(description: "Should recieve IncrementEvent in Listener")
        
        var count: Int = 0
        let incrementBy: Int = 20
        var recievedIncrementation: Int = 0
        
        let listener: CounterWasIncrementedListener = CounterWasIncrementedListener { event in
            count += event.incrementation
            recievedIncrementation = event.incrementation
            
            expectation.fulfill()
        }
        
        let _ = eventHub.subscribe(with: listener)
        
        eventHub.trigger(event: IncrementCounterEvent(incrementation: incrementBy))
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(recievedIncrementation, incrementBy)
        XCTAssertEqual(count, incrementBy)
    }


    static var allTests = [
        ("testCallbackWasCalledAfterEventFire", testCallbackWasCalledAfterEventFire),
        ("testEventsWasDistributedToAllCallbacks", testEventsWasDistributedToAllCallbacks),
        ("testMultipleTypesOfEvents", testMultipleTypesOfEvents),
        ("testListenerWasCalledAfterEventFire", testListenerWasCalledAfterEventFire)
    ]
}
