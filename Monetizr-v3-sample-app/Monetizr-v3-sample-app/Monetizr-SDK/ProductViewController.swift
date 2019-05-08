//
//  ProductViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ImageSlideshow

class ProductViewController: UIViewController, ActivityIndicatorPresenter {
    
    var activityIndicator = UIActivityIndicatorView()
    var tag: String?
    var product: Product?
    var selectedVariant: PurpleNode?
    var variantCount = 0
    var variants: [VariantsEdge] = []
    var imageLinks: NSMutableArray = []
    
    // Outlets
    let closeButton = UIButton()
    let checkoutButtonBackgroundView = UIView()
    let checkoutButton = UIButton()
    let variantOptionsContainerView = UIView()
    let imageCarouselContainerView = UIView()
    let descriptionContainerView = UIView()
    let priceLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionTextView = UITextView()
    let slideShow = ImageSlideshow()
    let variantOptionDisclosureView = UIImageView()
    let optionsTitleLabel = UILabel()
    var optionsTapGesture = UITapGestureRecognizer()
    var optionsSelectorOverlayView = UIView()
    var optionsSelectorOverlayTapGesture = UITapGestureRecognizer()
    let optionsSelectorPlaceholderView = UIView()
   // let variantSelectionViewController = VariantSelectionViewController()
    
    // Constraints
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var checkoutButtonBackgroundViewConstraint = NSLayoutConstraint()
    private var imageCarouselContainerViewHeightConstraint = NSLayoutConstraint()
    private var imageCarouselContainerViewWidthConstraint = NSLayoutConstraint()
    
    // Size values
    var bottomPadding: CGFloat = 0
    var topPadding: CGFloat = 0
    var viewHeight: CGFloat = 0
    var viewWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // Load product
        self.loadProductData()
        
        // Checkout button
        self.configureCheckOutButton()
        
        // Variant option selection container view
        self.configureVariantOptionsContainerView()
        
        // Image carousel
        self.configureImageCarouselContainerView()
        
        // Description container view
        self.configureDescriptionContainerView()
        
        // Close button
        self.configureCloseButton()
        
        // Configure price tag
        self.configurePriceTagLabel()
        
        // Configure title label
        self.configureTitleLabel()
        
        // Configure description text
        self.configureDescriptionTextView()
        
        // Configure image slider
        self.configureImageSlider()
        
        // Configure options selector
        self.configureOptionsTitleLabel()
        
        // Update views data
        self.updateViewsData()
        
        // Setup constraints
        self.configureSharedConstraints()
        self.configureCompatConstraints()
        self.configureRegularConstraints()
        self.activateInitialConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func activateInitialConstraints() {
        let window = UIApplication.shared.keyWindow
        viewHeight = view.frame.size.height
        viewWidth = view.frame.size.width
        
        if #available(iOS 11.0, *) {            
            topPadding = (window?.safeAreaInsets.top)!
            bottomPadding = (window?.safeAreaInsets.bottom)!
        }
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint.constant = 70+bottomPadding
        
        self.configureConstraintsForCurrentOrietnation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewWidth = size.width
        viewHeight = size.height
        coordinator.animate(alongsideTransition: { (context) in
            //
            if #available(iOS 11.0, *) {
                self.topPadding = self.view.safeAreaInsets.top
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 11.0, *) {
                self.bottomPadding = self.view.safeAreaInsets.bottom
            } else {
                // Fallback on earlier versions
            }
            // Checkout buttons background
            self.checkoutButtonBackgroundViewConstraint.constant = 70+self.bottomPadding
            
            // Resize and position option selector view - do not do this if view is not in hierarchy
            self.optionsSelectorOverlayView.frame = CGRect(x: 0, y: 0, width: self.viewWidth, height: self.viewHeight)
            self.optionsSelectorPlaceholderView.center = self.optionsSelectorOverlayView.convert(self.optionsSelectorOverlayView.center, from:self.optionsSelectorOverlayView.superview)
            
        }, completion: nil)
        
        self.configureConstraintsForCurrentOrietnation()
    }
    
    func configureConstraintsForCurrentOrietnation() {
        if (!sharedConstraints[0].isActive) {
            // activating shared constraints
            NSLayoutConstraint.activate(sharedConstraints)
        }
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth/100*55
            
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            print("Portrait")
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // Image carousel container view
            imageCarouselContainerViewHeightConstraint.constant = viewHeight/100*55
            
            // Image carousel container view
            imageCarouselContainerViewWidthConstraint.constant = viewWidth
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    func configureSharedConstraints() {
        
        // Checkout buttons background
        checkoutButtonBackgroundViewConstraint = checkoutButtonBackgroundView.heightAnchor.constraint(equalToConstant: 70+bottomPadding)
        
        // Image carousel container view
        imageCarouselContainerViewHeightConstraint = imageCarouselContainerView.heightAnchor.constraint(equalToConstant: viewHeight/100*55)
        
        // Image carousel container view
        imageCarouselContainerViewWidthConstraint = imageCarouselContainerView.widthAnchor.constraint(equalToConstant: viewWidth/100*55)
        
        // Create shared constraints array
        sharedConstraints.append(contentsOf: [
            
            // Checkout buttons background
            checkoutButtonBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            checkoutButtonBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            checkoutButtonBackgroundViewConstraint,
            
            // Checkout button
            checkoutButton.topAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 10),
            checkoutButton.leftAnchor.constraint(equalTo: checkoutButtonBackgroundView.safeLeftAnchor, constant: 10),
            checkoutButton.rightAnchor.constraint(equalTo: checkoutButtonBackgroundView.safeRightAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Variant option selection container view
            variantOptionsContainerView.bottomAnchor.constraint(equalTo: checkoutButtonBackgroundView.topAnchor, constant: 0),
            variantOptionsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            variantOptionsContainerView.heightAnchor.constraint(equalToConstant: 55),
            
            // Option disclosure view
            variantOptionDisclosureView.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            variantOptionDisclosureView.rightAnchor.constraint(equalTo: variantOptionsContainerView.safeRightAnchor, constant: 0),
            variantOptionDisclosureView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            variantOptionDisclosureView.widthAnchor.constraint(equalToConstant: 40),
            
            // Variant title label
            optionsTitleLabel.topAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            optionsTitleLabel.leftAnchor.constraint(equalTo: variantOptionsContainerView.leftAnchor, constant: 10),
            optionsTitleLabel.rightAnchor.constraint(equalTo: variantOptionDisclosureView.leftAnchor, constant: 10),
            optionsTitleLabel.bottomAnchor.constraint(equalTo: variantOptionsContainerView.bottomAnchor, constant: 0),
            
            // Image carousel container view
            imageCarouselContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            imageCarouselContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageCarouselContainerViewWidthConstraint,
            imageCarouselContainerViewHeightConstraint,
            
            // Image slideshow
            slideShow.topAnchor.constraint(equalTo: imageCarouselContainerView.topAnchor, constant: 0),
            slideShow.leftAnchor.constraint(equalTo: imageCarouselContainerView.leftAnchor, constant: 0),
            slideShow.rightAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            slideShow.bottomAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            descriptionContainerView.bottomAnchor.constraint(equalTo: variantOptionsContainerView.topAnchor, constant: 0),
            
            // Price tag
            priceLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            priceLabel.rightAnchor.constraint(equalTo: descriptionContainerView.safeRightAnchor, constant: -10),
            priceLabel.heightAnchor.constraint(equalToConstant: 30),
            priceLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Product title
            titleLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Description text
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionTextView.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 10),
            descriptionTextView.rightAnchor.constraint(equalTo: descriptionContainerView.safeRightAnchor, constant: -10),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 0),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func configureCompatConstraints() {
        compactConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: imageCarouselContainerView.rightAnchor, constant: 0),
            ])
    }
    
    func configureRegularConstraints() {
        regularConstraints.append(contentsOf: [
            // Checkout buttons background
            checkoutButtonBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Variant option selection container view
            variantOptionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            
            // Description container view
            descriptionContainerView.topAnchor.constraint(equalTo: imageCarouselContainerView.bottomAnchor, constant: 0),
            descriptionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            ])
    }
    
    func configureCloseButton() {
        // Close button
        closeButton.closeProductButtonStyle()
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }
    
    func configureCheckOutButton() {
        // Checkout buttons background
        checkoutButtonBackgroundView.checkoutButtonBackgroundViewStyle()
        self.view.addSubview(checkoutButtonBackgroundView)
        
        // Checkout button
        checkoutButton.checkoutProductButtonStyle()
        checkoutButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(checkoutButton)
    }
    
    func configureVariantOptionsContainerView() {
        // Variant option selection container view
        variantOptionsContainerView.variantOptionsContainerViewStyle()
        self.view.addSubview(variantOptionsContainerView)
        
        // Handle taps
        optionsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        optionsTapGesture.numberOfTapsRequired = 1
        optionsTapGesture.numberOfTouchesRequired = 1
        variantOptionsContainerView.addGestureRecognizer(optionsTapGesture)
    }
    
    func configureVariantOptionDisclosure() {
        variantOptionDisclosureView.translatesAutoresizingMaskIntoConstraints = false
        variantOptionDisclosureView.backgroundColor = .clear
        variantOptionDisclosureView.image = UIImage.disclosureIndicator()
        variantOptionDisclosureView.contentMode = .center
        variantOptionsContainerView.addSubview(variantOptionDisclosureView)
    }
    
    func configureImageCarouselContainerView() {
        // Image carousel container view
        imageCarouselContainerView.imageCarouselContainerViewStyle()
        view.addSubview(imageCarouselContainerView)
    }
    
    func configureDescriptionContainerView() {
        // Description container view
        descriptionContainerView.descriptionContainerViewStyle()
        view.addSubview(descriptionContainerView)
    }
    
    func configurePriceTagLabel() {
        // Configure price tag
        priceLabel.priceLabelStyle()
        descriptionContainerView.addSubview(priceLabel)
    }
    
    func configureTitleLabel() {
        // Configure product title
        titleLabel.titleLabelStyle()
        descriptionContainerView.addSubview(titleLabel)
    }
    
    func configureDescriptionTextView() {
        // Configure description text
        descriptionTextView.descriptionTextViewStyle()
        descriptionContainerView.addSubview(descriptionTextView)
    }
    
    func configureImageSlider() {
        // Configure image slider
        slideShow.translatesAutoresizingMaskIntoConstraints = false
        slideShow.contentScaleMode = .scaleAspectFill
        imageCarouselContainerView.addSubview(slideShow)
    }
    
    func configureOptionsTitleLabel() {
        // Configure options title label
        optionsTitleLabel.optionsTitleLabelStyle()
        variantOptionsContainerView.addSubview(optionsTitleLabel)
    }
    
    func loadProductData() {
        // Prepare image links Array
        let images = self.product?.data?.productByHandle?.images?.edges
        for image in images! {
            let link = image.node?.transformedSrc
            imageLinks.add(link!)
        }
        
        variants = (product?.data?.productByHandle?.variants?.edges)!
        
        // Count variants
        variantCount = variants.count
        
        // Select default variant
        selectedVariant = variants[0].node
    }
    
    func updateViewsData() {
        // Title label
        titleLabel.text = selectedVariant?.product?.title
        
        // Price tagd label
        priceLabel.text = (selectedVariant?.priceV2?.currencyCode)!+" "+(selectedVariant?.priceV2?.amount)!
        
        // Description text view
        descriptionTextView.text = selectedVariant?.product?.description
        
        let imageSources = NSMutableArray()
        // Image slide show
        for url in imageLinks {
            imageSources.add(AlamofireSource(urlString: url as! String)!)
        }
        slideShow.setImageInputs(imageSources as! [InputSource])
        
        // Selected option title
        optionsTitleLabel.text = selectedVariant?.title
        
        // Options selector disclosure
        if variants.count > 1 {
            self.configureVariantOptionDisclosure()
        }
    }
    
    func showOptionsSelector() {
        // Configure option selector overlay
        optionsSelectorOverlayView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        optionsSelectorOverlayView.addBlurEffect(style: UIBlurEffect.Style.dark)
        view.addSubview(optionsSelectorOverlayView);
        
        // Handle taps
        optionsSelectorOverlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        optionsSelectorOverlayTapGesture.numberOfTapsRequired = 1
        optionsSelectorOverlayTapGesture.numberOfTouchesRequired = 1
        optionsSelectorOverlayView.addGestureRecognizer(optionsSelectorOverlayTapGesture)
        
        // Options selector placeholder
        optionsSelectorPlaceholderView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        optionsSelectorPlaceholderView.center = optionsSelectorOverlayView.convert(optionsSelectorOverlayView.center, from:optionsSelectorOverlayView.superview)
        optionsSelectorPlaceholderView.backgroundColor = .white
        optionsSelectorOverlayView.addSubview(optionsSelectorPlaceholderView)
        
        // Add navigation controller childview controller
        let variantSelctionNavigationController = UINavigationController()
        addChild(variantSelctionNavigationController)
        variantSelctionNavigationController.view.frame.size.width = optionsSelectorPlaceholderView.frame.size.width
        variantSelctionNavigationController.view.frame.size.height = optionsSelectorPlaceholderView.frame.size.height
        
        // Populate first level selection
        let variantSelectionViewController = VariantSelectionViewController()
        variantSelectionViewController.variants = variants
        variantSelctionNavigationController.addChild(variantSelectionViewController)
        
        // Add selection to tableview
        optionsSelectorPlaceholderView.addSubview(variantSelctionNavigationController.view)
        variantSelctionNavigationController.didMove(toParent: self)
    }
    
    func checkoutSelectedVariant() {
        self.showActivityIndicator()
        Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!) { success, error, checkout in
            self.hideActivityIndicator()
            // Show some error if needed
            if success {
                guard let url = URL(string: (checkout?.data?.checkoutCreate?.checkout?.webURL)!) else { return }
                UIApplication.shared.open(url)
            }
            else {
                // Handle error
                let alert = UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                    @unknown default:
                        break
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Handle button clicks
    @objc func buttonAction(sender:UIButton!){
        if sender == closeButton {
            // Close product view
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        if sender == checkoutButton {
            // Start checkout
            self.checkoutSelectedVariant()
        }
    }
    
    // Handle taps
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender == optionsTapGesture {
            if variants.count > 1 {
                self.showOptionsSelector()
            }
        }
        if sender == optionsSelectorOverlayTapGesture {
            
            // Remove child view controllers
            self.children.forEach{$0.willMove(toParent: nil);$0.view.removeFromSuperview();$0.removeFromParent()}
            
            // Remove and reset optionsSelectorOverlayView
            optionsSelectorOverlayView.removeFromSuperview()
            optionsSelectorOverlayView = UIView()
        }
    }
    
}
