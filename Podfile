source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

target "iTHU" do
    pod 'ChameleonFramework/Swift'
    pod 'Alamofire', '3.5.1'
    pod 'RealmSwift', '2.0.2'
    pod 'Eureka', '1.7.0'
    pod 'Fuzi', '0.4.0'
    pod 'TextFieldEffects', '1.2.0'
    pod 'EasyTipView', '1.0.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end

