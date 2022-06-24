//
//  ViewController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import UIKit


class ImageCollectionView:UICollectionViewCell{
    var image:UIImage?{
        didSet{
            let imageView = UIImageView(frame: self.contentView.frame)
            imageView.image = image
            self.contentView.addSubview(imageView)
        }
    }
}

class ViewController: UIViewController,ISImagePickerControllerDelegate ,UICollectionViewDelegate,UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
    var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectView()
    }
    
    func setupCollectView(){
        let layout = UICollectionViewFlowLayout()
        let itemWH = (self.view.frame.width - CGFloat(IS_IMG_PICK_CONFIG.columnCount+1)*CGFloat(IS_IMG_PICK_CONFIG.columnMargin))/CGFloat(IS_IMG_PICK_CONFIG.columnCount)
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = IS_IMG_PICK_CONFIG.columnMargin
        layout.minimumInteritemSpacing = IS_IMG_PICK_CONFIG.columnMargin
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(ImageCollectionView.self, forCellWithReuseIdentifier: "ImageCollectionView")
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
        let options:[ISImagePickerOption] = [
            .MaxImagesCount(9),
            ISImagePickerOption.IsPickVideo(false),
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
    }
    func imagePicker(picker:ISImagePickerController , didFinishPickImages images:[UIImage], sourceAssets assets:[ISAssetModel] ,isSelectOriginalImage:Bool ){
       self.images = images
       collectionView.reloadData()
    }
    func imagePickerDidCancel(picker:ISImagePickerController){
    
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->UICollectionViewCell{
        let cell:ImageCollectionView = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionView", for: indexPath) as! ImageCollectionView
        cell.image = images[indexPath.row]
        return cell
    }
}

