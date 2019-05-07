
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
    var scale:CGFloat?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let cameraController = CameraController()
    var backView:UIImageView?
    var newZoonFactor:CGFloat = 1
    
    @objc private func scaled(_ sender:UIPinchGestureRecognizer){
        switch sender.state{
        case .changed,.began:
                    newZoonFactor = max(newZoonFactor*sender.scale,1)
                    sender.scale = 1
                    do{
                        try cameraController.rearCamera!.lockForConfiguration()
                        print("\(newZoonFactor)")
                       // PreviewView?.transform = CGAffineTransform.identity.scaledBy(x: newZoonFactor, y: newZoonFactor)
                        cameraController.rearCamera?.ramp(toVideoZoomFactor: newZoonFactor, withRate: 1000000)
                        cameraController.rearCamera?.unlockForConfiguration()
                    }catch{
                        print(error)
                    }
        default:break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //mark
        //let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaled))
        
        
        //self.backView?.addGestureRecognizer(recognizer)
        
        
        
        
        initView()
        configureCameraController()
        initBackView()
        
        
        // Do any additional setup after loading the view.
    }
    
    var PreviewView: UIView?
    var captureButton:UIButton?
    
    private func initBackView(){
        backView = UIImageView()
        backView!.isHidden = true
        view.addSubview(backView!)
        backView?.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    
    
    @objc private func returntoLastView(){
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
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
        func initReturnButton(){
            let button = UIButton()
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("⤸", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            button.addTarget(self, action: #selector(returntoLastView), for: .touchUpInside)
            view.addSubview(button)
            button.snp.remakeConstraints{(make) in
                make.top.equalTo(screenHeight*7/8)
                make.trailing.equalTo(-30)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
        }
        
        PreviewView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(PreviewView!)
        initPhotoButton()
        initReturnButton()
    }
    
    @objc private func takePhoto(_ sender: UIButton){
        backView?.isHidden = false
        cameraController.captureImage{(image) in
            guard let image = image else{
                fatalError()
            }
            
            
            
           self.backView?.image = image
//            //存储到内置的相片资料库
//            try? PHPhotoLibrary.shared().performChangesAndWait {
//                PHAssetChangeRequest.creationRequestForAsset(from: image)
//            }
            let imageData = image.jpegData(compressionQuality: 1)
            self.SaveImage(imageData: imageData!)
            UIView.transition(with: self.backView!, duration: 0.2, options: .transitionFlipFromTop, animations: {
                self.backView!.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }, completion: {(_) in
                UIView.transition(with: self.backView!, duration: 0.4, options: .transitionFlipFromTop, animations: {
                    self.backView!.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                }, completion: {(_) in
                    self.backView!.isHidden = true
                })
            })
            
        }
    }
    private func SaveImage(imageData:Data){
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(photoModel.shared.picked!.AlbumName!+String(photoModel.shared.picked!.theTotalNumberofPhotoInthisAlbum!))
        photoModel.shared.picked!.theTotalNumberofPhotoInthisAlbum! += 1
        photoModel.shared.pickedTwice?.theTotalNumberofPhotoInthisAlbum! += 1
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
            let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.scaled))
            self.PreviewView?.addGestureRecognizer(recognizer)
            try? self.cameraController.displayPreview(on:self.PreviewView!)
            
            
        }
        
    }
}

