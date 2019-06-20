Pod::Spec.new do |s|
  s.name = 'DJI-UXSDK-iOS-Beta-Core'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Core utilities for DJI iOS UX SDK.'
  s.homepage = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS'
  s.authors = { 'DJI' => 'dev@dji.com' }
  s.documentation_url = 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS/wiki'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.module_name = 'DJIUXSDKCore'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load' } 
  s.source = { :git => 'https://github.com/dji-sdk/Mobile-UXSDK-Beta-iOS.git', :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'DEFINES_MODULE' => 'YES', 'SWIFT_OBJC_BRIDGING_HEADER' => '$(PODS_TARGET_SRCROOT)/'}
  s.cocoapods_version = '>= 1.7.1'
  s.source_files = 'DJIUXSDKCore/**/*.{h,m}'
  s.public_header_files = 'DJIUXSDKCore/**/*.h'
  s.dependency 'DJI-SDK-iOS', '4.10'
  s.dependency 'DJI-UXSDK-iOS-Beta-Communication', '0.1.0'
end