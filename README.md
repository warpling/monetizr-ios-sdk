[![Version](https://img.shields.io/cocoapods/v/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)
[![License](https://img.shields.io/cocoapods/l/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)
[![Platform](https://img.shields.io/cocoapods/p/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)
# TheMonetizr SDK
### Useful links

* [API reference] (https://api3.themonetizr.com/docs)
* [API Integration guide] (https://docs.themonetizr.com/api/index.html)

### Dependencies
* [Alamofire - Elegant HTTP Networking in Swift] (https://github.com/Alamofire/Alamofire)
* [AlamofireImage - an image component library for Alamofire] (https://github.com/Alamofire/AlamofireImage)
* [ImageSlideshow - Swift image slideshow] (https://github.com/zvonicek/ImageSlideshow)

### Installation
Requires iOS 10.0+

#### CocoaPods

```swift
pod 'Monetizr', '~> 3.2'
```

#### Manual
```swift
Copy "Monetizr-SDK" folder to your project and resolve dependencies
```

Import "Monetizr" to your project

```swift
import Monetizr
```

### Usage

In applicationDidFinishLaunching(_:) do the initialization with token provided to you

```swift
Monetizr.shared.token = String
```
##### Apple Pay

If Apple Pay support is planned in applicationDidFinishLaunching(_:) set Merchant

```swift
Monetizr.shared.setApplePayMerchantID(id: String)
```

Optioanlly you can override default company and app name used in payment sheet

```swift
Monetizr.shared.setCompanyAndAppName(companyName: String, appName: String)
```

##### Themes:

Also you can set Product View theme (if not set Default .system would be used)

```swift
Monetizr.shared.setTheme(theme: ProductViewControllerTheme)
```


*.system - prior to iOS13 will be light theme with globalTint elements, on iOS13+ theme will use system Dark/Light mode preference and adopt to user selection.*

*.black - on all iOS versions and modes will look the same, it would be dark with red elements.*

#### Show product or get product data and show in your custom view. 

```swift
Monetizr.shared.showProduct(tag: String, presenter: UIViewController?, presentationStyle: UIModalPresentationStyle?) { success, error, product in ()}
```

If you choose to show product in a view provided in SDK you should provide presenter view and presentation style. If presentation style not provided it will be `UIModalPresentationStyle.automatic` for iOS 13.x or `UIModalPresentationStyle.overCurrentContext` for other iOS versions 

### Manual usage of *Monetizr.shared* with custom product views

Create Product View Controller

```func productViewForProduct(product: Product, tag: String) -> ProductViewController```

Present product View

```func presentProductView(productViewController: ProductViewController, presenter: UIViewController, presentationStyle: UIModalPresentationStyle)```

Checkout variant for product with tag

```swift
func checkoutSelectedVariantForProduct(selectedVariant: PurpleNode, tag: String, completionHandler: @escaping (Bool, Error?, Checkout?) -> Void)
```

Checkout with Apple Pay

```swift
Monetizr.shared.buyWithApplePay(selectedVariant: selectedVariant!, tag: tag!, presenter: UIViewController) { success, error in ()}
```

Increase impression count for session

```swift
func increaseImpressionCount()
```

Increase click count for session

```swift
func increaseClickCountInSession()
```

Increase checkout count for session

```swift
func increaseCheckoutCountInSession()
```

Get session duration in seconds

```swift
func sessionDurationSeconds() -> Int
```

Get session duration in miliseconds

```swift
func sessionDurationMiliseconds() -> Int
```

Telemetrics - Create a new entry for impressionvisible

```swift
func impressionvisibleCreate(tag: String?, fromDate:Date?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for clickreward

```swift
func clickrewardCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for design

```swift
func designCreate(numberOfTriggers: Int?, funnelTriggerList: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for dismiss

```swift
func dismissCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for install

```swift
func installCreate(deviceIdentifier: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for update

```swift
func updateCreate(deviceIdentifier: String, bundleVersion: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for firstimpression

```swift
func firstimpressionCreate(sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for playerbehaviour

```swift
func playerbehaviourCreate(deviceIdentifier: String, gameProgress: Int?, sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for purchase

```swift
func purchaseCreate(deviceIdentifier: String, triggerTag: String?, productPrice: String?, currency: String?, country: String?, city: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for session end

```swift
func sessionEnd(deviceIdentifier: String, startDate: String?, endDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for session start

```swift
func sessionCreate(deviceIdentifier: String, startDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for encounter

```swift
func encounterCreate(triggerType: String?, completionStatus: Int?, triggerTag: String?, levelName: String?, difficultyLevelName: String?, difficultyEstimation: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for firstimpressionclick

```swift
func firstimpressionclickCreate(firstImpressionClick: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for firstimpressioncheckout

```swift
func firstimpressioncheckoutCreate(firstImpressionCheckout: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```

Telemetrics - Create a new entry for firstimpressionpurchase

```swift
func firstimpressionpurchaseCreate(firstImpressionPurchase: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void)
```