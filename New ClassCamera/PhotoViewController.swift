//
//  PhotoViewController.swift
//  New ClassCamera
//
//  Created by 无敌帅的yyyyy on 2019/4/7.
//  Copyright © 2019 无敌帅的yyyy. All rights reserved.
//

import UIKit
import SnapKit
class PhotoViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var shake = false
    var checkedButton:UIButton?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        addReturnButton()
        initDeleteButton()
        initCheckedButton()
        setCollectionviewLayout()
    }
    
    @objc private func deleted(){
        if !shake{
            shake = true
            checkedButton?.isHidden = false
            photoCollection.reloadData()
        }else{
            shake = false
            photoCollection.reloadData()
        }
    }
    @objc private func checkedForDelete(){
        for Mcell in photoCollection.visibleCells{
            let cell = Mcell as! CellForImage
            if cell.isPicked{
                let indexPath = photoCollection.indexPath(for: cell)
                let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(photoModel.shared.pickedTwice!.AlbumName!+String(indexPath!.item))
                try! FileManager.default.removeItem(at: imageUrl)
                reSetFileURL(with:photoModel.shared.pickedTwice!.AlbumName!)
                photoModel.shared.pickedTwice!.theTotalNumberofPhotoInthisAlbum! -= 1
                photoCollection.reloadData()
                cell.isPicked = false
            }
        }
        shake = false
        
    }
    private func reSetFileURL(with name:String){
        var i = 0
        var flag = true
        while(true){
            
            let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name+String(i)).path
            if !FileManager.default.fileExists(atPath: imageUrl){
                let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name+String(i))
                let imageUrl2 = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name+String(i+1))
                if !FileManager.default.fileExists(atPath: imageUrl2.path){
                    return
                }
                let data = try! Data(contentsOf: imageUrl2)

                try! data.write(to: url)
                try! FileManager.default.removeItem(at: imageUrl2)
                
                
                
                
                
            }
            if flag{
                for album in photoModel.shared.pickedOne!{
                    if album.AlbumName == name{
                        album.theTotalNumberofPhotoInthisAlbum! -= 1
                        print(album.theTotalNumberofPhotoInthisAlbum!)
                        print(album.AlbumName!)
                    }
                }
                flag = false
            }

            i += 1
        }
    }
    private func initCheckedButton(){
        checkedButton = UIButton(type: .custom)
        checkedButton!.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        checkedButton!.setTitleColor(UIColor.red, for: .normal)
        checkedButton!.setTitle("确认删除", for: .normal)
        checkedButton!.addTarget(self, action: #selector(checkedForDelete), for: .touchUpInside)
        view.addSubview(checkedButton!)
        checkedButton!.snp.makeConstraints{(make) in
//            make.width.equalTo(50)
//            make.height.equalTo(50)
            make.bottom.equalTo(-30)
            make.centerX.equalToSuperview()
            
        }
        checkedButton!.isHidden = true
    }
    private func initDeleteButton(){
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("🗑", for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(deleted), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints{(make) in
            make.bottom.equalTo(-30)
            make.leading.equalTo(30)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DisplayVC
        let recognizer = sender as! UITapGestureRecognizer
        let cell = recognizer.view as! CellForImage
        let indexPath = photoCollection.indexPath(for: cell)
        destination.theNumberOfPicture = indexPath!.item
    }

    @objc private func goBack(){
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
    private func addReturnButton(){
        let button = UIButton()
        button.titleLabel!.font = UIFont.systemFont(ofSize: 30)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("⤸", for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(goBack), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints{(make) in
            make.bottom.equalTo(-30)
            make.trailing.equalTo(-30)
        }
    }
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @objc private func touchImage(_ recognizer:UITapGestureRecognizer){
        if !shake{
            performSegue(withIdentifier: "showImage", sender: recognizer)
        }else{
            
            let cell = recognizer.view as! CellForImage
            if !cell.isPicked{
                cell.imageShow.image = UIImage(named: "pick")
                cell.isPicked = true
            }else{
                cell.isPicked = false
                let indexPath = photoCollection.indexPath(for: cell)
                let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(photoModel.shared.pickedTwice!.AlbumName!+String(indexPath!.item))
                let data = try! Data(contentsOf: imageUrl)
                let image = UIImage(data: data)
                cell.imageShow.image = image?.crop(ratio: 1)
            }
            
        }
    }
    
}
extension PhotoViewController{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoModel.shared.pickedTwice!.theTotalNumberofPhotoInthisAlbum!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CellForImage
        //var i = indexPath.item
        
        let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(photoModel.shared.pickedTwice!.AlbumName!+String(indexPath.item))
        let data = try! Data(contentsOf: imageUrl)
        let image = UIImage(data: data)
        cell.imageShow.image = image?.crop(ratio: 1)
        
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(touchImage))
        cell.addGestureRecognizer(recognizer)
        
        
        if !shake{
            return cell
        }else{
            cell.transform = CGAffineTransform.identity.rotated(by: -0.05)
           
           UIView.animateKeyframes(withDuration: 0.25, delay: 0, options:[.repeat,.allowUserInteraction], animations: {
            cell.transform = CGAffineTransform.identity.rotated(by: CGFloat.randomCGFloatNumber(lower: 0, upper: 0.05))
           }, completion: nil)
            return cell
        }
    }
    
    
    
    
    
    func setCollectionviewLayout(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //设置滚动方向
        layout.itemSize = CGSize(width: screenWidth/5, height: screenWidth/5)//设置cell的大小
        layout.sectionInset = UIEdgeInsets(top: 20, left:10, bottom: 0, right: 10)//设置分组的间距
        layout.minimumLineSpacing = screenWidth/50//设置最小行间距
        layout.minimumInteritemSpacing = 0///设置小列间距
        
        photoCollection.collectionViewLayout = layout
    }
    
}



public extension CGFloat {
    static func randomCGFloatNumber(lower: CGFloat = 0,upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max)) * (upper - lower) + lower
    }
}



extension UIImage {
    
    //将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
