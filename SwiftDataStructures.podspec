Pod::Spec.new do |s|
  s.name             = "SwiftDataStructures"
  s.version          = "0.1.0"
  s.summary          = "Data structures in Swift, including a Trie, Tree, List, and Deque"
  s.description      = "SwiftDataStructures is a framework of commonly-used data structures for Swift. Included: Deque, List, Trie, Tree"
  s.homepage         = "https://github.com/oisdk/SwiftDataStructures"
  s.license          = 'MIT'
  s.author           = { "Donnacha Oisin Kidney" => "https://github.com/oisdk" }
  s.source           = { :git => "https://github.com/oisdk/SwiftDataStructures.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oisdk'

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'SwiftDataStructures/*.swift'
end
