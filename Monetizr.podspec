Pod::Spec.new do |s|
  s.name             = 'Monetizr'
  s.version          = '3.1.1'
  s.summary          = 'Monetizr is a game reward engine, we drive revenue to your business and enhance the experience of your players!'
 
  s.description      = <<-DESC
Monetizr rewards your users with an opportunity to unlock and buy your own game merchandise (t-shirts, hats, 3d-figurines, decals, and 40+ other products), gift cards (Amazon, Apple, etc.), and even brand sponsored rewards (from brands that fit your core audience and goes well with the narrative of the game). How you want to monetize, you decide!
                       DESC
 
  s.homepage         = 'https://www.themonetizr.com'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { '© Monetizr' => 'info@themonetizr.com' }
  s.source           = { :git => 'https://github.com/themonetizr/monetizr-ios-sdk.git', :tag => s.version.to_s }
 
  s.swift_version = "5.0"
  s.ios.deployment_target = '10.0'
  s.source_files = 'Monetizr-SDK/*'
  s.resource_bundles = { 'Monetizr' => ['Monetizr-SDK/*.{lproj, xcassets)'] }

  s.framework = "UIKit"
  s.framework = "PassKit"
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'ImageSlideshow/Alamofire'
  s.dependency 'ImageSlideshow', '~> 1.8'
 
end