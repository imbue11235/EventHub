Pod::Spec.new do |s|
  s.name             = 'SwiftEventHub'
  s.version          = '0.1.0'
  s.summary          = 'EventHub vfor swift'

  s.description      = <<-DESC
  Simple implementation of an EventHub in Swift. Supports callbacks and listeners.
                       DESC

  s.homepage         = 'https://github.com/imbue11235/EventHub'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'imbue11235' => 'kaspar.birk@gmail.com' }
  s.source           = { :git => 'https://github.com/imbue11235/EventHub.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/EventHub/*.swift'

end
