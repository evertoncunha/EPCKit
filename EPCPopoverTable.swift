//
//  EPCPopoverTable.swift
//  SmartSales
//
//  Created by Everton Cunha on 10/03/16.
//  Copyright © 2016 Intermidia. All rights reserved.
//

import UIKit

public class EPCPopoverTable: EPCPopover {

    // MARK: - Vars
    // MARK: Private
    
    private var _cellIdentifier = "cell"
    
    private var _data: [AnyObject]!
    
    private var _dataKeyPath: String?
    
    
    // MARK: Public
	
	public var allowsMultipleSelection: Bool {
		set (v) {
			tableViewController.tableView.allowsMultipleSelection = v
		}
		get {
			return tableViewController.tableView.allowsMultipleSelection
		}
	}
    
    public var didSelectRowBlockShouldDismiss: ((row: Int, rowsSelected:[Int]) -> Bool)?
	
	public var font: UIFont?
	
	public var selectedRows: [Int] {
		get {
			var r = [Int]()
			if let a = tableViewController.tableView.indexPathsForSelectedRows {
				for i in a {
					r.append(i.row)
				}
			}
			return r
		}
	}
    
	public let tableViewController = UITableViewController(style: .Plain)
	
	public var width: CGFloat?
	
    
    // MARK: - Override
    
    override public var viewController: UIViewController {
        get {
            return tableViewController
        }
        set (v) {
            
        }
    }
	
    // MARK: -
    // MARK: - Public Methods -
	
	public convenience init(data: [AnyObject], keyPath: String) {
		
		self.init()
		
		_data = data
		_dataKeyPath = keyPath
	}
	
	public convenience init(data: [String]) {
		
		self.init()
		
		_data = data
	}
	
	private override init() {
		
		super.init()
		
		tableViewController.modalPresentationStyle = .Popover
		
		tableViewController.tableView.dataSource = self
		tableViewController.tableView.delegate = self
		tableViewController.tableView.backgroundColor = UIColor.clearColor()
        tableViewController.clearsSelectionOnViewWillAppear = false
		
	}
	
	deinit {
		print(__FILE__ + __FUNCTION__)
	}
    
    
    public func cellForIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        var c = tableView.dequeueReusableCellWithIdentifier(_cellIdentifier)
        if c == nil {
            c = UITableViewCell(style: .Default, reuseIdentifier: _cellIdentifier)
            if font != nil {
                c!.textLabel?.font = font
            }
            c!.selectionStyle = .None
            c!.backgroundColor = UIColor.clearColor()
        }
        return c!
    }
    
    public func selectRow(row: Int) {
        tableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    public func selectRows(rows: [Int]) {
        for i in rows {
            tableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false, scrollPosition: .Middle)
        }
    }
    
}



// MARK: -
// MARK: - Private Methods -

private extension EPCPopoverTable {
	
	func stringForRow(row: Int) -> String {
		if _dataKeyPath != nil {
			return (_data[row].valueForKeyPath(_dataKeyPath!) as! String)
		}
		else {
			return (_data[row] as! String)
		}
	}
}


// MARK: -
// MARK: - Protocols -

extension EPCPopoverTable: UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _data.count
	}
	
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = self.cellForIndexPath(indexPath, tableView: tableView)
		
		if tableView.indexPathsForSelectedRows?.contains(indexPath) == true {
			cell.accessoryType = .Checkmark
		}
		else {
			cell.accessoryType = .None
		}
		
		cell.textLabel?.text = self.stringForRow(indexPath.row)
		
		return cell
	}
}

extension EPCPopoverTable: UITableViewDelegate {
	
	// MARK: UITableViewDelegate
	
	public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			cell.accessoryType = .None
		}
		
		if didSelectRowBlockShouldDismiss?(row: indexPath.row, rowsSelected: self.selectedRows) == true {
			self.dismissAnimated(true)
		}
	}
	
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			cell.accessoryType = .Checkmark
		}
		
		if didSelectRowBlockShouldDismiss?(row: indexPath.row, rowsSelected: self.selectedRows) == true {
			self.dismissAnimated(true)
		}
		
	}

}

extension EPCPopoverTable {
	
	// MARK: UIPopoverPresentationControllerDelegate
	
	public func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
		
		tableViewController.tableView.sizeToFit()
		
		let w: CGFloat = {
		
			if self.width == nil {
			
				var width:CGFloat = popoverPresentationController.sourceView!.bounds.size.width
				
				if _data.count>0, let cell = tableViewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
					
					var font: UIFont
					
					if self.font != nil {
						font = self.font!
					}
					else {
						font = cell.textLabel!.font
					}
					
					let height = cell.textLabel!.frame.size.height
					
					let maxWidth = UIScreen.mainScreen().bounds.size.width
					
					for i in 0..._data.count-1 {
						let str = self.stringForRow(i)
						
						let r = (str as NSString).boundingRectWithSize(CGSizeMake(maxWidth, height), options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName:font], context: nil)
						
						width = max(width, r.size.width)
					}
					
					width += 70
				}
				
				return width
			}
			return self.width!
		}()
		
		var size = tableViewController.tableView.frame.size
		size.width = w
		
		tableViewController.preferredContentSize = size
	}
	
}
