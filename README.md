![GitHub release](https://img.shields.io/badge/release-3.0.1-blue.svg)
# TheMonetizr SDK
### Useful links

* [API reference] (https://api3.themonetizr.com/docs)
* [Integration guide] (https://docs.themonetizr.com/api/index.html)

### Usage

In applicationDidFinishLaunching(_:) do the initialization with token provided to you

```
Monetizr.shared.token = ""
```

Optionally you can set languge - might not be availeble, check with Monetizr team

```
Monetizr.shared.setLanguage(language: "en_EN")
```

To show product or to get product data and show in your custom view

```
Monetizr.shared.getProductForTag(tag: merchTagField.text!, show: true) { success, error, product in ()}
```