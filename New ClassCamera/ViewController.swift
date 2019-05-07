//
//  ViewController.swift
//  ClassCamera
//
//  Created by 无敌帅的yyyyy on 2019/4/3.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit
import SnapKit



class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let photoButton = UIButton()
    var choosedIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        initView()
        
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    @objc private func TakePhoto(){
        performSegue(withIdentifier: "toTake", sender: self)
    }
    
    
    @objc private func IntoAlbum(_ sender:UITapGestureRecognizer){
        let cell = sender.view as! CustomCollectionViewCell
        let albumName = cell.NameOfAlbum.text
        photoModel.shared.pickedTwice = pickedAlbum()
        photoModel.shared.pickedTwice!.AlbumName = albumName
        for album in photoModel.shared.pickedOne!{
            if album.AlbumName == albumName{
                photoModel.shared.pickedTwice!.theTotalNumberofPhotoInthisAlbum = album.theTotalNumberofPhotoInthisAlbum!
            }
        }
        performSegue(withIdentifier: "toAlbum", sender: CustomCollectionViewCell.self)
    }
    
    
    private func createNewAlbum(with name:String){
        photoModel.shared.theNameofAlbums!.append(name)
        photoModel.shared.theNumberOfAlbum! += 1
        photoModel.shared.Albumdic![photoModel.shared.theNumberOfAlbum!] = name
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("name")
        photoModel.shared.theUrlofAlbums![photoModel.shared.theNumberOfAlbum!] = url
        
        collectionView.reloadData()
    }
    
    
    
    @objc private func addNewAlbum(){
        let alertVC = UIAlertController(title:"", message: "创建新相册", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(
            title: "取消",style: .cancel, handler:{_ in
                self.presentingViewController?.dismiss(animated: true, completion: nil)
        }))
        alertVC.addAction(UIAlertAction(title: "确定", style:.default, handler: {_ in
            let text = alertVC.textFields?.first?.text
            self.createNewAlbum(with:text!)
            
            
        }))
        alertVC.addTextField(configurationHandler: {textField in
            textField.placeholder = "请输入相册名"
            textField.isSecureTextEntry = false
            
        })
        present(alertVC,animated: true)
        
        
        
    }
    
    
    
    
    
    
}




extension ViewController{
    @objc private func pickAlbum(_ recognizer: UILongPressGestureRecognizer){
        switch recognizer.state{
        case .ended:
            let cell = recognizer.view as! CustomCollectionViewCell
            let path = collectionView.indexPath(for: cell)
            photoModel.shared.pickedItem = path!.item
            //cell.photoImage.image = UIImage(named: "pick")
            let nameofAlbum = cell.NameOfAlbum.text!
            var flag = false
            for album in photoModel.shared.pickedOne!{
                if album.AlbumName == nameofAlbum{
                    flag = true
                    photoModel.shared.picked = album
                }
            }
            if !flag{
                let newAlbum = pickedAlbum()
                newAlbum.AlbumName = nameofAlbum
                newAlbum.theTotalNumberofPhotoInthisAlbum = 0
                photoModel.shared.pickedOne?.append(newAlbum)
                photoModel.shared.picked = newAlbum
            }
            collectionView.reloadData()
        default:break
        }
        
        
        
        
        
        
    }
//    @objc private func move(_ recognizer: UIPanGestureRecognizer){
//        let point = recognizer.translation(in: collectionView)
//        switch recognizer.state{
//        case .changed:
//            photoButton.snp.remakeConstraints{(make) in
//                make.height.equalTo(100)
//                make.width.equalTo(100)
//                make.top.equalTo(lastY!+point.y)
//                make.left.equalTo(lastX!+point.x)
//            }
//        case .ended:
//            lastY = lastY!+point.y
//            lastX = lastX!+point.x
//            let indexPath = collectionView.indexPathForItem(at: CGPoint(x: lastX!,y: lastY!))
//            let cell = collectionView.cellForItem(at: indexPath!) as! CustomCollectionViewCell
//            //            choosedIndexPath = indexPath!
//            //            collectionView.reloadItems(at: [indexPath!])
//
//            let nameofAlbum = cell.NameOfAlbum.text!
//            var flag = false
//            for album in photoModel.shared.pickedOne!{
//                if album.AlbumName == nameofAlbum{
//                    flag = true
//                    photoModel.shared.picked = album
//                }
//            }
//            //第一次使用
//            if !flag{
//                let newAlbum = pickedAlbum()
//                newAlbum.AlbumName = nameofAlbum
//                newAlbum.theTotalNumberofPhotoInthisAlbum = 0
//                photoModel.shared.pickedOne!.append(newAlbum)
//                photoModel.shared.picked = newAlbum
//            }
//            // photoModel.shared.thePickedAlbum = nameofAlbum
//            let path = collectionView.indexPath(for: cell)
//            photoModel.shared.pickedItem = path!.item
//            // collectionView.reloadItems(at: [path!])
//            collectionView.reloadData()
//        default:break
//        }
//
//    }
    
    
    private func initView(){
        func initPhotoButton(){
            photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            photoButton.setTitle("📸", for: .normal)
            photoButton.backgroundColor = .clear
            photoButton.addTarget(self, action: #selector(TakePhoto), for: UIControl.Event.touchUpInside)
            view.addSubview(photoButton)
            photoButton.snp.makeConstraints{(make) in
                make.centerX.equalTo(screenWidth/2)
             
                make.width.equalTo(100)
                make.height.equalTo(100)
                make.top.equalTo(screenHeight*0.85)
              
            }
//            let recognizer = UIPanGestureRecognizer(target: self, action: #selector(move))
//            photoButton.addGestureRecognizer(recognizer)
            
        }
        
        
        func setCollectionviewLayout(){
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical //设置滚动方向
            layout.itemSize = CGSize(width: screenWidth*3/8, height: screenWidth*3/8)//设置cell的大小
            layout.sectionInset = UIEdgeInsets(top: 20, left: 27, bottom: 0, right: 27)//设置分组的间距
            layout.minimumLineSpacing = 20//设置最小行间距
            layout.minimumInteritemSpacing = 15//设置小列间距
            collectionView.collectionViewLayout = layout
        }
        
        func initAddButton(){
            let Addbutton = UIButton()
            Addbutton.setTitle("✚", for: .normal)
           // Addbutton.setImage(UIImage(named: "add"), for: .normal)
            Addbutton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            Addbutton.setTitleColor(UIColor.black, for: .normal)
            Addbutton.sizeToFit()
            Addbutton.addTarget(self, action: #selector(addNewAlbum), for: UIControl.Event.touchUpInside)
            view.addSubview(Addbutton)
            Addbutton.snp.makeConstraints{(make) in
                make.width.equalTo(100)
                make.height.equalTo(100)
                make.top.equalTo(screenHeight*0.85)
                make.right.equalTo(0)
            }
        }
        
        
        initAddButton()
        initPhotoButton()
        setCollectionviewLayout()
    }
}







extension ViewController{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photoModel.shared.theNumberOfAlbum!+1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "custom", for: indexPath) as! CustomCollectionViewCell
        
        
        cell.NameOfAlbum.text = photoModel.shared.Albumdic![indexPath.item]
        let Intorecognizer = UITapGestureRecognizer(target: self, action: #selector(IntoAlbum))
        cell.addGestureRecognizer(Intorecognizer)
        let pickRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pickAlbum))
        pickRecognizer.minimumPressDuration = 0.3
        
        cell.addGestureRecognizer(pickRecognizer)
        
        
        
        if photoModel.shared.pickedItem == nil{
            cell.photoImage.image = UIImage(named: "涂鸦")?.crop(ratio: 1)
        }else{
            if indexPath.item == photoModel.shared.pickedItem{
                
                cell.photoImage.image = UIImage(named: "pick")?.crop(ratio: 1)
            }else{
                let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(photoModel.shared.Albumdic![indexPath.item]!+String(0))
                let imageData = try? Data(contentsOf: imageUrl)
                if imageData != nil{
                    cell.photoImage.image = UIImage(data: imageData!)?.crop(ratio: 1)
                }else{
                    cell.photoImage.image = UIImage(named: "涂鸦")
                }
            }
        }
        
        return cell
    }
    
}
