# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
inhibit_all_warnings!
def common_pods_for_target
    pod 'SwiftLint'
    pod 'JTAppleCalendar'
    pod 'Swinject'
    pod 'SwinjectStoryboard'
    pod 'YLProgressBar'
#    pod 'SwiftEntryKit', '0.7.2'
    pod 'CodableAlamofire'
    pod 'PocketSVG'
    pod 'Kingfisher'
    pod 'FMDB'
    pod 'GoogleSignIn'
    pod 'EKBlurAlert'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
end

target 'Hawaii' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hawaii
common_pods_for_target

  target 'HawaiiTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HawaiiUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Hawaii production' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hawaii production
common_pods_for_target

end

target 'RequestNotification' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RequestNotification
common_pods_for_target

end
