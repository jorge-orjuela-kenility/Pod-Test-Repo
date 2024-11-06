Pod::Spec.new do |spec|
  spec.name         = 'TruvideoSdkFoundation'
  spec.version      = '0.0.1'
  spec.summary      = 'A versatile Swift framework that provides essential utilities and tools for iOS development.'
  spec.description  = 'A versatile Swift framework that provides essential utilities and tools for iOS development. This package is designed to help developers build scalable, maintainable, and testable applications by offering a set of modular components.'
  spec.homepage     = 'https://www.kenility.com/'
  spec.license      = 'MIT'
  spec.author       = 'TruVideo'
  spec.source       = { :git => "https://#{ENV['PAT_TOKEN']}@github.com/jorge-orjuela-kenility/Pod-Test-Repo.git", :tag => spec.version.to_s }
  spec.platform     = :ios, '15.0'
  spec.swift_version = '5.0'

  spec.source_files = 'Sources/**/*.{swift}'
  spec.vendored_frameworks = 'shared.xcframework'

end
