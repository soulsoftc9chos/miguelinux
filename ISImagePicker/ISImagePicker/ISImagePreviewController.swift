//
//  ISImagePreviewViewController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/22.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit


class ISImagePreviewCell:UICollectionViewCell,UIScrollViewDelegate{
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    var asset:ISAssetModel?{
        didSet{
           self.backgroundColor = UIColor.black
            self.contentView.backgroundColor = UIColor.black
            scrollView.frame = self.contentView.frame
            scrollView.bouncesZoom = true
            scrollView.maximumZoomScale = CGFloat(IS_IMG_PICK_CONFIG.previewImageMaxZoom)
            scrollView.minimumZoomScale = 1.0
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.backgroundColor = UIColor.black
            scrollView.delegate = self
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.isMultipleTouchEnabled = true
            imageView.frame = scrollView.frame
            scrollView.addSubview(imageView)
            self.contentView.addSubview(scrollView)
            let singleTapGes = UITapGestureRecognizer(target: self, action: #selector(singleTap(ges:)))
            let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(doubleTap(ges:)))
            doubleTapGes.numberOfTapsRequired = 2
            singleTapGes.require(toFail: doubleTapGes)
            imageView.addGestureRecognizer(singleTapGes)
            imageView.addGestureRecognizer(doubleTapGes)
            print("preview item size \(self.contentView.frame.size)")
            if let image = self.asset?.image{
                self.imageView.image = image
            }else {
                ISAssetManager.shareInstance.getAssetImgage(asset:self.asset! , expectWidth: IS_IMG_PICK_CONFIG.expectImageWidth) { (retImg:UIImage) in
                    self.imageView.image = retImg
                    self.asset?.image = retImg
                }
            }
            
            
        }
    }
   
    func singleTap(ges:UITapGestureRecognizer) -> Void{
    }
    func doubleTap(ges:UITapGestureRecognizer) -> Void{
      
        if(self.scrollView.zoomScale>1.0){
            self.scrollView.setZoomScale(1.0, animated: true)
        }else {
            let scale = scrollView.maximumZoomScale
            let point = ges.location(in: ges.view)
            let scrollSize = imageView.frame.size
            let size = CGSize(width: scrollSize.width / scale,
                              height: scrollSize.height / scale)
            let origin = CGPoint(x: point.x - size.width / 2.0,
                                 y: point.y - size.height / 2.0)
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

class ISImagePreiewController:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
    let album:ISAlbumModel
    let assets:[ISAssetModel]
    var index:Int
    var collectionView:UICollectionView?
    let bottomBar = UIView()
    let selBtn = UIButton()
    let previewNumLabel =  UILabel()
    let previewNumBack = UIImageView()
    let orignalImageBtn = UIButton()
    let orignalImageLabel = UILabel()
    let conformBtn = UIButton()
    
    var selHandler:((_ asset:ISAssetModel,_ image:UIImage)->(Bool))?
    var imagePickEndHandler:(()->())?
    init(album:ISAlbumModel,index:Int,isSelectedReview:Bool){
        self.album = album
        self.index = index
        if (isSelectedReview)
        {
            assets = self.album.selectAssets
        }else {
            assets = self.album.assets
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setupCollectionView(width: self.view.frame.width,height: self.view.frame.height)
        self.setupNavigationBar()
        self.setupBottomBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateOrignalImageInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        let layout:UICollectionViewFlowLayout =  collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize =  size
//        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.removeFromSuperview()
        self.setupCollectionView(width: size.width, height: size.height)
    }
    
    func setupNavigationBar() -> Void{
        self.navigationController?.isNavigationBarHidden = true
        let navBar = UIView()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let backBtn = UIButton()
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(backBtn)
        selBtn.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(selBtn)
        self.view.addSubview(navBar)
        navBar.backgroundColor = UIColor.black
        navBar.alpha = 0.6
        backBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.navBackItemImg), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(backAct(sender:)), for: UIControlEvents.touchUpInside)
     
        selBtn.addTarget(self, action: #selector(selImgAct(sender:)), for: UIControlEvents.touchUpInside)
        
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[backBtn(==44)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["backBtn":backBtn]))
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[backBtn(==44)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["backBtn":backBtn]))
       
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selBtn(==44)]-10-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn]))
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selBtn(==44)]-10-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn]))
        

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[navBar(==64)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["navBar":navBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[navBar]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["navBar":navBar]))
        
    }
    func setupCollectionView(width:CGFloat,height:CGFloat) ->Void{
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame:CGRect(x:0,y:0,width:width,height:height), collectionViewLayout: layout)
        if let collectionView = collectionView{
            self.view.insertSubview(collectionView, at: 0)
            collectionView.backgroundColor = UIColor.black
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = UIColor.white
            collectionView.isPagingEnabled = true
            collectionView.bounces = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.alwaysBounceVertical = true
            collectionView.register(ISImagePreviewCell.self, forCellWithReuseIdentifier:"ISImagePreviewCell")
            collectionView.setContentOffset(CGPoint(x:CGFloat(index)*collectionView.frame.width,y:0), animated: false)
            self.updateSelBtnState()
            self.scrollViewDidScroll(collectionView)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
        }
       
    }
    func setupBottomBar() -> Void{
        self.view.addSubview(bottomBar)
        bottomBar.backgroundColor = UIColor.gray
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        previewNumBack.translatesAutoresizingMaskIntoConstraints = false
        previewNumBack.image = UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name:IS_IMG_PICK_CONFIG.preNumImg)
        previewNumLabel.translatesAutoresizingMaskIntoConstraints = false
        previewNumLabel.textAlignment = NSTextAlignment.center
        previewNumLabel.textColor = UIColor.white
        previewNumLabel.font = UIFont.systemFont(ofSize: 14)
        previewNumBack.addSubview(previewNumLabel)
        bottomBar.addSubview(previewNumBack)
        
        conformBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(conformBtn)
        orignalImageLabel.textColor = UIColor.white
        orignalImageLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(orignalImageLabel)
        orignalImageBtn.translatesAutoresizingMaskIntoConstraints = false
        orignalImageBtn.addTarget(self, action: #selector(orignalImgBtnAct(sender:)), for: UIControlEvents.touchUpInside)
    
        
        bottomBar.addSubview(orignalImageBtn)
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[orignalImageBtn]-10-[orignalImageLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["orignalImageBtn":orignalImageBtn,"orignalImageLabel":orignalImageLabel]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previewNumBack(>=25)]-[conformBtn]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"conformBtn":conformBtn]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[orignalImageBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["orignalImageBtn":orignalImageBtn]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[orignalImageLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["orignalImageLabel":orignalImageLabel]))
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[conformBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["conformBtn":conformBtn]))
        
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumBack]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"previewNumLabel":previewNumLabel,"conformBtn":conformBtn]))
        
        
        
        conformBtn.setTitle("确定", for: UIControlState.normal)
        conformBtn.addTarget(self, action: #selector(pickDown(sender:)), for: UIControlEvents.touchUpInside)
        
        previewNumLabel.text = "\(self.album.selectAssets.count)"
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomBar(==44.0)]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
        
    }
    func backAct(sender:UIButton) -> Void{
       _ = self.navigationController?.popViewController(animated: true)
    }
    func orignalImgBtnAct(sender:UIButton) ->Void{
        IS_IMG_PICK_CONFIG.isSelectOrignalImage = !IS_IMG_PICK_CONFIG.isSelectOrignalImage
          self.updateOrignalImageInfo()
    }
    func updateOrignalImageInfo() -> Void{
        if IS_IMG_PICK_CONFIG.isSelectOrignalImage {
            orignalImageBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
            ISAssetManager.shareInstance.getAssetImageOriginalSize(assets: album.selectAssets, completion: { (size:String) in
                self.orignalImageLabel.text = String.localsizeStringFrom(bundle:IS_IMG_PICK_CONFIG.bundle, forkey:"Full image").appending(size)
            })
        }else {
            orignalImageBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
            orignalImageLabel.text = String.localsizeStringFrom(bundle:IS_IMG_PICK_CONFIG.bundle, forkey:"Full image")
        }
    }
    func updateSelBtnState() -> Void {
        let asset:ISAssetModel = assets[index]
        if asset.isSeleted{
            selBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
        }else {
            selBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
        }
    }
    func pickDown(sender:UIButton) ->Void{
        if let imagePickEndHandler = imagePickEndHandler{
            imagePickEndHandler()
        }
    }
    
    func selImgAct(sender:UIButton) -> Void{
        
        if let selHandler = selHandler{
            let asset:ISAssetModel = assets[index]
            if selHandler(asset,asset.image!) {
                previewNumLabel.text = "\(self.album.selectAssets.count)"
                self.updateOrignalImageInfo()
                if asset.isSeleted{
                    selBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
                }else {
                    selBtn.setImage(UIImage.loadBundleImage(bundle: IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
                }
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell:ISImagePreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISImagePreviewCell", for: indexPath) as! ISImagePreviewCell
            cell.asset = assets[indexPath.row]
            return cell
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let  newIdex = Int(scrollView.contentOffset.x/scrollView.frame.width)
        if index != newIdex {
            index = newIdex
           self.updateSelBtnState()
        }
    }
}
