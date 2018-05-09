//
//  GMCameraController.swift
//  Katrori.shop
//
//  Created by imac on 3/5/18.
//  Copyright © 2018 Katrori. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class GMCameraController: UIViewController, UINavigationControllerDelegate {
    
    var previewLayerCustom:CALayer!
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var image: UIImage!
    var clickedToCapture = false
    var arrayOfImages = [UIImage]()
    let imagePicker = UIImagePickerController()
    
    var indexPathOfImage = IndexPath()
    
    //MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captureButtonOutlet: UIButton!
    @IBOutlet weak var imagePickerGalery: UIButton!
    @IBOutlet weak var closeButon: UIButton!
    @IBOutlet weak var newPostButton: UIButton!
    
    //MARK: ViewDidLoad, ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isImageSelected = false
        imagePickerGalery.tintColor = kCOLOR_PRIMARY_APP
        prepareCamera()
        self.navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayerCustom?.frame = cameraView.layer.bounds
    }
    
    //MARK: Helper Methods
    
    var isImageSelected: Bool? {
        didSet {
            
            captureButtonOutlet.setImage(isImageSelected! ? UIImage(named:"icon_delete") : nil, for: .normal)
            captureButtonOutlet.backgroundColor = isImageSelected! ? kCOLOR_RED : kCOLOR_PRIMARY_APP
            
            imagePickerGalery.isHidden = isImageSelected! ? true : false
            imageView.isHidden = isImageSelected! ? false : true
            cameraView.isHidden = isImageSelected! ? true : false
            newPostButton.isHidden = isImageSelected! ? true : false
        }
    }
    
    @objc func deleteImage()
    {
        print("delete")
        
        self.arrayOfImages.remove(at: indexPathOfImage.item)
        self.collectionView.deleteItems(at: [indexPathOfImage])
        isImageSelected = false
    }
    
    @objc func captureImage()
        
    {
        clickedToCapture = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerOriginalImage] as! UIImage

        self.arrayOfImages.append(image)
        self.collectionView.reloadData()
        self.imagePicker.dismiss(animated: false, completion: {})

    }

    
    //MARK: ActionButtons
    
    @IBAction func captureImageAction(_ sender: Any) {
        
        if isImageSelected! {
            deleteImage()
        } else {
            captureImage()
        }

    }
    
    @IBAction func openGalery(_ sender: Any) {
        
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
      
    }
    
    @IBAction func closeButonAction(_ sender: Any) {
        
       self.dismiss(animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GMNewPostControllerSegueIdentifier"
        {
            let svc = segue.destination as? UINavigationController
            
            let vc: GMNewPostController = svc?.topViewController as! GMNewPostController
            
            vc.number = 4343434
 
        }
    }
    
    @IBAction func newPostButtonAction(_ sender: Any) {
        
       
    }
}

extension GMCameraController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayOfImages.count + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == arrayOfImages.count {
            
            isImageSelected = false
        }
            
        else {
            
            isImageSelected = true
            indexPathOfImage = indexPath
            self.imageView.image = arrayOfImages[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == arrayOfImages.count {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GMCameraEmptyCell", for: indexPath) as! GMCameraEmptyCell
            
        return cell
            
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GMCameraCell", for: indexPath) as! GMCameraCell
            
        cell.imageView.image = arrayOfImages[indexPath.row]
        
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 10
        
        return cell
            
        }
    }
 }

extension GMCameraController: AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate  {
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices as? [AVCaptureDevice]
        {
            captureDevice = availableDevices.first
            beginSession()
            
            self.cameraView.isHidden = false
            self.imageView.isHidden = true
            viewDidLayoutSubviews()
        }
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
            
        }catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) as? AVCaptureVideoPreviewLayer{
            
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            self.previewLayerCustom = previewLayer
            self.cameraView.layer.addSublayer(self.previewLayerCustom)
            self.previewLayerCustom.frame = self.cameraView.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if clickedToCapture == true {
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                DispatchQueue.main.async {
                    
                    self.arrayOfImages.append(image)
                    self.collectionView.reloadData()
                }
                
                self.clickedToCapture = false
            }
        }
    }
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
}

extension UIImage {
    // create a UIImage with solid color
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

