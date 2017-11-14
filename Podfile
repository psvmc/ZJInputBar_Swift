source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'ZJInputBar_Swift' do
	pod 'SnapKit', '~> 4.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end