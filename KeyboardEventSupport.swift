//
//  KeyboardEventSupport.swift
//  Supports
//
//  Created by Jesse Hao on 2019/5/5.
//

import Foundation

public struct StandardKeyboardNotificationUserInfo {
	public var animationCurve:UIView.AnimationCurve?
	public var animationDuration:Double?
	public var isLocal:Bool?
	public var beginFrame:CGRect?
	public var endFrame:CGRect?
	
	public init() {}
	
	public init(withUserInfoDict userInfo:[AnyHashable : Any]) {
		self.init()
		self.setValues(withUserInfoDict: userInfo)
	}
	
	public mutating func setValues(withUserInfoDict userInfo:[AnyHashable : Any]) {
		self.animationCurve = UIView.AnimationCurve(rawValue: Int(truncating: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber))
		self.animationDuration = Double(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
		self.isLocal = Bool(truncating: userInfo[UIResponder.keyboardIsLocalUserInfoKey] as! NSNumber)
		self.beginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		self.endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
	}
}

public protocol KeyboardEventSupport : class {
	/// Called immediately prior to the display of the keyboard. **configured in `GeneralViewController.addToNotificationCenter`**
	///
	/// - Parameter userInfo: The userInfo contains information about the keyboard.
	func keyboardWillShow(userInfo:StandardKeyboardNotificationUserInfo)
	
	/// Called immediately prior to the dismissal of the keyboard.  **configured in `GeneralViewController.addToNotificationCenter`**
	///
	/// - Parameter userInfo: The userInfo contains information about the keyboard.
	func keyboardWillHide(userInfo:StandardKeyboardNotificationUserInfo)
	
	/// Called immediately prior to a change in the keyboard’s frame.  **configured in `GeneralViewController.addToNotificationCenter`**
	///
	/// - Parameter userInfo: The userInfo contains information about the keyboard.
	func keyboardWillChangeFrame(userInfo:StandardKeyboardNotificationUserInfo)
	
	func keyboardDidShow(userInfo:StandardKeyboardNotificationUserInfo)
	
	func keyboardDidHide(userInfo:StandardKeyboardNotificationUserInfo)
	
	func keyboardDidChangeFrame(userInfo:StandardKeyboardNotificationUserInfo)
}

public extension KeyboardEventSupport {
	func registerKeyboardEvent() -> NotificationTokenBag {
		let retval = NotificationTokenBag()
		let notificationCenter = NotificationCenter.default
		retval.notificationCenter = notificationCenter
		retval.addNotificationName(UIResponder.keyboardWillShowNotification) { [weak self] in
			self?.keyboardWillShow(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		retval.addNotificationName(UIResponder.keyboardWillHideNotification) { [weak self] in
			self?.keyboardWillHide(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		retval.addNotificationName(UIResponder.keyboardWillChangeFrameNotification) { [weak self] in
			self?.keyboardWillChangeFrame(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		retval.addNotificationName(UIResponder.keyboardDidShowNotification) { [weak self] in
			self?.keyboardDidShow(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		retval.addNotificationName(UIResponder.keyboardDidHideNotification) { [weak self] in
			self?.keyboardDidHide(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		retval.addNotificationName(UIResponder.keyboardDidChangeFrameNotification) { [weak self] in
			self?.keyboardDidChangeFrame(userInfo: StandardKeyboardNotificationUserInfo(withUserInfoDict: $0.userInfo!))
		}
		return retval
	}
	func keyboardWillShow(userInfo:StandardKeyboardNotificationUserInfo) {}
	func keyboardWillHide(userInfo:StandardKeyboardNotificationUserInfo) {}
	func keyboardWillChangeFrame(userInfo:StandardKeyboardNotificationUserInfo) {}
	func keyboardDidShow(userInfo:StandardKeyboardNotificationUserInfo) {}
	func keyboardDidHide(userInfo:StandardKeyboardNotificationUserInfo) {}
	func keyboardDidChangeFrame(userInfo:StandardKeyboardNotificationUserInfo) {}
}

public final class NotificationTokenBag {
	var tokens:[NSObjectProtocol] = []
	weak var notificationCenter:NotificationCenter?
	
	deinit {
		self.removeAllTokens()
	}
}

public extension NotificationTokenBag {
	@discardableResult
	func addNotificationName(_ name:Notification.Name, object:Any? = nil, queue:OperationQueue? = nil, using handler:@escaping (Notification) -> Void) -> Bool {
		guard let center = self.notificationCenter else { return false }
		self.tokens.append(center.addObserver(forName: name, object: object, queue: queue, using: handler))
		return true
	}
	
	func removeAllTokens() {
		while let token = self.tokens.popLast() {
			self.notificationCenter?.removeObserver(token)
		}
	}
}

public extension NotificationTokenBag {
	func append(anotherManger:NotificationTokenBag) {
		self.tokens.append(contentsOf: anotherManger.tokens)
	}
	
	static func += (manager:NotificationTokenBag, another:NotificationTokenBag) {
		manager.append(anotherManger: another)
	}
}
