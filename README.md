# ISImagePicker
iOS ImagePicker(like wechat) written in Swift with PhotoKit 

![image](https://github.com/invictus-lee/ISImagePicker/blob/master/imagepicker.gif)

##Support
* Xcode8.0
* Swfit3.0 (Objective-C Not Supported)
* iOS8.0
* Device Support: Universal
* Device Orientaion Support:All

##UseAge
<pre code>
//conform ISImagePickerControllerDelegate
 let options:[ISImagePickerOption] = [
            .MaxImagesCount(9),
            .IsPickVideo(false),
            .IsPickImage(true),
            .IsShowTakePictureBtn(true),
            .ColumnCount(4),
            .ColumnMargin(5),
            .Bundle("ISImagePicker.bundle"),
            .SelImg("photo_sel_photoPickerVc.png"),
            .UnSelImg("photo_def_previewVc.png"),
            .PreNumImg("preview_number_icon.png"),
            .NavBackItemImg("navi_back.png"),
            .NavBarTintColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
            .NavBarItemColor(UIColor.white),
            ISImagePickerOption.PreviewImageMaxZoom(20),
            .ExpectImageWidth(400.0),
            .IsAllowSelecteOrignalImage(true)
        ]
        let imagePicker = ISImagePickerController(options: options)
        imagePicker.imagePickerDelegate = self
        self.present(imagePicker, animated: true, completion: nil)
</pre code>     
## Implement ISImagePickerControllerDelegate Method
<pre code>
 func imagePicker(picker:ISImagePickerController , didFinishPickImages images:[UIImage], sourceAssets assets:[ISAssetModel] ,isSelectOriginalImage:Bool ){
}
 func imagePickerDidCancel(picker:ISImagePickerController){
}
   </pre code>
