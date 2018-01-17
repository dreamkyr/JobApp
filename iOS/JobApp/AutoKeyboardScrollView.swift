//
//  AutoKeyboardScrollView.swift
//
//  Created by Honghao Zhang on 2/1/15.
//  Copyright (c) 2015 Honghao Zhang (张宏昊)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

open class AutoKeyboardScrollView: UIScrollView {
    
    // MARK: Public APIs
    
    /**
    Manually add textField to scrollView and let scrollView handle it
    
    :param: textField textField in subView tree of receiver
    */
    open func handleTextField(_ textField: UITextField) {
        (self.contentView as! ContentView).addTextField(textField)
    }
    
    /**
    Manually add a bunch of textFields to scrollView and let scrollView handle them
    This is a convenience method
    
    :param: textFields Array of textFields in subView tree of receiver
    */
    open func handleTextFields(_ textFields: [UITextField]) {
        for field in textFields {
            handleTextField(field)
        }
    }
	
	/**
	Manually remove textField to scrollView and let scrollView handle it
	
	:param: textField textField in subView tree of receiver
	*/
	open func removeTextField(_ textField: UITextField) {
		(self.contentView as! ContentView).removeTextField(textField)
	}
	
	/**
	Manually remove a bunch of textFields to scrollView and let scrollView handle them
	This is a convenience method
	
	:param: textFields Array of textFields in subView tree of receiver
	*/
	open func removeTextFields(_ textFields: [UITextField]) {
		for field in textFields {
			removeTextField(field)
		}
	}
    
    /**
     Set top and bottom margin for specific textField.
     This will give an empty spacing between active textField and keyboard
     
     - parameter margin:    margin
     - parameter textField: textField
     */
    open func setTextMargin(_ margin: CGFloat, forTextField textField: UITextField) {
        (contentView as! ContentView).setTextMargin(margin, forTextField: textField)
    }
	
    /// Top and Bottom margin for textField, this will give an empty spacing between active textField and keyboard
    open var textFieldMargin: CGFloat = 20
    
    /// contentView's width equals to scrollView
    open var contentViewWidthEqualsToScrollView: Bool = false {
        didSet {
            self.removeConstraint(contentViewEqualWidthConstraint)
			
            contentViewEqualWidthConstraint = contentViewConstraintEqual(.width)
            if contentViewWidthEqualsToScrollView {
                contentViewEqualWidthConstraint.priority = 1000
            } else {
                contentViewEqualWidthConstraint.priority = 10
            }
			
            self.addConstraint(contentViewEqualWidthConstraint)
        }
    }
    
    /// contentView's height equals to scrollView
    open var contentViewHeightEqualsToScrollView: Bool = false {
        didSet {
            self.removeConstraint(contentViewEqualHeightConstraint)
			
            contentViewEqualHeightConstraint = contentViewConstraintEqual(.height)
            if contentViewHeightEqualsToScrollView {
                contentViewEqualHeightConstraint.priority = 1000
            } else {
                contentViewEqualHeightConstraint.priority = 10
            }
			
            self.addConstraint(contentViewEqualHeightConstraint)
        }
    }
	
	// All subViews should be added on contentView
	// ContentView's size determines contentSize of ScrollView
	// By default, contentView has same size as ScrollView, to expand the contentSize, let subviews' constraints to determin all four edges
	open var contentView: UIView!
	
    // MARK: - Private
    fileprivate class ContentView: UIView {
        var textFields = [UITextField]()
        var textFieldsToMargin = [UITextField : CGFloat]()

		/**
		addSubView: will check whether there's textField on this view, be sure to add textField before adding its container View
		
		:param: view A subview
		*/
        override func addSubview(_ view: UIView) {
            super.addSubview(view)
            checkSubviewsRecursively(view)
        }

		/**
		Add all textFields from the subviews of the view into managed textFields and setup editing actions for them
		
		:param: view A target text field
		*/
		fileprivate func checkSubviewsRecursively(_ view: UIView) {
			if let textField = view as? UITextField {
				addTextField(textField)
			}
			
			// Base case
			if view.subviews.count == 0 {
				return
			}
			
			for subview in view.subviews {
				checkSubviewsRecursively(subview)
			}
		}
		
		/**
		Add the text field to managed textFields and setup editing actions for it
		
		:param: textField A target text field
		*/
        fileprivate func addTextField(_ textField: UITextField) {
            textFields.append(textField)
            setupEditingActionsForTextField(textField)
        }
		
		/**
		Setup text field editing actions for a text field
		
		:param: textField A target text field
		*/
        fileprivate func setupEditingActionsForTextField(_ textField: UITextField) {
			guard let scrollView = superview as? UIScrollView else {
				print("Error: contentView's superview is not scrollView")
				return
			}
			
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidBegin) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidBegin(_:)), for: .editingDidBegin)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingChanged) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingChanged(_:)), for: .editingChanged)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEnd) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEnd(_:)), for: .editingDidEnd)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEndOnExit) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
            }
        }
		
		/**
		Remove the text field from managed textFields and remove editing actions for it
		
		:param: textField A target text field
		*/
		fileprivate func removeTextField(_ textField: UITextField) {
			if let index = textFields.index(of: textField) {
				textFields.remove(at: index)
                textFieldsToMargin.removeValue(forKey: textField)
			}
			removeEditingActionsForTextField(textField)
		}
		
		/**
		Remove text field editing actions for a text field
		
		:param: textField A target text field
		*/
		fileprivate func removeEditingActionsForTextField(_ textField: UITextField) {
			guard let scrollView = superview as? UIScrollView else {
				print("Error: contentView's superview is not scrollView")
				return
			}
			
			if textField.actions(forTarget: scrollView, forControlEvent: .editingDidBegin) != nil {
				textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidBegin(_:)), for: .editingDidBegin)
			}
			
			if textField.actions(forTarget: scrollView, forControlEvent: .editingChanged) != nil {
				textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingChanged(_:)), for: .editingChanged)
			}
			
			if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEnd) != nil {
				textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEnd(_:)), for: .editingDidEnd)
			}
			
			if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEndOnExit) != nil {
				textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
			}
		}
        
        fileprivate func setTextMargin(_ margin: CGFloat, forTextField textField: UITextField) {
            guard textFields.contains(textField) else {
                assertionFailure("textField: \(textField) is not handled")
                return
            }
            
            textFieldsToMargin[textField] = margin
        }
    }
	
    fileprivate var contentViewEqualWidthConstraint: NSLayoutConstraint!
    fileprivate var contentViewEqualHeightConstraint: NSLayoutConstraint!
	
    // These two values are used to backup original states
    fileprivate var originalContentInset: UIEdgeInsets!
    fileprivate var originalContentOffset: CGPoint!
    
    // Keep values from UIKeyboardNotification
    fileprivate var keyboardFrame: CGRect!
    fileprivate var keyboardAnimationDuration: TimeInterval!
    
    // TextFields on subtrees for scrollView
    fileprivate var textFields: [UITextField] {
        get {
            return (contentView as! ContentView).textFields
        }
    }
    
    // Current editing textField
    fileprivate var activeTextField: UITextField?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Disable undesired scroll behavior of default UIScrollView
    // To Avoid undesired scroll behavior of default UIScrollView, call zhScrollRectToVisible::
    // Reference: http://stackoverflow.com/a/12640831/3164091
    override open func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if _expectedScrollRect == nil {
            super.scrollRectToVisible(rect, animated: animated)
            return
        }
        if rect.equalTo(_expectedScrollRect) {
            super.scrollRectToVisible(rect, animated: animated)
        }
    }
    
    fileprivate var _expectedScrollRect: CGRect!
    fileprivate func zhScrollRectToVisible(_ rect: CGRect, animated: Bool) {
        _expectedScrollRect = rect
        scrollRectToVisible(rect, animated: animated)
    }
	
	open override func addSubview(_ view: UIView) {
		if (view is ContentView == false) && (view is UIImageView == false && view.alpha == 0) {
			print("warning: adding view on AutoKeyboardScrollView detected, you should add view on .contentView")
		}
		super.addSubview(view)
	}
    
    // MARK: Setups
    fileprivate func commonInit() {
        setupContentView()
        setupGestures()
        registerNotifications()
    }
    
    fileprivate func setupContentView() {
        contentView = ContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
		
        let top = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        // Width and height constraints with a lower priority
        contentViewEqualWidthConstraint = contentViewConstraintEqual(.width)
        // If equal width is not required, set its priority to a low value
        if contentViewWidthEqualsToScrollView == false {
            // Set its priority to be a very low value, to avoid conflicts
            contentViewEqualWidthConstraint.priority = 10
        }
		
        contentViewEqualHeightConstraint = contentViewConstraintEqual(.height)
        if contentViewHeightEqualsToScrollView == false {
            contentViewEqualHeightConstraint.priority = 10
        }
		
        self.addConstraints([top, left, bottom, right, contentViewEqualWidthConstraint, contentViewEqualHeightConstraint])
    }
    
    fileprivate func contentViewConstraintEqual(_ attr: NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: contentView, attribute: attr, relatedBy: .greaterThanOrEqual, toItem: self, attribute: attr, multiplier: 1.0, constant: 0.0)
    }
    
    deinit {
        unregisterNotifications()
    }
}

// MARK: TapGesture - Tap to dismiss
extension AutoKeyboardScrollView {
    fileprivate func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AutoKeyboardScrollView._scrollViewTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
	
	@objc(scrollViewTapped:)
    fileprivate func _scrollViewTapped(_ gesture: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
    }
}

// MARK: TextFields Actions
extension AutoKeyboardScrollView {
	@objc(_textFieldEditingDidBegin:)
    fileprivate func _textFieldEditingDidBegin(_ sender: AnyObject) {
        activeTextField = sender as? UITextField
        if self.keyboardFrame != nil {
            makeActiveTextFieldVisible(self.keyboardFrame)
            
        }
    }
	
	@objc(_textFieldEditingChanged:)
    fileprivate func _textFieldEditingChanged(_ sender: AnyObject) {
        if self.keyboardFrame != nil {
            makeActiveTextFieldVisible(self.keyboardFrame)
        }
    }
	
	@objc(_textFieldEditingDidEnd:)
    fileprivate func _textFieldEditingDidEnd(_ sender: AnyObject) {
		activeTextField = nil
    }
	
	@objc(_textFieldEditingDidEndOnExit:)
    fileprivate func _textFieldEditingDidEndOnExit(_ sender: AnyObject) {
        // This method gives the ability of dismissing keyboard on tapping return
    }
}

// MARK: Keyboard Notification
extension AutoKeyboardScrollView {
    fileprivate func registerNotifications() {
        // Reason for only registering UIKeyboardWillChangeFrameNotification
        // Since UIKeyboardWillChangeFrameNotification will be posted before willShow and willBeHidden, to avoid duplicated animations, detecting keyboard behaviors only from this notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AutoKeyboardScrollView.keyboardWillChange(_:)),
            name: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil)
    }
    
    fileprivate func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
	
	@objc(keyboardWillChange:)
    fileprivate func keyboardWillChange(_ notification: Notification) {
        // Init keyboardAnimationDuration
        keyboardAnimationDuration = keyboardDismissingDuration(notification)
		
        if isKeyboardWillShow(notification) {
            // Preserved original contentInset and contentOffset
            originalContentInset = contentInset
            originalContentOffset = contentOffset
            
            let endFrame = keyboardEndFrame(notification)
            // Init keyboardFrame
            keyboardFrame = endFrame
            
            makeActiveTextFieldVisible(endFrame)
        } else if isKeyboardWillHide(notification) {
            // Animated to restore to original state
            UIView.animate(withDuration: keyboardDismissingDuration(notification), animations: { () -> Void in
                self.contentInset = self.originalContentInset ?? UIEdgeInsets.zero
                self.contentOffset = self.originalContentOffset ?? CGPoint.zero
                }, completion: { (completed) -> Void in
                    self.keyboardFrame = nil
            })
        } else {
            // This will be called when keyboard size is changed when it's still displaying
            let endFrame = keyboardEndFrame(notification)
            self.keyboardFrame = endFrame
            makeActiveTextFieldVisible(endFrame)
        }
    }
    
    /**
    Make sure active textField is visible
    Note: scrollView's contentInset will be changed
    
    :param: keyboardRect Current keyboard frame
    */
    public func makeActiveTextFieldVisible(_ keyboardRect: CGRect) {
        var keyboardRect = keyboardRect
		guard let activeTextField = activeTextField else {
			print("Warning: activeTextField is nil")
			return
		}
		
        // flipLandscapeFrameForIOS7 only changes CGRect for landscape on iOS7
        keyboardRect = flipLandscapeFrameForIOS7(keyboardRect)
        
        
        // VisibleScrollViewFrame
        var visibleScrollFrame = convert(bounds, to: nil)
        visibleScrollFrame = flipLandscapeFrameForIOS7(visibleScrollFrame)
        
        // If keyboard covers part of visibleScrollFrame, cut off visibleScrollFrame and update scrollView's contentInset
		let bottomOfScrollView = visibleScrollFrame.maxY
        if bottomOfScrollView > keyboardRect.origin.y {
            let cutHeight = bottomOfScrollView - keyboardRect.origin.y
            visibleScrollFrame.size.height -= cutHeight
            
            // Animated change self.contentInset
			UIView.animate(withDuration: keyboardAnimationDuration, animations: { () -> Void in
				self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, cutHeight, self.contentInset.right)
				}, completion: nil)
        }
		
        // Enlarge the targetFrame, give top and bottom some points margin
        var targetFrame = flipLandscapeFrameForIOS7(activeTextField.convert(activeTextField.bounds, to: self))
        
        // Add top & bottom margins for target frame
        let textFieldMargin = (contentView as! ContentView).textFieldsToMargin[activeTextField] ?? self.textFieldMargin
        targetFrame.origin.y -= textFieldMargin
        targetFrame.size.height += textFieldMargin * 2
        
        // Don't call default scrollRectToVisible
        self.zhScrollRectToVisible(targetFrame, animated: true)
    }
    
    // Helper functions
    fileprivate func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    fileprivate func keyboardBeginFrame(_ notification: Notification) -> CGRect {
        return (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue as CGRect!
    }
    
    fileprivate func keyboardEndFrame(_ notification: Notification) -> CGRect {
        return (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue as CGRect!
    }
    
    fileprivate func isKeyboardWillShow(_ notification: Notification) -> Bool {
        let beginFrame = keyboardBeginFrame(notification)
        return (abs(beginFrame.origin.y - screenHeight()) < 0.1)
    }
    
    fileprivate func isKeyboardWillHide(_ notification: Notification) -> Bool {
        let endFrame = keyboardEndFrame(notification)
        return (abs(endFrame.origin.y - screenHeight()) < 0.1)
    }
    
    fileprivate func keyboardDismissingDuration(_ notification: Notification) -> TimeInterval {
        return (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue as TimeInterval!
    }
    
    fileprivate func isIOS7() -> Bool { return floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1) }
    
    fileprivate func isLandscapeMode() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    
    /**
    Flip frame for landscape on iOS7
    Since on landscape on iOS7, CGRect's origin and size is same as portrait, need to flip the rect to let it reflect true width and height
    
    :param: frame Original CGRect
    
    :returns: Flipped CGRect
    */
    fileprivate func flipLandscapeFrameForIOS7(_ frame: CGRect) -> CGRect {
        if isIOS7() && isLandscapeMode() {
			let newFrame = CGRect(x: frame.origin.y, y: frame.origin.x, width: frame.size.height, height: frame.size.width)
			return newFrame
        } else {
			return frame
        }
    }
}
