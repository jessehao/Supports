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
