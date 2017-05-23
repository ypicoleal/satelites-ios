//
//  ViewController.swift
//  Satelites
//
//  Created by Exile Soluciones Tecnológicas on 22/05/17.
//  Copyright © 2017 Yamid Pico leal. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var mapsView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var didFinfMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 10.400196, longitude: -75.502797, zoom: 12.0)
        mapsView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapsView.isMyLocationEnabled = true
        view = mapsView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 10.400196, longitude: -75.502797)
        marker.title = "Ustes esta aqui"
        marker.snippet = "Australia"
        marker.map = mapsView
        
        mapsView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
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
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        print(image?.accessibilityIdentifier ?? "tales pascuales")
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
            mapsView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            didFinfMyLocation = true
        }
    }
}

