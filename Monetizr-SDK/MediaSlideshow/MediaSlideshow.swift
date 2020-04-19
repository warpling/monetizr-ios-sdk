//
//  MediaSlideshow.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 15/04/2020.
//
//  Adopted form ImageSlideshow Created by Petr Zvoníček on 30.07.15.
//
//

import UIKit

@objc
// The delegate protocol informing about media slideshow state changes
public protocol MediaSlideshowDelegate: class {
    // Tells the delegate that the current page has changed
    //
    // - Parameters:
    //   - mediaSlideshow: media slideshow instance
    //   - page: new page
    @objc optional func mediaSlideshow(_ mediaSlideshow: MediaSlideshow, didChangeCurrentPageTo page: Int)

    // Tells the delegate that the slideshow will begin dragging
    //
    // - Parameter mediaSlideshow: media slideshow instance
    @objc optional func mediaSlideshowWillBeginDragging(_ mediaSlideshow: MediaSlideshow)

    // Tells the delegate that the slideshow did end decelerating
    //
    // - Parameter mediaSlideshow: media slideshow instance
    @objc optional func mediaSlideshowDidEndDecelerating(_ mediaSlideshow: MediaSlideshow)
}

/*
    Used to represent position of the Page Control
    - hidden: Page Control is hidden
    - insideScrollView: Page Control is inside slideshow
    - underScrollView: Page Control is under slideshow
    - custom: Custom vertical padding, relative to "insideScrollView" position
 */
public enum PageControlPosition {
    case hidden
    case insideScrollView
    case underScrollView
    case custom(padding: CGFloat)
}

// Used to represent media preload strategy
//
// - fixed: preload only fixed number of images before and after the current image
// - all: preload all images in the slideshow
public enum ImagePreload {
    case fixed(offset: Int)
    case all
}

// Main view containing the Slideshow
@objcMembers
open class MediaSlideshow: UIView {

    // Scroll View to wrap the slideshow
    public let scrollView = UIScrollView()

    // Page Control shown in the slideshow
    @available(*, deprecated, message: "Use pageIndicator.view instead")
    open var pageControl: UIPageControl {
        if let pageIndicator = pageIndicator as? UIPageControl {
            return pageIndicator
        }
        fatalError("pageIndicator is not an instance of UIPageControl")
    }

    // Activity indicator shown when loading
    open var activityIndicator: ActivityIndicatorFactory? {
        didSet {
            reloadScrollView()
        }
    }

    open var pageIndicator: PageIndicatorView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            if let pageIndicator = pageIndicator {
                addSubview(pageIndicator.view)
                if let pageIndicator = pageIndicator as? UIControl {
                    pageIndicator.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
                }
            }
            setNeedsLayout()
        }
    }

    open var pageIndicatorPosition: PageIndicatorPosition = PageIndicatorPosition() {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: - State properties

    // Page control position
    @available(*, deprecated, message: "Use pageIndicatorPosition instead")
    open var pageControlPosition = PageControlPosition.insideScrollView {
        didSet {
            pageIndicator = UIPageControl()
            switch pageControlPosition {
            case .hidden:
                pageIndicator = nil
            case .insideScrollView:
                pageIndicatorPosition = PageIndicatorPosition(vertical: .bottom)
            case .underScrollView:
                pageIndicatorPosition = PageIndicatorPosition(vertical: .under)
            case .custom(let padding):
                pageIndicatorPosition = PageIndicatorPosition(vertical: .customUnder(padding: padding-30))
            }
        }
    }

    // Current page
    open fileprivate(set) var currentPage: Int = 0 {
        didSet {
            if oldValue != currentPage {
                pageIndicator?.page = currentPage
                currentPageChanged?(currentPage)
                delegate?.mediaSlideshow?(self, didChangeCurrentPageTo: currentPage)
            }
        }
    }

    // Delegate called on slideshow state change
    open weak var delegate: MediaSlideshowDelegate?

    // Called on each currentPage change
    open var currentPageChanged: ((_ page: Int) -> ())?

    // Called on scrollViewWillBeginDragging
    open var willBeginDragging: (() -> ())?

    // Called on scrollViewDidEndDecelerating
    open var didEndDecelerating: (() -> ())?

    // Currenlty displayed slideshow item
    open var currentSlideshowItem: MediaSlideshowItem? {
        if slideshowItems.count > scrollViewPage {
            return slideshowItems[scrollViewPage]
        } else {
            return nil
        }
    }

    // Current scroll view page. This may differ from `currentPage` as circular slider has two more dummy pages at indexes 0 and n-1 to provide fluent scrolling between first and last item.
    open fileprivate(set) var scrollViewPage: Int = 0

    // Input Sources loaded to slideshow
    open fileprivate(set) var media = [InputSource]()

    // Image Slideshow Items loaded to slideshow
    open fileprivate(set) var slideshowItems = [MediaSlideshowItem]()

    // MARK: - Preferences

    // Enables/disables infinite scrolling between images
    open var circular = true {
        didSet {
            if media.count > 0 {
                setMediaInputs(media)
            }
        }
    }

    // Enables/disables user interactions
    open var draggingEnabled = true {
        didSet {
            scrollView.isUserInteractionEnabled = draggingEnabled
        }
    }

    // Enables/disables zoom
    open var zoomEnabled = false {
        didSet {
            reloadScrollView()
        }
    }
    
    // Maximum zoom scale
    open var maximumScale: CGFloat = 2.0 {
        didSet {
            reloadScrollView()
        }
    }

    // Image change interval, zero stops the auto-scrolling
    open var slideshowInterval = 0.0 {
        didSet {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
            setTimerIfNeeded()
        }
    }

    // Image preload configuration, can be sed to .fixed to enable lazy load or .all
    open var preload = ImagePreload.all

    // Content mode of each image in the slideshow
    open var contentScaleMode: UIViewContentMode = UIViewContentMode.scaleAspectFit {
        didSet {
            for view in slideshowItems {
                view.imageView.contentMode = contentScaleMode
            }
        }
    }

    fileprivate var slideshowTimer: Timer?
    fileprivate var scrollViewMedia = [InputSource]()
    fileprivate var isAnimating: Bool = false
    
    private var primaryVisiblePage: Int {
        return scrollView.frame.size.width > 0 ? Int(scrollView.contentOffset.x + scrollView.frame.size.width / 2) / Int(scrollView.frame.size.width) : 0
    }

    // MARK: - Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    fileprivate func initialize() {
        autoresizesSubviews = true
        clipsToBounds = true

        // scroll view configuration
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 50.0)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = autoresizingMask
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            scrollView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)

        if pageIndicator == nil {
            pageIndicator = UIPageControl()
        }

        setTimerIfNeeded()
        layoutScrollView()
    }

    open override func removeFromSuperview() {
        super.removeFromSuperview()
        pauseTimer()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        // fixes the case when automaticallyAdjustsScrollViewInsets on parenting view controller is set to true
        scrollView.contentInset = UIEdgeInsets.zero

        layoutPageControl()
        layoutScrollView()
    }

    open func layoutPageControl() {
        if let pageIndicatorView = pageIndicator?.view {
            pageIndicatorView.isHidden = media.count < 2

            var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero
            if #available(iOS 11.0, *) {
                edgeInsets = safeAreaInsets
            }

            pageIndicatorView.sizeToFit()
            pageIndicatorView.frame = pageIndicatorPosition.indicatorFrame(for: frame, indicatorSize: pageIndicatorView.frame.size, edgeInsets: edgeInsets)
        }
    }

    // updates frame of the scroll view and its inner items
    func layoutScrollView() {
        let pageIndicatorViewSize = pageIndicator?.view.frame.size
        let scrollViewBottomPadding = pageIndicatorViewSize.flatMap { pageIndicatorPosition.underPadding(for: $0) } ?? 0

        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - scrollViewBottomPadding)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewMedia.count), height: scrollView.frame.size.height)

        for (index, view) in slideshowItems.enumerated() {
            if !view.zoomInInitially {
                view.zoomOut()
            }
            view.frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }

        setScrollViewPage(scrollViewPage, animated: false)
    }

    // reloads scroll view with latest slideshow items
    func reloadScrollView() {
        // remove previous slideshow items
        for view in slideshowItems {
            view.removeFromSuperview()
        }
        slideshowItems = []

        var i = 0
        for image in scrollViewMedia {
            let item = MediaSlideshowItem(image: image, zoomEnabled: zoomEnabled, activityIndicator: activityIndicator?.create(), maximumScale: maximumScale)
            item.imageView.contentMode = contentScaleMode
            slideshowItems.append(item)
            scrollView.addSubview(item)
            i += 1
        }

        if circular && (scrollViewMedia.count > 1) {
            scrollViewPage = 1
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
        } else {
            scrollViewPage = 0
        }

        loadImages(for: scrollViewPage)
    }

    private func loadImages(for scrollViewPage: Int) {
        let totalCount = slideshowItems.count

        for i in 0..<totalCount {
            let item = slideshowItems[i]
            switch preload {
            case .all:
                item.loadImage()
            case .fixed(let offset):
                // if circular scrolling is enabled and image is on the edge, a helper ("dummy") image on the other side needs to be loaded too
                let circularEdgeLoad = circular && ((scrollViewPage == 0 && i == totalCount-3) || (scrollViewPage == 0 && i == totalCount-2) || (scrollViewPage == totalCount-2 && i == 1))

                // load image if page is in range of loadOffset, else release image
                let shouldLoad = abs(scrollViewPage-i) <= offset || abs(scrollViewPage-i) > totalCount-offset || circularEdgeLoad
                shouldLoad ? item.loadImage() : item.releaseImage()
            }
        }
    }

    // MARK: - Image setting

    /*
     Set image inputs into the image slideshow
     - parameter inputs: Array of InputSource instances.
     */
    open func setMediaInputs(_ inputs: [InputSource]) {
        media = inputs
        pageIndicator?.numberOfPages = inputs.count

        // in circular mode we add dummy first and last image to enable smooth scrolling
        if circular && media.count > 1 {
            var scMedia = [InputSource]()

            if let last = media.last {
                scMedia.append(last)
            }
            scMedia += media
            if let first = media.first {
                scMedia.append(first)
            }

            scrollViewMedia = scMedia
        } else {
            scrollViewMedia = media
        }

        reloadScrollView()
        layoutScrollView()
        layoutPageControl()
        setTimerIfNeeded()
    }

    // MARK: paging methods

    /*
     Change the current page
     - parameter newPage: new page
     - parameter animated: true if animate the change
     */
    open func setCurrentPage(_ newPage: Int, animated: Bool) {
        var pageOffset = newPage
        if circular && (scrollViewMedia.count > 1) {
            pageOffset += 1
        }

        setScrollViewPage(pageOffset, animated: animated)
    }

    /*
     Change the scroll view page. This may differ from `setCurrentPage` as circular slider has two more dummy pages at indexes 0 and n-1 to provide fluent scrolling between first and last item.
     - parameter newScrollViewPage: new scroll view page
     - parameter animated: true if animate the change
     */
    open func setScrollViewPage(_ newScrollViewPage: Int, animated: Bool) {
        if scrollViewPage < scrollViewMedia.count {
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(newScrollViewPage), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: animated)
            setCurrentPageForScrollViewPage(newScrollViewPage)
            if animated {
                isAnimating = true
            }
        }
    }

    fileprivate func setTimerIfNeeded() {
        if slideshowInterval > 0 && scrollViewMedia.count > 1 && slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval, target: self, selector: #selector(MediaSlideshow.slideshowTick(_:)), userInfo: nil, repeats: true)
        }
    }

    @objc func slideshowTick(_ timer: Timer) {
        let page = scrollView.frame.size.width > 0 ? Int(scrollView.contentOffset.x / scrollView.frame.size.width) : 0
        var nextPage = page + 1

        if !circular && page == scrollViewMedia.count - 1 {
            nextPage = 0
        }

        setScrollViewPage(nextPage, animated: true)
    }

    fileprivate func setCurrentPageForScrollViewPage(_ page: Int) {
        if scrollViewPage != page {
            // current page has changed, zoom out this image
            if slideshowItems.count > scrollViewPage {
                slideshowItems[scrollViewPage].zoomOut()
            }
        }

        if page != scrollViewPage {
            loadImages(for: page)
        }
        scrollViewPage = page
        currentPage = currentPageForScrollViewPage(page)
    }
    
    fileprivate func currentPageForScrollViewPage(_ page: Int) -> Int {
        if circular {
            if page == 0 {
                // first page contains the last image
                return Int(media.count) - 1
            } else if page == scrollViewMedia.count - 1 {
                // last page contains the first image
                return 0
            } else {
                return page - 1
            }
        } else {
            return page
        }
    }

    fileprivate func restartTimer() {
        if slideshowTimer?.isValid != nil {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }

        setTimerIfNeeded()
    }

    // Stops slideshow timer
    open func pauseTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }

    // Restarts slideshow timer
    open func unpauseTimer() {
        setTimerIfNeeded()
    }

    @available(*, deprecated, message: "use pauseTimer instead")
    open func pauseTimerIfNeeded() {
        pauseTimer()
    }

    @available(*, deprecated, message: "use unpauseTimer instead")
    open func unpauseTimerIfNeeded() {
        unpauseTimer()
    }

    /*
     Change the page to the next one
     - Parameter animated: true if animate the change
     */
    open func nextPage(animated: Bool) {
        if !circular && currentPage == media.count - 1 {
            return
        }
        if isAnimating {
            return
        }

        setCurrentPage(currentPage + 1, animated: animated)
        restartTimer()
    }

    /*
     Change the page to the previous one
     - Parameter animated: true if animate the change
     */
    open func previousPage(animated: Bool) {
        if !circular && currentPage == 0 {
            return
        }
        if isAnimating {
            return
        }

        let newPage = scrollViewPage > 0 ? scrollViewPage - 1 : scrollViewMedia.count - 3
        setScrollViewPage(newPage, animated: animated)
        restartTimer()
    }
}

extension MediaSlideshow: UIScrollViewDelegate {

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        restartTimer()
        willBeginDragging?()
        delegate?.mediaSlideshowWillBeginDragging?(self)
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPageForScrollViewPage(primaryVisiblePage)
        didEndDecelerating?()
        delegate?.mediaSlideshowDidEndDecelerating?(self)
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if circular && (scrollViewMedia.count > 1) {
            let regularContentOffset = scrollView.frame.size.width * CGFloat(media.count)

            if scrollView.contentOffset.x >= scrollView.frame.size.width * CGFloat(media.count + 1) {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - regularContentOffset, y: 0)
            } else if scrollView.contentOffset.x <= 0 {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + regularContentOffset, y: 0)
            }
        }

        // Updates the page indicator as the user scrolls (#204). Not called when not dragging to prevent flickers
        // when interacting with PageControl directly (#376).
        if scrollView.isDragging {
            pageIndicator?.page = currentPageForScrollViewPage(primaryVisiblePage)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isAnimating = false
    }
    
    @objc private func pageControlValueChanged() {
        if let currentPage = pageIndicator?.page {
            setCurrentPage(currentPage, animated: true)
        }
    }
}
