//
//  ViewController.swift
//  PhotoFrameworkUtility
//
//  Created by Sachin Patil on 3/7/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonHandlerGallery(_ sender: Any) {

        
        let image = UIImage.init(named: "558465")

    }
    
 
    @IBAction func buttonHandlerCamera(_ sender: Any) {
        
      
    }
    
    
    @IBAction func buttonHandlerReset(_ sender: Any) {
    }
    
    private func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
}

