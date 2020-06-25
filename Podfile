platform :ios, '13.0'
swift_version= '5.0'

target 'Camera' do
  use_frameworks!
  pod 'LicensePlist'

  inhibit_all_warnings!
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/MLVision'
  pod 'Firebase/MLVisionAutoML'
  pod 'Firebase/MLVisionObjectDetection'
  pod 'Firebase/MLVisionBarcodeModel'
  pod 'Firebase/MLVisionFaceModel'
  pod 'Firebase/MLVisionLabelModel'
  pod 'Firebase/MLVisionTextModel'

  target 'CameraTests' do
    inherit! :search_paths
  end

  # (XcodeGen+CocoaPodsの組み合わせ)=>FabricのscriptをCocoapods最後に呼ぶ
  script_phase :name => 'Crashlytics',
               :script => '"${PODS_ROOT}/FirebaseCrashlytics/run"'
end

target 'Environments' do
  use_frameworks!
end

target 'Logger' do
  use_frameworks!
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end