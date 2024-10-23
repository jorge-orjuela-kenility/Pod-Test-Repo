Pod::Spec.new do |spec|
  spec.name         = 'TruvideoSdkFoundation'
  spec.version      = '0.0.1'
  spec.summary      = 'A short description of your package'
  spec.description  = <<-DESC
		     TruvideoSdkFoundation is a versatile Swift framework that provides essential utilities and tools for iOS and macOS development. 
		     This package is designed to help developers build scalable, maintainable, and testable applications by offering a set of modular components.

		     Key Features:

		     - CoreDataKit: Simplifies Core Data integration, making it easier to manage persistent data across your app.
		     - Network Module: Provides a streamlined and reusable approach for handling network requests and responses.
		     - Logger: A robust logging system to track and manage application events for better debugging and monitoring.
		     - Extensions: A collection of useful Swift extensions that enhance standard library functionality.
		     - Error Handling: Standardized error management to improve resilience and reduce code duplication.
		     - Operators Module: Introduces custom operators to simplify and clarify complex operations.

		     Testing and CI Integration:

		     Well-structured unit tests covering all major components, ensuring code reliability and maintainability.
		     Mocks for efficient testing of network and Core Data operations.
		     Integrated Dangerfile for automated CI checks, enhancing code quality in collaborative environments.
		
		     Platform Support:

		     Supports iOS (from version 11.0) and macOS (from version 10.15), making it compatible with a wide range of Apple platforms.
		     Full integration with Swift Package Manager for easy project setup and modular integration.

                     DESC
  spec.homepage     = 'https://github.com/Truvideo/truvideo-sdk-ios-foundation-source'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Your Name' => 'developer@truvideo.com' }
  spec.source       = { :git => 'https://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@github.com/Truvideo/truvideo-sdk-ios-foundation-source.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '15.0'  # Adjust to the minimum iOS version supported by your package
  spec.swift_version = '5.10'
  spec.source_files  = 'Sources/**/*.{swift}'  # Points to your Swift package's source files
  spec.vendored_frameworks = 'https://github.com/Truvideo/truvideo-sdk-ios-core/releases/download/75.1.1-RC.135/TruvideoSDKCore.xcframework.zip'

  spec.subspec 'Testing' do |testing_spec|
    testing_spec.source_files = 'Testing/**/*.{swift}'
  end

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
    test_spec.resource_bundles = {
      'TestResources' => ['Tests/Resources/**/*']
    }
  end
end