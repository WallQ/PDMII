//
//  QRCodeViewController.swift
//  APP
//
//  Created by André Pinto on 30/01/2022.
//

import UIKit
import CoreImage

class QRCodeViewController: UIViewController {

    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var lblTexto: UILabel!
    
    var newsID: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTexto.text = String(newsID)
        
        if let QRCodeImage = createQRFromString(str: String(newsID)){
            let img = UIImage(ciImage: QRCodeImage, scale: 0, orientation: .down)
            self.imgQRCode.image = img
        }
        
    }
    
    func createQRFromString(str: String) -> CIImage?{
        let stringData = str.data(using: .utf8)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(stringData, forKey: "inputMessage")
        
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        return filter?.outputImage
    }
    
    func generateQRCodeScaled(from string: String) -> UIImage{
        let data = string.data(using: String.Encoding.ascii)
        
        if let QRFilter = CIFilter(name: "CIQRCodeGenerator"){
            QRFilter.setValue(data, forKey: "inputMessage")
            
            guard let QRImage = QRFilter.outputImage else {return UIImage()}
            
            let transformScale = CGAffineTransform(scaleX: 5.0, y: 5.0)
            let scaledQRImage = QRImage.transformed(by: transformScale)
            return UIImage(ciImage: scaledQRImage)
        }
        return UIImage()
    }
    

}
