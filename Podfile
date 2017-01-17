source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

target "iTsinghua" do
    pod 'Alamofire', '~> 4.0.1'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'RealmSwift', '~> 2.0.3'
    pod 'SwiftMessages', '~> 3.0.3'
    pod 'Eureka', '~> 2.0.0-beta.1'
    pod 'Fuzi', '~> 1.0.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

