//
//  GalleryManager.swift
//  PhotoFrameworkUtility
//
//  Created by Sachin on 3/7/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import Photos


/**
 Description : - Class responsible for saving and retrieving images based on their gallary identifier.
 
 - Requires: PhotoFramework in iOS
 
 - Author: Sachin Patil
 */

class GalleryManager: NSObject {

    /**
     Description : - This method creates album for application.
     - Parameter  WithTitle : Album name in gallary.
     - Parameter  withCompletionHandler : Completion handler.
     
     ### Important Notes ###
       - Reason to keep it as static method because to use this utility we don't neet to create instance of class.
     
     - Requires: PHPhotoLibrary class
     
     - Author: Sachin Patil
    */
    public static func createAlbum(WithTitle albumTitle:String, withCompletionHandler completionHandler: @escaping (_ albumID:String?,_ error: Error?) -> Void){
        
        UserDefaults.standard.set(true, forKey: "GallaryCreationInProgress")
        var collection : PHAssetCollection?

        var collectionPlaceHolder : PHObjectPlaceholder?
        
        let fetchOptions : PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate  = NSPredicate.init(format: "title = %@", albumTitle)
        collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
        
        if (collection == nil) {
            
             PHPhotoLibrary.shared().performChanges({
                
                let newAlbum = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                collectionPlaceHolder = newAlbum.placeholderForCreatedAssetCollection
                
                
            }, completionHandler: { (success, error) in
                
                UserDefaults.standard.removeObject(forKey: "GallaryCreationInProgress")
                if success{
                    
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [(collectionPlaceHolder?.localIdentifier)!], options: nil)
                    
                    UserDefaults.standard.set(collectionPlaceHolder?.localIdentifier, forKey: "ApplicationGallaryLocalIndentifier")
                    collection = collectionFetchResult.firstObject
                    completionHandler(collectionPlaceHolder?.localIdentifier,nil)
                }
                else{
                    
                    completionHandler(nil,error)
                }
            })
        }
        else{
            let localIndentifier = collection!.localIdentifier
            UserDefaults.standard.set(localIndentifier, forKey: "ApplicationGallaryLocalIndentifier")
            completionHandler(localIndentifier,nil);
        }
    }
    
    /**
     Description : - This method used to delete the album created previously.
     - Parameter  WithTitle : album name which needs to delete.
     - Parameter  withCompletionHandler : Completion handler.
     
     ### Important Notes ###
     - Reason to keep it as static method because to use this utility we don't neet to create instance of class.

     - Requires: PHFetchOptions class knowledge
     
     - Author: Sachin Patil
     
     */
    public static func deleteApplicationCreatedAlbum(WithTitle albumTitle:String, withCompletionHandler completionHandler: @escaping (_ albumID:String?,_ error: Error?) -> Void){
        
        var applicationAlbum: PHAssetCollection?
        
        let albumFetchOptions = PHFetchOptions.init()
        albumFetchOptions.predicate  = NSPredicate.init(format: "title", albumTitle)
        applicationAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: albumFetchOptions).firstObject
        
        if applicationAlbum != nil{
            let albumImage = PHAsset.fetchAssets(in: applicationAlbum!, options: nil)
            
            PHPhotoLibrary.shared().performChanges({
                
                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest.init(for: applicationAlbum!)
                assetCollectionChangeRequest?.removeAssets(albumImage)
                
            }, completionHandler: { (success, error) in
                
            })
        }
    }
    
    /**
     Description : - This method used save photo in photogallary.
     - Parameter  forImage : UIImage object needs to save.
     - Parameter  withCompletionHandler : Completion handler.
     
     ### Important Notes ###
     - Reason to keep it as static method because to use this utility we don't neet to create instance of class.
     
     - Requires: PHFetchOptions class knowledge
     
     - Author: Sachin Patil
     
     */
    public static func saveImageToAlbum(forImage image : UIImage, withCompletionHandler completionHandler: @escaping (_ assetID:String?,_ error: Error?) -> Void){
        
        GalleryManager.createAlbum(WithTitle: "24/7 Communicator") { (albumID, error) in
            
            let albumLocalIndentifier = UserDefaults.standard.object(forKey: "ApplicationGallaryLocalIndentifier")
            
            let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIndentifier as! String], options: nil)
            
            let applicationAlbum : PHAssetCollection? = fetchResult.firstObject
            var  objectPlaceHolder : PHObjectPlaceholder?
            
            PHPhotoLibrary.shared().performChanges({
            
                let request = PHAssetCreationRequest.creationRequestForAsset(from: image)
                
                 objectPlaceHolder = request.placeholderForCreatedAsset
                
                  let collectionChangeReqeust = PHAssetCollectionChangeRequest.init(for: applicationAlbum!)
                let enumeration: NSArray = [objectPlaceHolder!]
                collectionChangeReqeust?.addAssets(enumeration)
                
            }, completionHandler: { (sucess, error) in
                
                if sucess {
                    
                    completionHandler(objectPlaceHolder!.localIdentifier, nil)
                }
                else{
                    
                    completionHandler(nil,error)
                }
                
            })
        }
    }
    
    /**
     Description : - This method used get image from gallary based on gallary identifier we get.
     - Parameter  forLocalIndentifier : Local identifier of image save in gallery.
     - Parameter  withCompletionHandler : Completion handler.
     
     ### Important Notes ###
     - Reason to keep it as static method because to use this utility we don't neet to create instance of class.
     
     - Requires: PHFetchOptions class knowledge
     
     - Author: Sachin Patil
     
     */
    public static func getImageFromAlbum(forLocalIndentifier localIdentifier : String, withCompletionHandler completionHandler: @escaping (UIImage?) -> Void){
        
         let albumLocalIndentifier = UserDefaults.standard.object(forKey: "ApplicationGallaryLocalIndentifier")
         let fetchResultCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIndentifier as! String], options: nil)
        let applicationAlbum : PHAssetCollection? = fetchResultCollection.firstObject
        
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(in: applicationAlbum!, options: fetchOptions)
        let asset : PHAsset? = fetchResult.lastObject
        if asset != nil {
            
            PHImageManager.default().requestImageData(for: asset!, options: nil, resultHandler: { (imageData, strResult, orientaition, hashValue) in
                
                if let resultedData = imageData{
                    
                    let resultImage = UIImage.init(data: resultedData)
                    completionHandler(resultImage)
                }
                else{
                    completionHandler(nil)
                }
            })
        }
        else{
            completionHandler(nil)
        }
    }
    
    /**
     Description : - This method used check that image with local identifier is available or not.
     
     - Parameter  withIdentfier : Local identifier of image to check.
     - Parameter  withCompletionHandler : Completion handler.
     
     ### Important Notes ###
     - Reason to keep it as static method because to use this utility we don't neet to create instance of class.
     
     - Requires: PHFetchOptions class knowledge
     
     - Author: Sachin Patil
     
     */
    public static func checkAssetAvailable(withIdentfier localIdentifier : String) -> Bool{
        
        let photoFetchOptions = PHFetchOptions()
        photoFetchOptions.predicate = NSPredicate.init(format: "localIdentifier = %@", localIdentifier)
        
        let resultedImage = PHAsset.fetchAssets(with: photoFetchOptions)
        
        let asset = resultedImage.firstObject
        if (asset != nil) {
            return true
        }
        else{
           return false
        }
    }
}
