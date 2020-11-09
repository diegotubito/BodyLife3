# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/diegotubito/pods.git'
source 'https://github.com/CocoaPods/Specs.git'

def shared_pods
  pod 'Alamofire', '4.9.1'
  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  pod 'BLServerManager', '0.1.8'
 end

target 'Production-Target' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OSX-Version
  shared_pods

end

target 'Internal-Target' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OSX-Version
  shared_pods

end

