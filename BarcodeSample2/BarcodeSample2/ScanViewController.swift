//
//  ViewController.swift
//  ATBarcodeScanner
//
//  Created by Dejan on 21/01/2019.
//  Copyright © 2019 agostini.tech. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanDataDelegate {
    
    func scanData(data: String)
    
}

class ScanViewController: UIViewController {
    var delegate : ScanDataDelegate?

    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "Capture Session Queue")
    
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        sessionQueue.sync {
            self.captureSession.beginConfiguration()
            
            let output = AVCaptureMetadataOutput()
            
            if let device = AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: device),
                self.captureSession.canAddInput(input) && self.captureSession.canAddOutput(output) {
                self.captureSession.addInput(input)
                self.captureSession.addOutput(output)
                
                output.metadataObjectTypes = [
                    .aztec,
                    .code39,
                    .code39Mod43,
                    .code93,
                    .code39Mod43,
                    .code128,
                    .dataMatrix,
                    .ean8,
                    .ean13,
                    .interleaved2of5,
                    .itf14,
                    .interleaved2of5,
                    .pdf417,
                    .qr,
                    .upce
                ]
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
            
            self.captureSession.commitConfiguration()
            
            DispatchQueue.main.async {
                self.setupPreviewLayer(session: self.captureSession)
                self.setupBoundingBox()
            }
            
            self.captureSession.startRunning()
        }
    }
    
    private func setupPreviewLayer(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = previewContainer.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        previewContainer.layer.addSublayer(previewLayer)
    }
    
    // MARK - Bounding Box
    private var boundingBox = CAShapeLayer()
    private func setupBoundingBox() {
        boundingBox.frame = previewContainer.layer.bounds
        boundingBox.strokeColor = UIColor.red.cgColor
        boundingBox.lineWidth = 4.0
        boundingBox.fillColor = UIColor.clear.cgColor
        
        previewContainer.layer.addSublayer(boundingBox)
    }
    
    fileprivate func updateBoundingBox(_ points: [CGPoint]) {
        guard let firstPoint = points.first else {
            return
        }
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        
        var newPoints = points
        newPoints.removeFirst()
        newPoints.append(firstPoint)
        
        newPoints.forEach { path.addLine(to: $0) }
        
        boundingBox.path = path.cgPath
        boundingBox.isHidden = false
    }
    
    private var resetTimer: Timer?
    fileprivate func hideBoundingBox(after: Double) {
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval() + after,
                                          repeats: false) {
                                            [weak self] (timer) in
                                            self?.resetViews() }
    }
    
    private func resetViews() {
        boundingBox.isHidden = true
        resultsLabel.text = nil
    }
}

@available(iOS 10.0, *)
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            self.resultsLabel.text = object.stringValue
            
            hideBoundingBox(after: 0.25)
            delegate?.scanData(data: object.stringValue!)
            self.navigationController?.popToRootViewController(animated: true)
            self.captureSession.stopRunning()
        }
    }
}
