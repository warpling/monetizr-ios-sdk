Pod::Spec.new do |s|
  s.name             = 'Monetizr'
  s.version          = '3.4.1'
  s.summary          = 'Platform to Sell Game Gear from Inside the Game UI'
 
  s.description      = <<-DESC
Monetizr™ is a turn-key solution enabling game developers and game IP holders to sell personalized game gear from inside the game’s UI and create meta-experiences for high-value players. Give players more than they expect!
                       DESC
 
  s.homepage         = 'https://www.themonetizr.com'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { '© Monetizr' => 'info@themonetizr.com' }
  s.source           = { :git => 'https://github.com/themonetizr/monetizr-ios-sdk.git', :tag => s.version.to_s }
 
  s.swift_version = "5.0"
  s.ios.deployment_target = '10.0'
  s.source_files = 'Monetizr-SDK/*'
  s.resources = ['Monetizr-SDK/*.lproj', 'Monetizr-SDK/*.json', 'Monetizr-SDK/Assets/*']

  s.framework = "UIKit"
  s.framework = "PassKit"
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'ImageSlideshow/Alamofire'
  s.dependency 'ImageSlideshow', '~> 1.8'
  s.dependency 'Mobile-Buy-SDK'
  s.dependency 'McPicker'
 
end