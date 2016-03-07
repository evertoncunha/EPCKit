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

//MARK: - STRING
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
	
	//MARK: - Path
	
	var lastPathComponent: String {
		get {
			return (self as NSString).lastPathComponent
		}
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
	
	func stringByAppendingPathComponent(str: String) -> String {
		return (self as NSString).stringByAppendingPathComponent(str)
	}
}

//MARK: - NSURL
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

