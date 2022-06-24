//
//  ISImagePickerController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
  static  func loadBundleImage(bundle:String?,name:String) -> UIImage?{
        var ret:UIImage?
        if let bundle = bundle{
            let path = Bundle.main.bundlePath.appending("/\(bundle)")
            let aBundel = Bundle( path:path)
            ret = UIImage(named: name, in:aBundel , compatibleWith: nil);
            if let ret = ret
            {
                return ret
            }
        }
        ret = UIImage(named: name);
        return ret
    }
}

extension String{
    static func localsizeStringFrom( bundle:String?,forkey key:String) -> String {
        var ret:String  = ""
        if let bundle = bundle{
            let path = Bundle.main.bundlePath.appending("/\(bundle)")
            let aBundel = Bundle( path:path)
            if let aBundel = aBundel{
                var languate = NSLocale.preferredLanguages.first
                if ((languate?.range(of: "zh-Hans")) != nil){
                    languate = "en"
                }else {
                    languate = "zh-Hans"
                }
                ret = aBundel.localizedString(forKey: key, value: "", table: nil)
            }
        }
        return ret
    }
}

enum ISImagePickerOption{
    case MaxImagesCount(Int) //max allow to select image count
    case IsPickVideo(Bool)   //is allow  to select video
    case IsPickImage(Bool)   //is allow  to select Image
    case IsShowTakePictureBtn(Bool) //is show take photo btn
    case ColumnCount(Int)           //photo collectionview column count
    case ColumnMargin(Int)          //photo collectionview item margin
    case Bundle(String)             // Bundle name to load resource
    case SelImg(String)             // image selected flag-image
    case UnSelImg(String)           // image unSelected flag-image
    case PreNumImg(String)          // backgroud image for the  preview selected image number
    case NavBackItemImg(String)     // navigation bar backitem image
    case NavBarTintColor(UIColor)   // navigation tint color (backgrond color)
    case NavBarItemColor(UIColor)   // navigation item(title or item's title) color
    case PreviewImageMaxZoom(CGFloat)  // preview image maxzoom
    case ExpectImageWidth(CGFloat)    //expect image width to return
    case IsAllowSelecteOrignalImage(Bool)  // is allow to select orignal image
}

protocol ISImagePickerControllerDelegate {
    func imagePicker(picker:ISImagePickerController , didFinishPickImages images:[UIImage], sourceAssets assets:[ISAssetModel] ,isSelectOriginalImage:Bool );
    func imagePickerDidCancel(picker:ISImagePickerController);
}

struct ISImagePickerConfig{
    var maxIamgesCount = 9
    var isPickeVideo = false
    var isPickeImage = true
    var isShowTakePictureBtn = true
    var columnCount = 4
    var columnMargin:CGFloat = 5
    var bundle = "ISImagePicker.bundle"
    var selImg = "photo_sel_photoPickerVc.png"
    var unSelImg = "photo_def_previewVc.png"
    var preNumImg = "preview_number_icon.png"
    var navBackItemImg = "navi_back.png"
    var navBarTintColor = UIColor.black
    var navBarItemColor = UIColor.white
    var previewImageMaxZoom :CGFloat = 2.0
    var expectImageWidth:CGFloat = 600
    var isAllowSelectOrignalImage = true
    var isSelectOrignalImage = false
}

var IS_IMG_PICK_CONFIG = ISImagePickerConfig()

class ISImagePickerController:UINavigationController{
    
    var imagePickerDelegate:ISImagePickerControllerDelegate?
    init(options:[ISImagePickerOption]?){
        IS_IMG_PICK_CONFIG.isSelectOrignalImage = false
        if let options = options{
            for option in options{
                switch option {
                case let .MaxImagesCount(value):
                    IS_IMG_PICK_CONFIG.maxIamgesCount = value
                case let .IsPickVideo(value):
                    IS_IMG_PICK_CONFIG.isPickeVideo = value
                case let .IsPickImage(value):
                    IS_IMG_PICK_CONFIG.isPickeImage = value
                case let .IsShowTakePictureBtn(value):
                    IS_IMG_PICK_CONFIG.isShowTakePictureBtn = value;
                case let .ColumnCount(value):
                    IS_IMG_PICK_CONFIG.columnCount = value
                case let .ColumnMargin(value):
                    IS_IMG_PICK_CONFIG.columnMargin = CGFloat(value)
                case let .Bundle(value):
                    IS_IMG_PICK_CONFIG.bundle = value
                case let .SelImg(value):
                    IS_IMG_PICK_CONFIG.selImg = value
                case let .UnSelImg(value):
                    IS_IMG_PICK_CONFIG.unSelImg = value
                case let .PreNumImg(value):
                    IS_IMG_PICK_CONFIG.preNumImg = value
                case let .NavBackItemImg(value):
                    IS_IMG_PICK_CONFIG.navBackItemImg = value
                case let .NavBarTintColor(value):
                    IS_IMG_PICK_CONFIG.navBarTintColor = value
                case let .NavBarItemColor(value):
                    IS_IMG_PICK_CONFIG.navBarItemColor = value
                case let .PreviewImageMaxZoom(value):
                    IS_IMG_PICK_CONFIG.previewImageMaxZoom = value
                case let .ExpectImageWidth(value):
                    IS_IMG_PICK_CONFIG.expectImageWidth = value
                case let .IsAllowSelecteOrignalImage(value):
                    IS_IMG_PICK_CONFIG.isAllowSelectOrignalImage = value
                }
            
            }
        }
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = IS_IMG_PICK_CONFIG.navBarItemColor
        navigationBarAppearace.barTintColor = IS_IMG_PICK_CONFIG.navBarTintColor
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:IS_IMG_PICK_CONFIG.navBarItemColor]
        
        let albumPickerController = ISAlbumPickerController()
        super.init(rootViewController: albumPickerController)
        albumPickerController.imagePickerDidEnd = self.imagePickerDidEnd
        albumPickerController.imagePickerDidCancel = self.imagePickerDidCancel
        
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func imagePickerDidEnd(_ images:[UIImage],_ assets:[ISAssetModel],_ isSelectOrignalImage:Bool) -> Void {
        self.imagePickerDelegate?.imagePicker(picker: self, didFinishPickImages: images, sourceAssets: assets, isSelectOriginalImage: isSelectOrignalImage)
        self.dismiss(animated: true, completion: ({
            
        }))
    }
    
    func imagePickerDidCancel() ->Void{
       self.imagePickerDelegate?.imagePickerDidCancel(picker: self)
    }
  
}
