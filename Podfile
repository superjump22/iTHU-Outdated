source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

target "iTHU" do
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git', :tag => '2.2.0'
    pod 'Alamofire', '~> 4.0.0'
    pod 'RealmSwift', '~> 2.0.2'
    pod 'Eureka', '~> 2.0.0-beta.1'
    pod 'Fuzi', '~> 1.0.0'
    pod 'TextFieldEffects', '~> 1.3.0'
    pod 'EasyTipView', '~> 1.0.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

