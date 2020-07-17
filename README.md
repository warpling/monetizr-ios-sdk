[![Version](https://img.shields.io/cocoapods/v/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)
[![License](https://img.shields.io/cocoapods/l/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)
[![Platform](https://img.shields.io/cocoapods/p/Monetizr.svg?style=flat)](http://cocoapods.org/pods/Monetizr)

## What is Monetizr?
Monetizr is a turn-key platform for game developers enabling to sell or give-away game gear right inside the game's UI. You can use this SDK in your game to let players purchase products or claim gifts within the game.  All orders made with Monetizr automatically initiates fulfillment and shipping. More info: https://docs.themonetizr.com/docs/get-started.
 
## Monetizr iOS SDK
Monetizr iOS SDK is a plugin with the built-in functionality of:
- showing image carousel and fullscreen pictures in offers to end-users;
- HTML texts for descriptions;
- allowing end-users to select product variant options;
- displaying price in real or in-game currency (including discounts);
- checkout and payment support;
- Apple Pay support (optional).

Monetizr uses oAuth 2 authentication behind the scenes for all payment and order related processes. The SDK takes care of managing oAuth 2. To use SDK and connect to Monetizr servers, all you need is a single API key. It can be retrieved via Monetizr web [Console][1]. API is a public two-way, it does not expose any useful information, but you should be aware of this.

Read the Monetizr's [iOS documentation][2] to find out more.

## Installation
Requires iOS 10.0+

### Dependencies
* [Alamofire][8] - Elegant HTTP Networking in Swift;
* [AlamofireImage][9] - an image component library for Alamofire;
* [ImageSlideshow][10] - Swift image slideshow;
* [Stripe][11] - lets users buy products using Apple Pay;
* [McPicker][12] - UIPickerView drop-in solution.

### Option 1 (suggested)
**CocoaPods:**

```swift
pod 'Monetizr', '~> 3.5'
```

### Option 2

Copy "Monetizr-SDK" folder to your project and resolve dependencies. Import "Monetizr" to your project:

```swift
import Monetizr
```

## Using the library in your app

To use the SDK you need an [API key][3]. For testing purposes, you can use public test key `4D2E54389EB489966658DDD83E2D1`.

In applicationDidFinishLaunching(_:) do the initialization with the API key:

```swift
Monetizr.shared.token = "4D2E54389EB489966658DDD83E2D1"
```

To show a product in an [Offer View][4], you need to call a specific product_tag. Product tags represent a specific product, and they are managed in the web Console. For testing purposes, you can use public test product `T-shirt`.

Show an Offer View inside your app:

```swift
Monetizr.shared.showProduct(tag: "T-shirt", playerID: String(Optional) presenter: UIViewController?, presentationStyle: UIModalPresentationStyle?) { success, error, product, uniqueID in ()}
```

If you choose to show a product in an Offer View provided in the SDK, you should provide a presenter view and presentation style. If presentation style is not provided it will default to `UIModalPresentationStyle.automatic` for iOS 13.x or `UIModalPresentationStyle.overCurrentContext` for other iOS versions.

Implement `MonetizrDelegate` to get notified about events in Monetizr:

* Offer View exposure whenever purchase is made

```swift
func monetizrPurchase(tag: String?, uniqueID: String?)
```

## Optional settings

### Apple Pay

To use Apple Pay payments in applicationDidFinishLaunching(_:) set your [Merchant ID][5]:

```swift
Monetizr.shared.setApplePayMerchantID(id: String)
```

Additionally, you can override the default payment receiver name (app bundle name) that is used in the Apple payment sheet. It changes the displayed payment receiver that end-users see on their receipts.

```swift
Monetizr.shared.setCompanyName(companyName: String)
```

Learn more about setting up Apple Pay for Monetizr integrations [here][6].

### Themes

Set to .system by default. You can customize Offer View theme:

```swift
Monetizr.shared.setTheme(theme: ProductViewControllerTheme)
```

Versions up to iOS13 .system uses light theme with globalTint elements.
Versions iOS13+ uses .system uses Dark/Light mode preference and adapts to user selection.

*.black - on all iOS versions and modes is set to dark with red elements.*

### Monetizr.shared customization

Create ProductView Controller:

```swift
func productViewForProduct(product: Product, tag: T-shirt, playerID: String(Optional)) -> ProductViewController
```

Present ProductView:

```swift
func presentProductView(productViewController: ProductViewController, presenter: UIViewController, presentationStyle: UIModalPresentationStyle)
```

Checkout for product [variant][7].

```swift
func checkoutSelectedVariantForProduct(selectedVariant: PurpleNode, tag: T-shirt, shippingAddress: CheckoutAddress(Optional) completionHandler: @escaping (Bool, Error?, Checkout?) -> Void)
```

Update checkout

```swift
func updateCheckout(request: UpdateCheckoutRequest, completionHandler: @escaping (Bool, Error?, CheckoutResponse?) -> Void)
```

Claim order

```swift
func claimOrder(shippingLine: CheckoutData?, player_id: String, price: String, completionHandler: @escaping (Bool, Error?, Claim?) -> Void)
```

Checkout with Apple Pay:

```swift
Monetizr.shared.buyWithApplePay(selectedVariant: selectedVariant!, tag: T-shirt!, presenter: UIViewController) { success, error in ()}
```

[1]: https://app.themonetizr.com/
[2]: https://docs.themonetizr.com/docs/ios
[3]: https://docs.themonetizr.com/docs/creating-account#section-your-unique-access-token
[4]: https://docs.themonetizr.com/docs/offer-view
[5]: https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay_requirements
[6]: https://docs.themonetizr.com/docs/apple-pay-setup
[7]: https://docs.themonetizr.com/docs/creating-offer-view#section-create-product-option-selectors
[8]: https://github.com/Alamofire/Alamofire
[9]: https://github.com/Alamofire/AlamofireImage
[10]: https://github.com/zvonicek/ImageSlideshow
[11]: https://github.com/stripe/stripe-ios
[12]: https://github.com/kmcgill88/McPicker-iOS
