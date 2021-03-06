//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import CoreFoundation
import AssetsLibrary
import MobileCoreServices
import UIKit

protocol UploadImageProtocol {
    func didSelectImageToUpload(_ image:UIImage) -> UIImage
}

class UploadImageController: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func showCameraCaptureInViewController(_ viewController:UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = setupPickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            viewController.present(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    func showPhotoLibraryPickerInViewController(_ viewController:UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = setupPickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            viewController.present(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? NSString{
            if (CFStringCompare(mediaType , kUTTypeImage, .compareCaseInsensitive) == CFComparisonResult.compareEqualTo ){
                _ = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                
                var refURL = info[UIImagePickerControllerReferenceURL] as! URL?;
                if refURL == nil {
                    refURL = info[UIImagePickerControllerMediaURL] as! URL?;
                }
                if let actualMediaURL = refURL as URL! {
                    var fileName = "temp.jpg"
                    let assetLibrary = ALAssetsLibrary()
                    assetLibrary.asset(for: actualMediaURL , resultBlock: { asset in
                        if let actualAsset = asset as ALAsset? {
                            let assetRep: ALAssetRepresentation = actualAsset.defaultRepresentation()
                            fileName = assetRep.filename()
                            let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                            let image = UIImage(cgImage: iref)
                            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                            let documentsDir = paths.firstObject as! NSString?
                            if let documentsDirectory = documentsDir {
                                let localFilePath = documentsDirectory.appendingPathComponent(fileName)
                                let data = UIImageJPEGRepresentation(image, 1.0)
                                _ = (try? data!.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])) != nil
                                let localFileURL = URL(fileURLWithPath: localFilePath)
                                let appDelegate = UIApplication.shared.delegate as! SHCAppDelegate
                                picker.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
                                    appDelegate.uploadImage(with: localFileURL)
                                    UIApplication.shared.statusBarStyle = .lightContent
                                })
                            }
                        }
                        }, failureBlock: { (error) -> Void in
                            
                    })
                } else {
                    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                    let documentsDir = paths.firstObject as! NSString?
                    if let documentsDirectory = documentsDir {
                        let localFilePath = documentsDirectory.appendingPathComponent(Date().prettyStringWithJPGExtension())
                        let data = UIImageJPEGRepresentation(image, 1.0)
                        _ = (try? data!.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])) != nil
                        let localFileURL = URL(fileURLWithPath: localFilePath)
                        let appDelegate = UIApplication.shared.delegate as! SHCAppDelegate
                        picker.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
                            appDelegate.uploadImage(with: localFileURL)
                            UIApplication.shared.statusBarStyle = .lightContent
                        })
                    }
                }
            } else {
                let movieURL = info[UIImagePickerControllerMediaURL] as! URL
                _ = movieURL.path
                _ = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                let documentsDir = paths.firstObject as! NSString?
                var name = movieURL.path.components(separatedBy: "/").last as String!
                name = name?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                if let documentsDirectory = documentsDir {
                    let localFilePath = documentsDirectory.appendingPathComponent(Date().prettyStringWithMOVExtension())
                    let data = try! Data(contentsOf: movieURL)
                    _ = (try? data.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])) != nil
                    let localFileURL = URL(fileURLWithPath: localFilePath)
                    let appDelegate = UIApplication.shared.delegate as! SHCAppDelegate
                    picker.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
                        appDelegate.uploadImage(with: localFileURL)
                        UIApplication.shared.statusBarStyle = .lightContent
                    })
                }
            }
        }
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        let orientation = UIApplication.shared.statusBarOrientation
        return orientation
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    fileprivate func setupPickerController() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.delegate = self
        imagePicker.mediaTypes = NSArray(objects:kUTTypeImage,kUTTypeVideo,kUTTypeMovie) as! [String]
        return imagePicker
    }
}
