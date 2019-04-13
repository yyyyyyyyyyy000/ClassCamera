//
//  photoModel.swift
//  ClassCamera
//
//  Created by 无敌帅的yyyyy on 2019/4/3.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import Foundation
class photoModel:Codable{
    
    var thePickedAlbum:String?
    
    var theNumberOfAlbum:Int?
    
    var Albumdic:[Int:String]?
    
    var theNameofAlbums:[String]?
    
    var theUrlofAlbums:[Int:URL]?
    
    static var shared = photoModel()
    
    var json:Data{
        return try! JSONEncoder().encode(self)
    }
    
    init(){
        //        theNumberOfAlbum = -1
        //        theNameofAlbums = [String]()
        //        theUrlofAlbums = [Int:URL]()
        //        Albumdic = [Int:String]()
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Model")
        if let data = try? Data(contentsOf: path){
            let model = try! JSONDecoder().decode(photoModel.self, from: data)
            theNumberOfAlbum = model.theNumberOfAlbum
            theNameofAlbums = model.theNameofAlbums
            theUrlofAlbums = model.theUrlofAlbums
            Albumdic = model.Albumdic
            thePickedAlbum = model.thePickedAlbum
        }else{
            theNumberOfAlbum = -1
            theNameofAlbums = [String]()
            theUrlofAlbums = [Int:URL]()
            Albumdic = [Int:String]()
            
        }
    }
    
    func saveModel(){
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Model")
        try! json.write(to: url)
        
    }
    
    
    
    
}
