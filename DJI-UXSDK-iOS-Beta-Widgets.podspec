Pod::Spec.new do |s|
  s.name = 'DJI-UXSDK-iOS-Beta-Widgets'
  s.version = '0.2'
  s.license = 'MIT'
  s.summary = 'A collection of widget, widget model, and related helpers for DJI iOS UX SDK.'
  s.homepage = 'https://github.com/dji-dev/Open-Source-UXSDK-iOS'
  s.authors = { 'DJI' => 'dev@dji.com' }
  s.documentation_url = 'https://github.com/dji-dev/Open-Source-UXSDK-iOS/wiki'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.module_name = 'DJIUXSDKWidgets'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load' } 
  s.source = { :git => 'https://github.com/dji-dev/Open-Source-UXSDK-iOS.git', :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'DEFINES_MODULE' => 'YES' }
  s.cocoapods_version = '>= 1.7.1'
  s.source_files = 'DJIUXSDKWidgets/**/*.{h,m,swift}'
  s.resource_bundle = { 'DUXBetaAssets' => 'DJIUXSDKWidgets/**/*.{xcassets,html,otf}' }
  s.dependency 'DJI-SDK-iOS', '~> 4.12'
  s.dependency 'DJIWidget', '~> 1.6.2'
  s.dependency 'DJI-UXSDK-iOS-Beta-Core', '0.2'
  s.dependency 'DJI-UXSDK-iOS-Beta-Communication', '0.2'
end