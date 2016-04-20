platform :ios, '8.0'
use_frameworks!

source 'https://github.com/appodeal/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'CubesGame' do
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
    pod 'ASCFlatUIColor'
    pod 'SwiftRandom'
    
#    pod 'Google-Mobile-Ads-SDK', '~> 7.0'
    
    pod 'Appodeal', '~> 0.5' # for XCODE 7
    
#    pod 'Fabric'
#    pod 'Answers'
#    pod 'Crashlytics'
end

# idk if this is needed to fix the Appodeal situation
post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
