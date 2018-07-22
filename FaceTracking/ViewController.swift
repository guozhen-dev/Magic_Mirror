//
//  ViewController.swift
//  AutoCamera
//
//  Created by Pawel Chmiel on 26.09.2016.
//  Copyright © 2016 Pawel Chmiel. All rights reserved.
//

import UIKit
import AVFoundation

class DetailsView: UIView {

    lazy var detailsLabel: UILabel = {
        let detailsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        detailsLabel.numberOfLines = 0
        detailsLabel.textColor = .white
        detailsLabel.font = UIFont.systemFont(ofSize: 18.0)
        detailsLabel.textAlignment = .left
        return detailsLabel
    }()
    lazy var image222:UIImageView={
        let retu = UIImageView(frame:CGRect(x:0,y:0,width:350,height:200))
        retu.image = UIImage(named:"333.png")
        return retu
    }()
    lazy var lip :UIImageView = {
        let retuiimg = UIImageView(frame: CGRect(x: 0 , y :0 , width:100 , height:100))
        retuiimg.image = UIImage(named:"lip.png")
        retuiimg.contentMode = .scaleToFill
        return retuiimg
    }()
    func uuuaaa(){
        addSubview(image222)
    }
    func setup() {
        layer.borderColor = UIColor.red.withAlphaComponent(0.7).cgColor
        layer.borderWidth = 5.0
//        addSubview(image222)
        addSubview(detailsLabel)
    }
    func start_lip (){
        addSubview(lip)
    }
   override var frame: CGRect {
        didSet(newFrame) {
            var detailsFrame = detailsLabel.frame
            detailsFrame = CGRect(x: 0, y: newFrame.size.height, width: newFrame.size.width * 2.0, height: newFrame.size.height / 2.0)
            detailsLabel.frame = detailsFrame
        }
    }
}


class ViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    @IBAction func diss(_ sender: Any) {
        self.detailsView.image222.image = UIImage(named:"NUll.png")
    }
    var tag = 3
    @IBAction func push222(_ sender: Any) {
        print("push")
        self.detailsView.uuuaaa()
        view.addSubview(detailsView.image222)
        view.bringSubview(toFront: detailsView.image222)
        
    }
    var recordingSession:AVAudioSession!
    var audiorecorder:AVAudioRecorder!
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    var player:AVAudioPlayer?
    func playsound()  {
        guard let url = Bundle.main.url(forResource:"new",withExtension:"mp3") else {return}
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf:url)
        }catch {
        print("err")
        }
    }
    @IBAction func record(_ sender: Any) {
        print("pressed")
        tag = 2
//        let manager = FileManager.default
//        let urlforDocument = manager.urls(for: .documentDirectory, in: .userDomainMask)
//        let docPath=urlforDocument[0]
//        let audioFilename = docPath.appendingPathComponent("1.m4a")
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        do {
            print("indo")
            audiorecorder = try AVAudioRecorder(url: audioFilename , settings: recordSettings)
            print("tried")
            audiorecorder.delegate=self
            DispatchQueue.main.async {
            self.audiorecorder.record()
            }
        let time : TimeInterval = 5.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+time){
            self.audiorecorder.stop()
            print ( "record finished")
            self.playsound()
            
        }
        }catch{
//            print("\(err.localizedDescription)")
        }
    }
    
    
    
    
    var session: AVCaptureSession?
    var stillOutput = AVCaptureStillImageOutput()
    var borderLayer: CAShapeLayer?
   
    let detailsView: DetailsView = {
        let detailsView = DetailsView()
        detailsView.setup()
        
        return detailsView
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        var previewLay = AVCaptureVideoPreviewLayer(session: self.session!)
        previewLay?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        return previewLay
    }()
    
    lazy var frontCamera: AVCaptureDevice? = {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else { return nil }
        
        return devices.filter { $0.position == .front }.first
    }()
    
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = previewLayer else { return }
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(detailsView)
//        view.addSubview(lip)
        view.bringSubview(toFront: detailsView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sessionPrepare()
        session?.startRunning()
        recordingSession=AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
//            recordingSession.requestRecordPermission(){
//                [unowned self] allowed in
//                DispatchQueue.main.async {
//                    if allowed {
//                        self.loadRecordingUI()
//                    }else{
//
//                    }
//                }
//
//
//            }
//
//
            
        }
            catch{
//
        }
    }
}

extension ViewController {

    func sessionPrepare() {
        session = AVCaptureSession()
       
        guard let session = session, let captureDevice = frontCamera else { return }
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            output.alwaysDiscardsLateVideoFrames = true
        
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self, queue: queue)
            
        } catch {
            print("error with creating AVCaptureDeviceInput")
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
        let options: [String : Any] = [CIDetectorImageOrientation: exifOrientation(orientation: UIDevice.current.orientation),
                                       CIDetectorSmile: true,
                                       CIDetectorEyeBlink: true]
        let allFeatures = faceDetector?.features(in: ciImage, options: options)
    
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription!, false)
        
        guard let features = allFeatures else { return }
        
        //tag = 3
        for feature in features {
            if let faceFeature = feature as? CIFaceFeature {
                let faceRect = calculateFaceRect(facePosition: faceFeature.mouthPosition, faceBounds: faceFeature.bounds, clearAperture: cleanAperture)
                let featureDetails = ["has smile: \(faceFeature.hasSmile)",
                    "has closed left eye: \(faceFeature.leftEyeClosed)",
                    "has closed right eye: \(faceFeature.rightEyeClosed)"]
                print(faceFeature.mouthPosition.x)
                print(faceFeature.mouthPosition.y)
                put_lip(x1: faceFeature.leftEyePosition.x , y1: faceFeature.leftEyePosition.y,minx:faceFeature.bounds.minX,miny:faceFeature.bounds.minY,maxx : faceFeature.bounds.maxX,maxy: faceFeature.bounds.maxY,tag:tag)
                update(with: faceRect, text: featureDetails.joined(separator: "\n"))
            }
        }
        
        if features.count == 0 {
            DispatchQueue.main.async {
                self.detailsView.alpha = 0.0
            }
        }
        
    }
    
    func exifOrientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
        case .portraitUpsideDown:
            return 8
        case .landscapeLeft:
            return 3
        case .landscapeRight:
            return 1
        default:
            return 6
        }
    }
    
    func videoBox(frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height
        
        var size = CGSize.zero
     
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width
            size.height = apertureSize.width * (frameSize.width / apertureSize.height)
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width)
            size.height = frameSize.height
        }
        
        var videoBox = CGRect(origin: .zero, size: size)
       
        if (size.width < frameSize.width) {
            videoBox.origin.x = (frameSize.width - size.width) / 2.0
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2.0
        }
        
        if (size.height < frameSize.height) {
            videoBox.origin.y = (frameSize.height - size.height) / 2.0
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2.0
        }
       
        return videoBox
    }

    func calculateFaceRect(facePosition: CGPoint, faceBounds: CGRect, clearAperture: CGRect) -> CGRect {
        let parentFrameSize = previewLayer!.frame.size
        let previewBox = videoBox(frameSize: parentFrameSize, apertureSize: clearAperture.size)
        
        var faceRect = faceBounds
        
        swap(&faceRect.size.width, &faceRect.size.height)
        swap(&faceRect.origin.x, &faceRect.origin.y)

        let widthScaleBy = previewBox.size.width / clearAperture.size.height
        let heightScaleBy = previewBox.size.height / clearAperture.size.width
        
        faceRect.size.width *= widthScaleBy
        faceRect.size.height *= heightScaleBy
        faceRect.origin.x *= widthScaleBy
        faceRect.origin.y *= heightScaleBy
        
        faceRect = faceRect.offsetBy(dx: 10.0, dy: previewBox.origin.y)
        let frame = CGRect(x: parentFrameSize.width - faceRect.origin.x - faceRect.size.width / 2.0 - previewBox.origin.x / 2.0, y: faceRect.origin.y, width: faceRect.width, height: faceRect.height)
        
        return frame
    }
}

extension ViewController {
    func update(with faceRect: CGRect, text: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.detailsView.detailsLabel.text = text
                self.detailsView.alpha = 1.0
                self.detailsView.frame = faceRect
            }
        }
    }
    
    func put_lip (x1:CGFloat  , y1:CGFloat,minx : CGFloat , miny : CGFloat,maxx : CGFloat , maxy : CGFloat,tag:Int){
        if tag == 3 {return}
        print (x1)
        print ( y1 )
        DispatchQueue.main.async {
//            self.detailsView.lip = UIImageView(frame: CGRect(x: x, y: y, width: 150, height: 150))
            
//            self.detailsView.lip.center =
            
            if tag == 1 {
                self.detailsView.lip.frame=CGRect(x: (x1-minx)*0.65, y: (y1-miny)*1.4, width: 0.25*(maxx-minx), height: 0.2*(maxy-miny))
                self.detailsView.lip.image = UIImage(named:"lip.png")
            }else if tag == 2  {
                self.detailsView.lip.frame=CGRect(x: (x1-minx)*0.65, y: (y1-miny)*1.4, width: 0.28*(maxx-minx), height: 0.15*(maxy-miny))
                self.detailsView.lip.image = UIImage(named:"lip2.png")
            }else  {
                self.detailsView.lip.image = UIImage(named:"aaa.png")
            }
            print (self.detailsView.lip.image)
            print (CGFloat(x1))
            print ("000")
            print (CGFloat(y1))
            print ( "111" )
            self.detailsView.start_lip()
        }
    }
}
