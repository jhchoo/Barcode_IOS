//
//  ScanViewController.swift
//  BarcodeSample4
//
//  Created by jae hwan choo on 2022/05/17.
//

import UIKit
import Vision
import AVFoundation
import SafariServices

class ScanViewController: UIViewController {
    // MARK: - Private Variables
    private var captureSession = AVCaptureSession()
//    private var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: BarcodeScanDelegate?
    
    
    // TODO: Make VNDetectBarcodesRequest variable
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
      guard error == nil else {
        self.showAlert(withTitle: "Barcode error", message: error?.localizedDescription ?? "error")
        return
      }
      self.processClassification(request)
    }
    
    // MARK: - Vision
    func processClassification(_ request: VNRequest) {
      // TODO: Main logic
      guard let barcodes = request.results else { return }
      DispatchQueue.main.async { [self] in
        if captureSession.isRunning {
          view.layer.sublayers?.removeSubrange(1...)

          for barcode in barcodes {
            guard
              // TODO: Check for QR Code symbology and confidence score
              let potentialQRCode = barcode as? VNBarcodeObservation,
//              potentialQRCode.symbology == .code128,
              potentialQRCode.confidence > 0.9 // 유사성
              else { return }

            observationHandler(payload: potentialQRCode.payloadStringValue)
          }
        }
      }
    }
    
    // MARK: - Handler
    func observationHandler(payload: String?) {
      print("payload: \(payload ?? "")")
        self.delegate?.scanner(didCaptureCode: payload ?? "")
        // self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermissions()
        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.layer.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
        
        setupCameraLiveView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      // TODO: Stop Session
      captureSession.stopRunning()
    }
    
    private func setupCameraLiveView() {
      // TODO: Setup captureSession
      captureSession.sessionPreset = .hd1280x720

      // TODO: Add input
      let videoDevice = AVCaptureDevice
        .default(.builtInWideAngleCamera, for: .video, position: .back)

      guard
        let device = videoDevice,
        let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
        captureSession.canAddInput(videoDeviceInput) else {
          showAlert(
            withTitle: "Cannot Find Camera",
            message: "There seems to be a problem with the camera on your device.")
          return
        }

      captureSession.addInput(videoDeviceInput)

      // TODO: Add output
      let captureOutput = AVCaptureVideoDataOutput()
      // TODO: Set video sample rate
      captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
      captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
      captureSession.addOutput(captureOutput)

      configurePreviewLayer()

      // TODO: Run session
      captureSession.startRunning()
    }
    
    private func configurePreviewLayer() {
      let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      cameraPreviewLayer.videoGravity = .resizeAspectFill
      cameraPreviewLayer.connection?.videoOrientation = .portrait
      cameraPreviewLayer.frame = view.frame
      view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
}

// MARK: - AVCaptureDelegation
extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // TODO: Live Vision
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    let imageRequestHandler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      orientation: .right)

    do {
      try imageRequestHandler.perform([detectBarcodeRequest])
    } catch {
      print(error)
    }
  }
}

// 카메라 펴미션 획득
extension ScanViewController {
    // MARK: - Camera
    private func checkPermissions() {
      // TODO: Checking permissions
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { [self] granted in
          if !granted {
            self.showPermissionsAlert()
          }
        }
      case .denied, .restricted:
        showPermissionsAlert()
      default:
        return
      }
    }
    
    private func showPermissionsAlert() {
        showAlert (
            withTitle: "Camera Permissions",
            message: "Please open Settings and grant permission for this app to use your camera.")
    }
    
    
    private func showAlert(withTitle title: String, message: String) {
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
      }
    }
}

/// Delegate to handle the captured code.
public protocol BarcodeScanDelegate: AnyObject {
  func scanner( didCaptureCode code: String)
}
