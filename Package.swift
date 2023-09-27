// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Monetizr",
    defaultLocalization: "en",
    platforms: [
    .iOS(.v13)
    ],
    products: [
    .library(
        name: "Monetizr",
        targets: ["Monetizr"]
        ),
    ],
    dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
    .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.0.0"),
    .package(url: "https://github.com/stripe/stripe-ios.git", from: "23.0.0"),
    // TODO: Switch back to the original branch once it supports SPM
    // .package(url: "https://github.com/kmcgill88/McPicker-iOS", from: "3.0.0")
    .package(url: "https://github.com/lukemmtt/McPicker-iOS.git", .branch("master"))

    ],
    targets: [
    .target(
        name: "Monetizr",
        dependencies: [
        "Alamofire",
        "AlamofireImage",
        .product(name: "McPicker", package: "McPicker-iOS"),
        .product(name: "Stripe", package: "stripe-ios"),
        ],
        path: "Monetizr-SDK",
        resources: [
        .copy("country-data.json"),
        .copy("Assets"),
        // TODO: *.lproj doesn't work, find a more generalized way to do this
        // Perhaps move lproj files to a directory
        .copy("af.lproj"),
        .copy("da.lproj"),
        .copy("de.lproj"),
        .copy("en.lproj"),
        .copy("es-AR.lproj"),
        .copy("es-MX.lproj"),
        .copy("es-UY.lproj"),
        .copy("es.lproj"),
        .copy("fr.lproj"),
        .copy("he.lproj"),
        .copy("it.lproj"),
        .copy("ja.lproj"),
        .copy("ka-GE.lproj"),
        .copy("ka.lproj"),
        .copy("ko.lproj"),
        .copy("nb.lproj"),
        .copy("nl.lproj"),
        .copy("pl-PL.lproj"),
        .copy("pt-BR.lproj"),
        .copy("pt-PT.lproj"),
        .copy("ru.lproj"),
        .copy("sl.lproj"),
        .copy("tr.lproj")
        ]
    )],
    swiftLanguageVersions: [.version("5")]
    )
