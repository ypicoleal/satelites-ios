//
//  ViewController.swift
//  Satelites
//
//  Created by Yamid Pico Leal on 22/05/17.
//  Copyright © 2017 Yamid Pico leal. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var mapContainer: UIView!
    
    var mapsView: GMSMapView!
    
    @IBOutlet weak var reportButton: UIBarButtonItem!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var locationManager = CLLocationManager()
    var didFinfMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.darkGray
        
        let camera = GMSCameraPosition.camera(withLatitude: 10.400196, longitude: -75.502797, zoom: 12.0)
        mapsView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapContainer.addSubview(mapsView)
        
        mapsView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        view.addSubview(activityIndicator)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addReport(_ sender: UIBarButtonItem) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Saving Image here
    @IBAction func save(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(imageTake.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func send(_ image: UIImage) {
        
        print("Sending image")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        reportButton.isEnabled = false
        
        let imageData = UIImagePNGRepresentation(image)
        
        let request = NSMutableURLRequest(url: NSURL(string:"http://104.236.33.228:8080/basureros/reportar/")! as URL)
        
        request.httpMethod = "POST"
        
        let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        // Latitud
        body.append(NSString(format: "\r\n--%@\r\n",boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"latitude\"\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append((mapsView.myLocation?.coordinate.latitude.description.data(using: String.Encoding.utf8, allowLossyConversion: true)!)!)
        
        // Longitud
        body.append(NSString(format: "\r\n--%@\r\n",boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"longitude\"\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append((mapsView.myLocation?.coordinate.longitude.description.data(using: String.Encoding.utf8, allowLossyConversion: true)!)!)
        
        // Image
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"profile_img\"; filename=\"img.jpg\"\\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(imageData!)
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        
        request.httpBody = body as Data
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                                                                     completionHandler: {
                                                                        (data, response, error) -> Void in
                                                                        if let data = data {
                                                                            
                                                                            // You can print out response object
                                                                            print("******* response = \(String(describing: response))")
                                                                            
                                                                            print(data.count)
                                                                            // you can use data here
                                                                            
                                                                            // Print out reponse body
                                                                            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                                                            print("****** response data = \(responseString!)")
                                                                            
                                                                            
                                                                            
                                                                            DispatchQueue.main.async(execute: {
                                                                                self.activityIndicator.stopAnimating()
                                                                                self.reportButton.isEnabled = true
                                                                                let alert = UIAlertController(title: "Reporte de basurero", message: "Reporte enviado con exito", preferredStyle: UIAlertControllerStyle.alert)
                                                                                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.default, handler: nil))
                                                                                self.present(alert, animated: true, completion: nil)
                                                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                                            });
                                                                            
                                                                        } else if let error = error {
                                                                            print(error.localizedDescription)
                                                                        }
        })
        task.resume()

    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        send(resizeImage(image: image!, newWidth: 500)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapsView.isMyLocationEnabled = true
            print("Location enabled")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFinfMyLocation {
            let myLocation: CLLocation = change![.newKey] as! CLLocation
            mapsView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 16.0)
            didFinfMyLocation = true
        }
    }
}

