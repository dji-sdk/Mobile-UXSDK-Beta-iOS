Pod::Spec.new do |s|
  s.name = 'DJI-UXSDK-iOS-Beta'
  s.version = '0.4'
  s.license = 'MIT'
  s.summary = 'DJI iOS UX SDK'
  s.homepage = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS'
  s.authors = { 'DJI' => 'dev@dji.com' }
  s.documentation_url = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS/wiki'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.swift_version = '5.0'
  s.module_name = 'DJIUXSDKBeta'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load' } 
  s.source = { :git => 'ssh://git@us003.fly-access.com:7999/msdk/ios-uxsdk-os.git', :branch => "feature/UX-6717" }
  #s.source = { :git => 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS.git', :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'DEFINES_MODULE' => 'YES'}
  s.cocoapods_version = '>= 1.7.1'
  s.source_files = 'DJIUXSDKBeta/**/*.{h,m,swift}'
  s.dependency 'DJI-UXSDK-iOS-Beta-Core', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-CameraCore', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-Flight', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-Accessory', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-Map', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-Media', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-Training', '0.4'
  s.dependency 'DJI-UXSDK-iOS-Beta-VisualCamera', '0.4'
end