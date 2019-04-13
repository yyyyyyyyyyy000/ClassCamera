
//
//  MainPhotoVC.swift
//  
//
//  Created by 无敌帅的yyyyy on 2019/4/3.
//

import UIKit
import SnapKit
import Photos
class MainPhotoVC: UIViewController {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let cameraController = CameraController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        configureCameraController()
        // Do any additional setup after loading the view.
    }
    
    var PreviewView: UIView?
    var captureButton:UIButton?
    
    
    
    private func initView(){
        func initPhotoButton(){
            captureButton = UIButton()
            captureButton?.backgroundColor = .clear
            captureButton?.setTitle("⚪️", for: .normal)
            captureButton?.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            captureButton?.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
            view.addSubview(captureButton!)
            captureButton!.snp.makeConstraints{(make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(screenHeight*7/8)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
        }
        
        PreviewView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(PreviewView!)
        initPhotoButton()
    }
    
    @objc private func takePhoto(_ sender: UIButton){
        cameraController.captureImage{(image) in
            guard let image = image else{
                fatalError()
            }
            
//            //存储到内置的相片资料库
//            try? PHPhotoLibrary.shared().performChangesAndWait {
//                PHAssetChangeRequest.creationRequestForAsset(from: image)
//            }
            let imageData = image.jpegData(compressionQuality: 1)
            self.SaveImage(imageData: imageData!)
            
            
        }
    }
    private func SaveImage(imageData:Data){
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(photoModel.shared.thePickedAlbum!)
        try! imageData.write(to: path)
        print("save successfully")
    }

}





extension MainPhotoVC{
    func configureCameraController(){
        cameraController.prepare{(error) in
            if let error = error{
                print(error)
            }
            try? self.cameraController.displayPreview(on:self.PreviewView!)
            
        }
        
    }
}

