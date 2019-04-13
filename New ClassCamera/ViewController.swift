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
    
    var pickedItem:Int?
    
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
    
    
    private func createNewAlbum(with name:String){
        photoModel.shared.theNameofAlbums!.append(name)
        photoModel.shared.theNumberOfAlbum! += 1
        photoModel.shared.Albumdic![photoModel.shared.theNumberOfAlbum!] = name
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("name")
        photoModel.shared.theUrlofAlbums![photoModel.shared.theNumberOfAlbum!] = url
        
        collectionView.reloadData()
        
        
    }
    
    
    @objc private func getPickedAlbum(_ sender:UILongPressGestureRecognizer){
        let cell = sender.view as! CustomCollectionViewCell
        if (sender.state == .began){
            let nameofAlbum = cell.NameOfAlbum.text
            print(nameofAlbum!)
            photoModel.shared.thePickedAlbum = nameofAlbum
            let path = collectionView.indexPath(for: cell)
            pickedItem = path!.item
            // collectionView.reloadItems(at: [path!])
            collectionView.reloadData()
        }
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
    private func initView(){
        func initPhotoButton(){
            let photoButton = UIButton()
            photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            photoButton.setTitle("📸", for: .normal)
            photoButton.backgroundColor = .clear
            photoButton.addTarget(self, action: #selector(TakePhoto), for: UIControl.Event.touchUpInside)
            view.addSubview(photoButton)
            photoButton.snp.makeConstraints{(make) in
                make.centerX.equalTo(view)
                make.width.equalTo(100)
                make.height.equalTo(100)
                make.top.equalTo(screenHeight*0.85)
            }
        }
        
        
        func setCollectionviewLayout(){
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical //设置滚动方向
            layout.itemSize = CGSize(width: screenWidth*3/8, height: screenHeight*3/13)//设置cell的大小
            layout.sectionInset = UIEdgeInsets(top: 0, left: screenWidth/10, bottom: screenHeight/8, right: screenWidth/10)//设置分组的间距
            layout.minimumLineSpacing = 20//设置最小行间距
            layout.minimumInteritemSpacing = 10//设置小列间距
            collectionView.collectionViewLayout = layout
        }
        
        func initBackGroundImage(){
            let imaView = UIImageView(image: UIImage(named: "地球"))
            imaView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            imaView.alpha = 0.2
            view.addSubview(imaView)
        }
        
        func initAddButton(){
            let Addbutton = UIButton()
            Addbutton.setTitle("✚", for: .normal)
            Addbutton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            Addbutton.setTitleColor(UIColor.black, for: .normal)
            Addbutton.sizeToFit()
            Addbutton.addTarget(self, action: #selector(addNewAlbum), for: UIControl.Event.touchUpInside)
            view.addSubview(Addbutton)
            Addbutton.snp.makeConstraints{(make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.top.equalTo(30)
                make.right.equalTo(0)
            }
        }
        
        
        initBackGroundImage()
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
        
        if pickedItem == nil{
            cell.photoImage.image = UIImage(named: "涂鸦")
        }else{
            if indexPath.item == pickedItem{
                cell.photoImage.image = UIImage(named: "简约")
            }else{
                cell.photoImage.image = UIImage(named: "涂鸦")
            }
        }
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(getPickedAlbum))
        //  cell.photoImage.addGestureRecognizer(recognizer)
        recognizer.minimumPressDuration = 0.5
        cell.addGestureRecognizer(recognizer)
        
        cell.NameOfAlbum.text = photoModel.shared.Albumdic![indexPath.item]
        return cell
    }
    
}
