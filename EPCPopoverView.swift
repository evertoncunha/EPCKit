//
//  EPCPopoverView.swift
//  SmartSales
//
//  Created by Everton Cunha on 11/03/16.
//  Copyright © 2016 Intermidia. All rights reserved.
//

import UIKit

public class EPCPopoverView: EPCPopover {
    
    // MARK: -
    // MARK: - Public Methods -
    
    public convenience init(text: String, font: UIFont? = nil) {
        
        self.init()

        let label = UILabel(frame: CGRectZero)
        if font != nil {
            label.font = font
        }
        label.text = text
        
        label.sizeToFit()
        
        var frame = label.frame
        frame.origin.y = 8
        frame.origin.x = 8
        
        label.frame = frame
        
        frame.size.width += 16
        frame.size.height += 16
        
        super.viewController.view.frame = frame
        
        viewController.view.addSubview(label)
        
        viewController.preferredContentSize = frame.size
    }
    
    public convenience init(view: UIView) {
        self.init()
        
        viewController.view.addSubview(view)
        viewController.view.sizeToFit()
        
        viewController.preferredContentSize = viewController.view.frame.size
    }
    
}

