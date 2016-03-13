//
//  EPCPopover.swift
//  SmartSales
//
//  Created by Everton Cunha on 11/03/16.
//  Copyright © 2016 Intermidia. All rights reserved.
//

import UIKit

public class EPCPopover: NSObject {
    
    // MARK: - Vars
    // MARK: Private
    
    private var _retainSelf: EPCPopover?
    
    // MARK: Public
    
    public private(set) var viewController = UIViewController()
    
    public var didDismissBlock: (() -> Void)?
    
    public var willDismissBlock: (() -> Void)?
    
    
    // MARK: -
    // MARK: - Public Methods -
    
    override init() {
        
        super.init()
        
        viewController.modalPresentationStyle = .Popover
        viewController.view.backgroundColor = UIColor.clearColor()
        
    }
    
    func dismissAnimated(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.willDismissBlock?()
            self.viewController.dismissViewControllerAnimated(animated, completion: nil)
            self.didDismissBlock?()
            self._retainSelf = nil
        }
    }
    
    func presentFromViewController(viewController: UIViewController, view: UIView, permittedArrowDirections: UIPopoverArrowDirection = UIPopoverArrowDirection.Any, rect: CGRect? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        self._retainSelf = self
        
        self.viewController.popoverPresentationController?.sourceView = view
        self.viewController.popoverPresentationController?.sourceRect = rect != nil ? rect! : view.bounds
        self.viewController.popoverPresentationController?.delegate = self
        self.viewController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        
        viewController.presentViewController(self.viewController, animated: animated, completion: completion)
    }
}


// MARK: -
// MARK: - Delegate -

extension EPCPopover: UIPopoverPresentationControllerDelegate {
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    public func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        willDismissBlock?()
        return true
    }
    
    public func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        didDismissBlock?()
        _retainSelf = nil
    }
}