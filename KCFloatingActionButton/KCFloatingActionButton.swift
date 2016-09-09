//
//  KCFloatingActionButton.swift
//
//  Created by LeeSunhyoup on 2015. 10. 4..
//  Copyright © 2015년 kciter. All rights reserved.
//

import UIKit

public enum KCFABOpenAnimationType {
    case pop
    case fade
    case slideLeft
    case slideUp
    case none
}

/**
    Floating Action Button Object. It has `KCFloatingActionButtonItem` objects.
    KCFloatingActionButton support storyboard designable.
*/
@IBDesignable
open class KCFloatingActionButton: UIView {
    // MARK: - Properties
    
    /**
        `KCFloatingActionButtonItem` objects.
    */
    open var items: [KCFloatingActionButtonItem] = []
    
    /**
        This object's button size.
    */
    open var size: CGFloat = 56 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /**
        Padding from bottom right of UIScreen or superview.
    */
    open var paddingX: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var paddingY: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
	
	/**
		Automatically closes child items when tapped
	*/
	@IBInspectable open var autoCloseOnTap: Bool = true
	
	/**
		Degrees to rotate image
	*/
	@IBInspectable open var rotationDegrees: CGFloat = -45
    /**
        Button color.
    */
    @IBInspectable open var buttonColor: UIColor = UIColor(red: 73/255.0, green: 151/255.0, blue: 241/255.0, alpha: 1)
    
    /**
        Button image.
    */
    @IBInspectable open var buttonImage: UIImage? = nil
    
    /**
        Plus icon color inside button.
    */
    @IBInspectable open var plusColor: UIColor = UIColor(white: 0.2, alpha: 1)
    
    /**
        Background overlaying color.
    */
    @IBInspectable open var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    
    /**
        The space between the item and item.
    */
    @IBInspectable open var itemSpace: CGFloat = 14
    
    /**
        Child item's default size.
    */
    @IBInspectable open var itemSize: CGFloat = 42
    
    /**
        Child item's default button color.
    */
    @IBInspectable open var itemButtonColor: UIColor = UIColor.white
	
	/**
		Child item's image color
	*/
	@IBInspectable open var itemImageColor: UIColor? = nil
	
    /**
        Child item's default shadow color.
    */
    @IBInspectable open var itemShadowColor: UIColor = UIColor.black
    
    /**
    
    */
    open var closed: Bool = true
    
    open var openAnimationType: KCFABOpenAnimationType = .pop
    
    /**
     Delegate that can be used to learn more about the behavior of the FAB widget.
    */
    open var fabDelegate: KCFloatingActionButtonDelegate?
    
    /**
        Button shape layer.
    */
    fileprivate var circleLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        Plus icon shape layer.
    */
    fileprivate var plusLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        Button image view.
    */
    fileprivate var buttonImageView: UIImageView = UIImageView()
    
    /**
        If you keeping touch inside button, button overlaid with tint layer.
    */
    fileprivate var tintLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        If you show items, background overlaid with overlayColor.
    */
//    private var overlayLayer: CAShapeLayer = CAShapeLayer()
     
    fileprivate var overlayView : UIControl = UIControl()

    
    /**
        If you created this object from storyboard or `initWithFrame`, this property set true.
    */
    fileprivate var isCustomFrame: Bool = false
    
    // MARK: - Initialize
    
    /**
        Initialize with default property.
    */
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        backgroundColor = UIColor.clear
        setObserver()
    }
    
    /**
        Initialize with custom size.
    */
    public init(size: CGFloat) {
        self.size = size
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        backgroundColor = UIColor.clear
        setObserver()
    }
    
    /**
        Initialize with custom frame.
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        size = min(frame.size.width, frame.size.height)
        backgroundColor = UIColor.clear
        isCustomFrame = true
        setObserver()
    }
    
    /**
        Initialize from storyboard.
    */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        size = min(frame.size.width, frame.size.height)
        backgroundColor = UIColor.clear
        clipsToBounds = false
        isCustomFrame = true
        setObserver()
    }
    
    // MARK: - Method
    
    /**
        Set size and frame.
    */
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        if isCustomFrame == false {
            setRightBottomFrame()
        } else {
            size = min(frame.size.width, frame.size.height)
        }
    }
    
    /**
        Draw layers.
    */
    open override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
//        setOverlayLayer()
        setCircleLayer()
        if buttonImage == nil {
            setPlusLayer()
        } else {
            setButtonImage()
        }
        setShadow()
    }
    
    /**
        Items open.
    */
    open func open() {
        if(items.count > 0){
            
            setOverlayView()
            self.superview?.insertSubview(overlayView, aboveSubview: self)
            self.superview?.bringSubview(toFront: self)
            overlayView.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
            
            UIView.animate(withDuration: 0.3, delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 0.3,
                options: .curveEaseInOut, animations: { () -> Void in
					if self.buttonImage == nil {
						self.plusLayer.transform = CATransform3DMakeRotation(self.toRadians(degrees: self.rotationDegrees), 0.0, 0.0, 1.0)
					}
					else {
                        self.buttonImageView.transform = CGAffineTransform(rotationAngle: self.toRadians(degrees: self.rotationDegrees))
					}
                    self.overlayView.alpha = 1
                }, completion: nil)
            
            
            switch openAnimationType {
            case .pop:
                popAnimationWithOpen()
            case .fade:
                fadeAnimationWithOpen()
            case .slideLeft:
                slideLeftAnimationWithOpen()
            case .slideUp:
                slideUpAnimationWithOpen()
            case .none:
                noneAnimationWithOpen()
            }
        }
        
        fabDelegate?.KCFABOpened?(self)
        closed = false
    }
    
    /**
        Items close.
    */
    open func close() {
        if(items.count > 0){
            self.overlayView.removeTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
            UIView.animate(withDuration: 0.3, delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8,
                options: [], animations: { () -> Void in
					if self.buttonImage == nil {
						self.plusLayer.transform = CATransform3DMakeRotation(self.toRadians(degrees: 0), 0.0, 0.0, 1.0)
					}
					else {
                        self.buttonImageView.transform = CGAffineTransform(rotationAngle: self.toRadians(degrees: 0))
					}
                    self.overlayView.alpha = 0
                }, completion: {(f) -> Void in
                    self.overlayView.removeFromSuperview()
            })
            
            switch openAnimationType {
            case .pop:
                popAnimationWithClose()
            case .fade:
                fadeAnimationWithClose()
            case .slideLeft:
                slideLeftAnimationWithClose()
            case .slideUp:
                slideUpAnimationWithClose()
            case .none:
                noneAnimationWithClose()
            }
        }
        
        fabDelegate?.KCFABClosed?(self)
        closed = true
    }
    
    /**
        Items open or close.
    */
    open func toggle() {
        if items.count > 0 {
            if closed == true {
                open()
            } else {
                close()
            }
        } else {
            fabDelegate?.emptyKCFABSelected?(self)
        }
    }
    
    /**
        Add custom item
    */
    open func addItem(item item: KCFloatingActionButtonItem) {
        item.frame.origin = CGPoint(x: size/2-item.size/2, y: size/2-item.size/2)
        item.alpha = 0
		item.actionButton = self
        items.append(item)
        addSubview(item)
    }
    
    /**
        Add item with title.
    */
    open func addItem(_ title: String) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        itemDefaultSet(item)
        item.title = title
        addItem(item: item)
        return item
    }
    
    /**
        Add item with title and icon.
    */
    open func addItem(_ title: String, icon: UIImage) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        itemDefaultSet(item)
        item.title = title
        item.icon = icon
        addItem(item: item)
        return item
    }
    
    /**
        Add item with title, icon or handler.
    */
    open func addItem(_ title: String, icon: UIImage, handler: @escaping ((KCFloatingActionButtonItem) -> Void)) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        itemDefaultSet(item)
        item.title = title
        item.icon = icon
        item.handler = handler
        addItem(item: item)
        return item
    }
    
    /**
        Add item with icon.
    */
    open func addItem(icon icon: UIImage) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        itemDefaultSet(item)
        item.icon = icon
        addItem(item: item)
        return item
    }
    
    /**
        Add item with icon and handler.
    */
    open func addItem(_ icon: UIImage, handler: @escaping ((KCFloatingActionButtonItem) -> Void)) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        itemDefaultSet(item)
        item.icon = icon
        item.handler = handler
        addItem(item: item)
        return item
    }
    
    /**
        Remove item.
    */
    open func removeItem(item item: KCFloatingActionButtonItem) {
        guard let index = items.index(of: item) else { return }
        items[index].removeFromSuperview()
        items.remove(at: index)
    }
    
    /**
        Remove item with index.
    */
    open func removeItem(_ index: Int) {
        items[index].removeFromSuperview()
        items.remove(at: index)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if closed == false {
            for item in items {
                if item.isHidden == true { continue }
                var itemPoint = item.convert(point, from: self)
                let size = CGRect(x: item.titleLabel.frame.origin.x + item.bounds.origin.x,
                                  y: item.bounds.origin.y,
                                  width: item.titleLabel.bounds.size.width + item.bounds.size.width + 30,
                                  height: item.bounds.size.height)
                
                if size.contains(itemPoint) == true {
                    itemPoint = item.bounds.origin
                    return item.hitTest(itemPoint, with: event)
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    fileprivate func setCircleLayer() {
        circleLayer.removeFromSuperlayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.backgroundColor = buttonColor.cgColor
        circleLayer.cornerRadius = size/2
        layer.addSublayer(circleLayer)
    }
    
    fileprivate func setPlusLayer() {
        plusLayer.removeFromSuperlayer()
        plusLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = plusColor.cgColor
        plusLayer.lineWidth = 2.0
        plusLayer.path = plusBezierPath().cgPath
        layer.addSublayer(plusLayer)
    }
    
    fileprivate func setButtonImage() {
        buttonImageView.removeFromSuperview()
        buttonImageView = UIImageView(image: buttonImage)
		buttonImageView.tintColor = plusColor
        buttonImageView.frame = CGRect(
            x: size/2 - buttonImageView.frame.size.width/2,
            y: size/2 - buttonImageView.frame.size.height/2,
            width: buttonImageView.frame.size.width,
            height: buttonImageView.frame.size.height
        )
        addSubview(buttonImageView)
    }
    
    fileprivate func setTintLayer() {
        tintLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        tintLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        tintLayer.cornerRadius = size/2
        layer.addSublayer(tintLayer)
    }
    
    fileprivate func setOverlayView() {
		setOverlayFrame()
        overlayView.backgroundColor = overlayColor
        overlayView.alpha = 0
        overlayView.isUserInteractionEnabled = true
        
    }
	fileprivate func setOverlayFrame() {
		overlayView.frame = CGRect(
			x: 0,y: 0,
			width: UIScreen.main.bounds.width,
			height: UIScreen.main.bounds.height
		)
	}
	
    fileprivate func setShadow() {
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
    }
    
    fileprivate func plusBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size/2, y: size/3))
        path.addLine(to: CGPoint(x: size/2, y: size-size/3))
        path.move(to: CGPoint(x: size/3, y: size/2))
        path.addLine(to: CGPoint(x: size-size/3, y: size/2))
        return path
    }
    
    fileprivate func itemDefaultSet(_ item: KCFloatingActionButtonItem) {
        item.buttonColor = itemButtonColor
		
		/// Use separate color (if specified) for item button image, or default to the plusColor
		item.iconImageView.tintColor = itemImageColor ?? plusColor
		
        item.circleShadowColor = itemShadowColor
        item.titleShadowColor = itemShadowColor
        item.size = itemSize
    }
    
    fileprivate func setRightBottomFrame(_ keyboardSize: CGFloat = 0) {
        if superview == nil {
            frame = CGRect(
                x: UIScreen.main.bounds.size.width-size-paddingX,
                y: UIScreen.main.bounds.size.height-size-paddingY-keyboardSize,
                width: size,
                height: size
            )
        } else {
            frame = CGRect(
                x: superview!.bounds.size.width-size-paddingX,
                y: superview!.bounds.size.height-size-paddingY-keyboardSize,
                width: size,
                height: size
            )
        }
    }
    
    fileprivate func setObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 {
            let touch = touches.first
            if touch?.tapCount == 1 {
                if touch?.location(in: self) == nil { return }
                setTintLayer()
            }
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if touches.count == 1 {
            let touch = touches.first
            if touch?.tapCount == 1 {
                if touch?.location(in: self) == nil { return }
                setTintLayer()
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        tintLayer.removeFromSuperlayer()
        if touches.count == 1 {
            let touch = touches.first
            if touch?.tapCount == 1 {
                if touch?.location(in: self) == nil { return }
                toggle()
            }
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? UIView) == superview && keyPath == "frame" {
            if isCustomFrame == false {
                setRightBottomFrame()
                setOverlayView()
            } else {
                size = min(frame.size.width, frame.size.height)
            }
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        superview?.removeObserver(self, forKeyPath: "frame")
        super.willMove(toSuperview: newSuperview)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superview?.addObserver(self, forKeyPath: "frame", options: [], context: nil)
    }
    
    internal func deviceOrientationDidChange(_ notification: Notification) {
        var keyboardSize: CGFloat = 0.0
        if let size = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
            keyboardSize = size.height
        }
		
		/// Update overlay frame for new orientation dimensions
		setOverlayFrame()
		
        if isCustomFrame == false {
            setRightBottomFrame(keyboardSize)
        } else {
            size = min(frame.size.width, frame.size.height)
        }
    }
    
    internal func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        
        if isCustomFrame == false {
            setRightBottomFrame(keyboardSize.height)
        } else {
            size = min(frame.size.width, frame.size.height)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.frame = CGRect(
                x: UIScreen.main.bounds.width-self.size-self.paddingX,
                y: UIScreen.main.bounds.height-self.size-self.paddingY - keyboardSize.height,
                width: self.size,
                height: self.size
            )
            }, completion: nil)
    }
    
    internal func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            if self.isCustomFrame == false {
                self.setRightBottomFrame()
            } else {
                self.size = min(self.frame.size.width, self.frame.size.height)
            }
            
            }, completion: nil)
    }
}

/**
    Opening animation functions
 */
extension KCFloatingActionButton {
    /**
        Pop animation
     */
    func popAnimationWithOpen() {
        var itemHeight: CGFloat = 0
        var delay = 0.0
        for item in items {
            if item.isHidden == true { continue }
            itemHeight += item.size + itemSpace
            item.layer.transform = CATransform3DMakeScale(1, 1, 1)
            item.frame.origin.y = -itemHeight
            item.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: delay,
                                       usingSpringWithDamping: 0.55,
                                       initialSpringVelocity: 0.3,
                                       options: .curveEaseInOut, animations: { () -> Void in
                                        item.layer.transform = CATransform3DMakeScale(1, 1, 1)
                                        item.alpha = 1
                }, completion: nil)
            
            delay += 0.1
        }
    }
    
    func popAnimationWithClose() {
        var delay = 0.0
        for item in items.reversed() {
            if item.isHidden == true { continue }
            UIView.animate(withDuration: 0.15, delay: delay, options: [], animations: { () -> Void in
                item.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
                item.alpha = 0
                }, completion: nil)
            delay += 0.1
        }
    }
    
    /**
        Fade animation
     */
    func fadeAnimationWithOpen() {
        var itemHeight: CGFloat = 0
        var delay = 0.0
        for item in items {
            if item.isHidden == true { continue }
            itemHeight += item.size + itemSpace
            item.frame.origin.y = -itemHeight
            UIView.animate(withDuration: 0.4,
                                       delay: delay,
                                       options: [],
                                       animations: { () -> Void in
                                        item.alpha = 1
                }, completion: nil)
            
            delay += 0.2
        }
    }
    
    func fadeAnimationWithClose() {
        var delay = 0.0
        for item in items.reversed() {
            if item.isHidden == true { continue }
            UIView.animate(withDuration: 0.4,
                                       delay: delay,
                                       options: [],
                                       animations: { () -> Void in
                                        item.alpha = 0
                }, completion: nil)
            delay += 0.2
        }
    }
    
    /**
        Slide left animation
     */
    func slideLeftAnimationWithOpen() {
        var itemHeight: CGFloat = 0
        var delay = 0.0
        for item in items {
            if item.isHidden == true { continue }
            itemHeight += item.size + itemSpace
            item.frame.origin.x = UIScreen.main.bounds.size.width - frame.origin.x
            item.frame.origin.y = -itemHeight
            UIView.animate(withDuration: 0.3, delay: delay,
                                       usingSpringWithDamping: 0.55,
                                       initialSpringVelocity: 0.3,
                                       options: .curveEaseInOut, animations: { () -> Void in
                                        item.frame.origin.x = self.size/2 - self.itemSize/2
                                        item.alpha = 1
                }, completion: nil)
            
            delay += 0.1
        }
    }
    
    func slideLeftAnimationWithClose() {
        var delay = 0.0
        for item in items.reversed() {
            if item.isHidden == true { continue }
            UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: { () -> Void in
                item.frame.origin.x = UIScreen.main.bounds.size.width - self.frame.origin.x
                item.alpha = 0
                }, completion: nil)
            delay += 0.1
        }
    }
    
    /**
        Slide up animation
     */
    func slideUpAnimationWithOpen() {
        var itemHeight: CGFloat = 0
        for item in items {
            if item.isHidden == true { continue }
            itemHeight += item.size + itemSpace
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: { () -> Void in
                                        item.frame.origin.y = -itemHeight
                                        item.alpha = 1
                }, completion: nil)
        }
    }
    
    func slideUpAnimationWithClose() {
        for item in items.reversed() {
            if item.isHidden == true { continue }
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: { () -> Void in
                item.frame.origin.y = 0
                item.alpha = 0
                }, completion: nil)
        }
    }
    
    /**
        None animation
     */
    func noneAnimationWithOpen() {
        var itemHeight: CGFloat = 0
        for item in items {
            if item.isHidden == true { continue }
            itemHeight += item.size + itemSpace
            item.frame.origin.y = -itemHeight
            item.alpha = 1
        }
    }
    
    func noneAnimationWithClose() {
        for item in items.reversed() {
            if item.isHidden == true { continue }
            item.frame.origin.y = 0
            item.alpha = 0
        }
    }
}

/**
    Util functions
 */
extension KCFloatingActionButton {
    func toRadians(degrees: CGFloat) -> CGFloat {
        return degrees / 180.0 * CGFloat(M_PI)
    }
}
