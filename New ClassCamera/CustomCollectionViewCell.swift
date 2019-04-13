//
//  CustomCollectionViewCell.swift
//  ClassCamera
//
//  Created by 无敌帅的yyyyy on 2019/4/3.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var NameOfAlbum: UILabel!{
        didSet{
            NameOfAlbum.textAlignment = .center
        }
    }
    
    @IBOutlet weak var photoImage: UIImageView!
    
    
    
    
}
