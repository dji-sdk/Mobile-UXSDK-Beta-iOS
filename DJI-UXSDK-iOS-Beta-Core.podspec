Pod::Spec.new do |s|
  s.name = 'DJI-UXSDK-iOS-Beta-Core'
  s.version = '0.4.0'
  s.license = 'MIT'
  s.summary = 'Core utilities for DJI iOS UX SDK.'
  s.homepage = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS'
  s.authors = { 'DJI' => 'dev@dji.com' }
  s.documentation_url = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS/wiki'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.swift_version = '5.0'
  s.module_name = 'UXSDKCore'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load' } 
  s.source = { :git => 'ssh://git@us003.fly-access.com:7999/msdk/ios-uxsdk-os.git', :branch => "feature/UX-6717" }
  #s.source = { :git => 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS.git', :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'DEFINES_MODULE' => 'YES'}
  s.cocoapods_version = '>= 1.7.1'
  s.source_files = 'UXSDKCore/**/*.{h,m,swift}'
  s.resource_bundle = { 'UXSDKCoreAssets' => 'UXSDKCore/**/*.{xcassets,html,otf}' }
  s.dependency 'DJI-SDK-iOS', '~> 4.13.1'
  s.dependency 'DJIWidget', '~> 1.6.3'
end