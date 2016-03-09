//
//  EPCExtensions.swift
//  LTvFramework
//
//  Created by Everton Cunha on 23/01/16.
//  Copyright © 2016 Everton Cunha. All rights reserved.
//

#if TARGET_OS_X
	import Cocoa
#else
	import Foundation
	import UIKit
#endif

public func DLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
//	#if DEBUG
	NSLog("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
//	#endif
}

public func Localized(string: String?) -> String? {
	if string != nil {
		return NSLocalizedString(string!, comment: "")
	}
	return nil
}

public func dispatch_async_in_background(block:dispatch_block_t) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
}

public func dispatch_async_in_main(block:dispatch_block_t) {
	dispatch_async(dispatch_get_main_queue(), block)
}

public func dispatch_sync_in_main(block:dispatch_block_t) {
	dispatch_sync(dispatch_get_main_queue(), block)
}

// MARK: - STRING
public extension String {
	
	public func arrayByExploding(string: String) -> Array<String> {
		
		let end = self.startIndex.advancedBy(self.characters.count)
		
		var b: Range<Index>? = Range<Index>(start: self.startIndex, end: self.startIndex)
		
		var result = Array<String>()
		
		while b != nil {
			
			let e = self.rangeOfString(string, options: [], range: Range<String.Index>(start: b!.endIndex, end: end))
			
			let s:String
			
			if e != nil {
				s = self.substringWithRange(Range<Index>(start: b!.endIndex, end: e!.startIndex))
			}
			else {
				s = self.substringFromIndex(b!.endIndex)
			}
			
			if s.characters.count > 0 {
				result.append(s)
			}
			
			b = e
		}

		return result
	}
	
	// MARK: - Path
	
	var lastPathComponent: String {
		get {
			return (self as NSString).lastPathComponent
		}
	}
	
	func stringByAppendingPathComponent(str: String) -> String {
		return (self as NSString).stringByAppendingPathComponent(str)
	}
	
	var stringByDeletingPathExtension: String {
		get {
			return (self as NSString).stringByDeletingPathExtension
		}
	}
	
	var stringByDeletingLastPathComponent: String {
		get {
			return (self as NSString).stringByDeletingLastPathComponent
		}
	}
	
}

// MARK: - NSURL
public extension NSURL {
	
	var uniformTypeIdentifier: String {
		get {
			var uniformTypeIdentifier: AnyObject?
			_ = try? self.getResourceValue(&uniformTypeIdentifier, forKey: NSURLTypeIdentifierKey)
			if uniformTypeIdentifier != nil {
				return uniformTypeIdentifier as! String
			}
			return ""
		}
	}
}

// MARK: - UIView

public extension UIView {
	
	public class func animateWithKeyboardNotification(notification: NSNotification, delay: NSTimeInterval = 0.0, animations: () -> Void, completion: ((Bool) -> Void)?) {
		
		let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
		
		let curve = UIViewAnimationOptions(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntegerValue)
		
		UIView.animateWithDuration(duration, delay: delay, options: curve, animations: animations, completion: completion)
	}
	
	public var frameHeight: CGFloat {
		get {
			return self.frame.size.height
		}
		set (v) {
			var fra = self.frame
			fra.size.height = v
			self.frame = fra
		}
	}
	
	public var frameOrigin: CGPoint {
		get {
			return self.frame.origin
		}
		set (v) {
			var fra = self.frame
			fra.origin = v
			self.frame = fra
		}
	}
	
	public var frameSize: CGSize {
		get {
			return self.frame.size
		}
		set (v) {
			var fra = self.frame
			fra.size = v
			self.frame = fra
		}
	}
	
	public var frameWidth: CGFloat {
		get {
			return self.frame.size.width
		}
		set (v) {
			var fra = self.frame
			fra.size.width = v
			self.frame = fra
		}
	}
	
	public var frameX: CGFloat {
		get {
			return self.frame.origin.x
		}
		set (v) {
			var fra = self.frame
			fra.origin.x = v
			self.frame = fra
		}
	}
	
	public var frameY: CGFloat {
		get {
			return self.frame.origin.y
		}
		set (v) {
			var fra = self.frame
			fra.origin.y = v
			self.frame = fra
		}
	}
	
}

// MARK: - UIResponder

extension UIResponder {

	private weak static var _currentFirstResponder: UITextField? = nil
	
	public class func currentFirstResponder() -> UITextField? {
		UIResponder._currentFirstResponder = nil
		UIApplication.sharedApplication().sendAction("findFirstResponder:", to: nil, from: nil, forEvent: nil)
		return UIResponder._currentFirstResponder
	}
	
	internal func findFirstResponder(sender: AnyObject) {
		if self.isKindOfClass(UITextField) {
			UIResponder._currentFirstResponder = self as? UITextField
		}
	}
}

// MARK: UIApplication

extension UIApplication {
	
	static var applicationDocumentsDirectory: NSURL {
		get {
			return EPCKit.sharedInstance.applicationDocumentsDirectory
		}
	}
}

// MARK: EPCKit Aux

class EPCKit: NSObject {
	
	static let sharedInstance = EPCKit()
	
	override private init() {}
	
	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
	}()
	
}
