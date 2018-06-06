extension EventHub {
    internal struct Subscriber {
        public let identifier: String
        public let handler: Any
        public let type: SubscriptionType
    }
}
