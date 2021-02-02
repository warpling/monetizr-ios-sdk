Pod::Spec.new do |s|
  s.name             = 'Monetizr'
  s.version          = '3.5.8'
  s.summary          = 'Platform to Sell Game Gear from Inside the Game UI'
 
  s.description      = <<-DESC
Monetizr is a turn-key platform for game developers enabling to sell or give-away game gear right inside the game's UI. You can use this SDK in your game to let players purchase products or claim gifts within the game. All orders made with Monetizr automatically initiates fulfillment and shipping. More info: https://docs.themonetizr.com/docs/get-started.
                       DESC
 
  s.homepage         = 'https://www.themonetizr.com'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { '© Monetizr' => 'info@themonetizr.com' }
  s.source           = { :git => 'https://github.com/themonetizr/monetizr-ios-sdk.git', :tag => s.version.to_s }
 
  s.swift_version = "5.0"
  s.ios.deployment_target = '11.0'
  s.source_files = ['Monetizr-SDK/*.{swift}', 'Monetizr-SDK/**/*.{swift}']
  s.resources = ['Monetizr-SDK/*.lproj', 'Monetizr-SDK/*.json', 'Monetizr-SDK/Assets/*']

  s.framework = "UIKit"
  s.framework = "PassKit"
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'Stripe'
  s.dependency 'McPicker'
 
end