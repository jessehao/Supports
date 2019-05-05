//
//  General.swift
//  Supports
//
//  Created by Jesse Hao on 2019/5/5.
//

import Foundation

protocol MetatypeSupport {}
extension MetatypeSupport {
	typealias Metatype = Self
	var metatype:Self.Type {
		return type(of: self)
	}
}

// MARK: - SystemImagePickerSupport
protocol SystemImagePickerSupport : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	@discardableResult func presentImagePickerActionSheet() -> Bool
	@discardableResult func presentImagePicker(type:UIImagePickerController.SourceType) -> Bool
}

extension SystemImagePickerSupport where Self : UIViewController {
	@discardableResult func presentImagePickerActionSheet(titleForTakePhoto:String, titleForChooseFromPhotos:String, titleForCancel:String) -> Bool {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		sheet.addAction(UIAlertAction(title: titleForTakePhoto, style: .default, handler: { [weak self] _ in
			guard let self = self else { return }
			self.presentImagePicker(type: .camera)
			sheet.dismiss(animated: true)
		}))
		sheet.addAction(UIAlertAction(title: titleForChooseFromPhotos, style: .default, handler: { [weak self] _ in
			guard let self = self else { return }
			self.presentImagePicker(type: .photoLibrary)
			sheet.dismiss(animated: true)
		}))
		sheet.addAction(UIAlertAction(title: titleForCancel, style: .cancel))
		self.present(sheet, animated: true)
		return true
	}
	
	@discardableResult func presentImagePicker(type:UIImagePickerController.SourceType) -> Bool {
		let destination = UIImagePickerController()
		destination.delegate = self
		destination.sourceType = type
		self.present(destination, animated: true)
		return true
	}
}

// MARK: - ConversionSupport
public protocol ConversionSupport {
	func convert<T>(_ handler:(Self) -> T) -> T
}

public extension ConversionSupport {
	func convert<T>(_ handler:(Self) -> T) -> T {
		return handler(self)
	}
}

// MARK: - Pasteboard Support
public protocol StandardPasteboardSupport {
	func copyToGeneralPasteboard(withString string:String)
}

public extension StandardPasteboardSupport {
	func copyToGeneralPasteboard(withString string:String) {
		UIPasteboard.general.string = string
	}
}

// MARK: - Convenient Right NavigationBarButtonItem Support
/// Conform this protocol could help you set right navigation bar button item really fast.
///
///	all you need to do is:
/// 1. write `func rightNavigationBarButtonItemTouched(sender:UIBarButtonItem)` in your adopter body.
///	2. if adopted by a UIViewController or its subclass, invoke `setRightNavigationBarButtonItem(_ onConfig:(UIBarButtonItem) -> Void)` after the navigation controller loaded the destination view controller.
@objc
public protocol ConvenientRightNavigationBarButtonItemSupport : class {
	@objc
	func rightNavigationBarButtonItemTouched(sender:UIBarButtonItem)
	
	var navigationItem: UINavigationItem { get }
}

public extension ConvenientRightNavigationBarButtonItemSupport {
	@discardableResult
	func prepareRightNavigationBarButtonItemSupport(_ title:String? = nil) -> UIBarButtonItem {
		let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.rightNavigationBarButtonItemTouched(sender:)))
		self.navigationItem.rightBarButtonItem = item
		return item
	}
}

// MARK: - Convenient RefreshControl Support
@objc
public protocol ConvenientRefreshControlSupport : class {
	@objc
	func refreshControlValueChanged(sender:UIRefreshControl)
}

public extension ConvenientRefreshControlSupport {
	@discardableResult
	func prepareRefreshControlSupport(for scrollView:UIScrollView) -> UIRefreshControl {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
		if #available(iOS 10.0, *) {
			scrollView.refreshControl = refreshControl
		} else {
			scrollView.addSubview(refreshControl)
		}
		return refreshControl
	}
}

public extension ConvenientRefreshControlSupport where Self : UITableViewController {
	@discardableResult
	func prepareRefreshControlSupport() -> UIRefreshControl {
		let retval = UIRefreshControl()
		retval.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
		self.refreshControl = retval
		return retval
	}
}

// MARK: - TableView Update Support
public protocol TableViewUpdateSupport {}
public extension TableViewUpdateSupport where Self : UITableView {
	func updates(_ operation:((Self) -> Void)? = nil) {
		self.beginUpdates()
		operation?(self)
		self.endUpdates()
	}
}

public protocol NullableSupport {}

public extension NullableSupport {
	/// Return nil if condition is false
	///
	/// - Parameter condition: condition closure
	/// - Returns: This object
	func orNil(condition:(Self) -> Bool) -> Self? {
		return condition(self) ? self : nil
	}
}
