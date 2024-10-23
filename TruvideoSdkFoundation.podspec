Pod::Spec.new do |spec|
  spec.name         = 'TruvideoSdkFoundation'
  spec.version      = '0.0.1'
  spec.summary      = 'A versatile Swift framework that provides essential utilities and tools for iOS development.'
  spec.description  = 'A versatile Swift framework that provides essential utilities and tools for iOS development. This package is designed to help developers build scalable, maintainable, and testable applications by offering a set of modular components.'
  spec.homepage     = 'https://www.kenility.com/'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Your Name' => 'developer@truvideo.com' }
  spec.source       = { :git => 'https://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@github.com/jorge-orjuela-kenility/Pod-Test-Repo.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '15.0'  # Minimum iOS version supported
  spec.swift_version = '5.0'
  
  # Points to the source files of the Swift package
  spec.source_files  = 'Sources/**/*.{swift}'

  # Points to the vendored framework URL
  spec.vendored_frameworks = 'shared.xcframework'

  # Subspec for Testing related components
  #spec.subspec 'Testing' do |testing_spec|
    #testing_spec.source_files = 'Testing/**/*.{swift}'
    #testing_spec.vendored_frameworks = 'TruvideoSdk.xcframework'
  #end

  # Test specification for unit tests
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
    test_spec.resource_bundles = {
      'TestResources' => ['Tests/Resources/**/*']
    }
  end
end