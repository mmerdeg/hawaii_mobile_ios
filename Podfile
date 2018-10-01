# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def common_pods_for_target
    pod 'SwiftLint'
    pod 'JTAppleCalendar'
    pod 'Swinject'
    pod 'SwinjectStoryboard'
    pod 'YLProgressBar'
    pod 'CodableAlamofire'
    pod 'PocketSVG'
    pod 'Kingfisher'
    pod 'FMDB'
    pod 'GoogleSignIn'
end

target 'Hawaii' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

common_pods_for_target
  # Pods for Hawaii

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

  common_pods_for_target

  # Pods for Hawaii production

end
