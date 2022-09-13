//
//  ViewController.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    var isAuth: SessionSetupResult! = .success
    
    private var cameraView = UIImageView()
    
    private var videoCapture: VideoCapture!
    private var videoProcessingChain: VideoProcessingChain!
    
    private var yellowFruitShape = UIBezierPath()
    private var yellowFruitShapeLayer = CAShapeLayer()
    
    private var particleShapeLayer = CAShapeLayer()
    private var particleShape = UIBezierPath()
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    private var nameLabel = UILabel()
    private var scoreLabel = UILabel()
    private let highScoreNoticeLabel = UILabel()
    private var highScoreValueLabel = UILabel()
    private var gameOverLabel = UILabel()
    
    private let accentColor: UIColor = .accentColor ?? .yellow
    
    private var scoreInt: Int = 0
    private var highScore: Int = 0
    
    private var duration: CGFloat = 3
    private let durationMinusValue: CGFloat = 0.025
    private let durationMinLimitNum: CGFloat = 0.75
    private let durationMaxLimitNum: CGFloat = 3
    private var patienceCount: Int = 0
    private var patientLimitNum = 10
    private let patientPlusValue: Int = 10
    
    private var circleRadius: CGFloat = 60
    
    private var gameStart = false
    private var gameOver = false
    private var gameCanRestart = false
    
    private var pastHandStatus: HandPoseStatus = .possible
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //https://stackoverflow.com/questions/66037782/swiftui-how-do-i-lock-a-particular-view-in-portrait-mode-whilst-allowing-others
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
        UIApplication.shared.isIdleTimerDisabled = true
        
        setCameraViewLayout()
        setVideoDelegate()
        
        initializeProperties()
        setUILabel()
        setShapeLayer()
        
        checkCaptureDeviceAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(gameIsOver), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
//        SoundManager.shared.playBGM()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCapture.cameraPermissionCheck(vc: self)
    }
    
    @objc func gameIsOver() {
        if gameStart == true {
            gameOver = true
            setUIGameOver()
        }
    }
    
    private func setCameraViewLayout() {
        view.backgroundColor = .black
        
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            cameraView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
        ])
    }
    
    private func setVideoDelegate() {
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.setOneHandDetection()
        videoProcessingChain.delegate = self

        videoCapture = VideoCapture()
        videoCapture.delegate = self
    }
    
    private func initializeProperties() {
        width = view.bounds.maxX
        height = view.bounds.maxY
        circleRadius = height * 30 / 844
    }
    
    private func setUILabel() {
        view.addSubview(highScoreNoticeLabel)
        highScoreNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highScoreNoticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreNoticeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            highScoreNoticeLabel.heightAnchor.constraint(equalToConstant: 80),
            highScoreNoticeLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        highScoreNoticeLabel.text = "HIGHSCORE"
        highScoreNoticeLabel.textAlignment = .center
        highScoreNoticeLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        highScoreNoticeLabel.textColor = accentColor
        highScoreNoticeLabel.alpha = 0
        
        view.addSubview(scoreLabel)
        scoreLabel.frame = CGRect(x: 0, y: height/2 - 75, width: width, height: 150)
        scoreLabel.center = CGPoint(x: width/2, y: height/2)
        
        highScore = getHighScore()
        scoreLabel.text = highScore == 0 ? "" : "\(highScore)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 60, weight: .regular)
        scoreLabel.textColor = accentColor
        scoreLabel.alpha = 0
        
        view.addSubview(highScoreValueLabel)
        highScoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highScoreValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreValueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height * 0.12),
            highScoreValueLabel.heightAnchor.constraint(equalToConstant: 36),
            highScoreValueLabel.widthAnchor.constraint(equalToConstant: width)
        ])

        highScoreValueLabel.text = highScore == 0 ? "" : "\(highScore)"
        highScoreValueLabel.textAlignment = .center
        highScoreValueLabel.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        highScoreValueLabel.textColor = accentColor
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            nameLabel.bottomAnchor.constraint(equalTo: highScoreValueLabel.topAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 88),
            nameLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        nameLabel.text = "AGUAGU"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        nameLabel.textColor = accentColor
        
        view.addSubview(gameOverLabel)
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameOverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameOverLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            gameOverLabel.heightAnchor.constraint(equalToConstant: 80),
            gameOverLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.textAlignment = .center
        gameOverLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        gameOverLabel.textColor = accentColor
        gameOverLabel.alpha = 0
    }
    
    private func setShapeLayer() {
        yellowFruitShape.addArc(withCenter: CGPoint(x: width/2, y: height * 0.38), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        yellowFruitShapeLayer.path = yellowFruitShape.cgPath
        yellowFruitShapeLayer.fillColor = accentColor.cgColor
        view.layer.addSublayer(yellowFruitShapeLayer)
        
        cameraView.layer.addSublayer(particleShapeLayer)
        drawParticle(centerPoint: CGPoint(x: width/2, y: height/2))
        particleShapeLayer.fillColor = UIColor.accentColor?.cgColor
        particleShapeLayer.opacity = 0
    }
    
    private func checkCaptureDeviceAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    break
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                        if !granted {
                            self.isAuth = .notAuthorized
                        }
                    })
                default:
                    isAuth = .notAuthorized
        }
    }
}

extension ViewController: VideoCaptureDelegate {
    
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher) {
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
    
}

extension ViewController: VideoProcessingChainDelegate {
    
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [HandPose]?,
                              in frame: CGImage) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.drawPoses(poses, onto: frame)
        }
    }
    
}

/// ViewController Extension for Alert
extension ViewController {
    
    func alert(title: String, message: String, actions: [UIAlertAction]) {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            actions.forEach {
                alertController.addAction($0)
            }
            
            self.present(alertController, animated: true, completion: nil)
    }
    
}

/// ViewController Extension for Game UI & Value Update
extension ViewController {
    
    private func drawParticle(centerPoint: CGPoint) {
        let startXDistance: CGFloat = 55
        let startYDistance: CGFloat = 18
        let xValue: CGFloat = 12
        let yValue: CGFloat = 5
        let radius: CGFloat = 3
        
        particleShape.removeAllPoints()

        for i in 0..<6 {
            var xDistance: CGFloat = 0
            var yDistance: CGFloat = 0
            if i < 3 {
                xDistance = startXDistance + xValue * CGFloat(i)
                yDistance = startYDistance + yValue * CGFloat(i)
            } else {
                xDistance = -startXDistance - xValue * CGFloat(i%3)
                yDistance = -startYDistance - yValue * CGFloat(i%3)
            }
            particleShape.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y - yDistance))
            particleShape.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y - yDistance), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            particleShape.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y))
            particleShape.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            particleShape.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y + yDistance))
            particleShape.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y + yDistance), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        particleShapeLayer.path = particleShape.cgPath
    }
    
    private func changePosition(layer: CAShapeLayer, path: UIBezierPath) {
        layer.opacity = 0
        
        let randomX = CGFloat.random(in: 100...width-100)
        let randomY = CGFloat.random(in: 200...height-200)
        
        path.removeAllPoints()
        path.addArc(withCenter: CGPoint(x: randomX, y: randomY), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        layer.path = path.cgPath
        layer.fillColor = accentColor.cgColor
        layer.opacity = 1
    }
    
    private func addOpacityChangeAnimation(duration: CGFloat) {
        // https://ios-development.tistory.com/937
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            // https://stackoverflow.com/questions/20244933/get-current-caanimation-transform-value
            let currentOpacity = self.yellowFruitShapeLayer.presentation()?.value(forKeyPath: "opacity") ?? 0.0
            if (currentOpacity as! Double) <= 0.001 {
                self.setUIGameOver()
            }
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = yellowFruitShapeLayer.opacity
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        yellowFruitShapeLayer.add(animation, forKey: "changeOpacity")
        
        CATransaction.commit()
    }
    
    private func setUIGameOver() {
        gameOver = true
        yellowFruitShapeLayer.isHidden = true
        
        labelOpacityAnimation(target: gameOverLabel, duration: 0.25, targetOpacity: 1, completion: { _ in
            if self.highScore < self.scoreInt {
                self.labelOpacityAnimation(target: self.highScoreNoticeLabel, duration: 0.25, targetOpacity: 1, completion: { _ in
                    self.checkHighScore()
                })
            }
            
            self.yellowFruitShape.removeAllPoints()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.gameCanRestart = true
            })
        })
    }
    
    private func addParticleFadeInOutAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = self.particleShapeLayer.opacity
            animation.toValue = 0
            animation.duration = 3
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            self.particleShapeLayer.add(animation, forKey: "ParticleFadeIn")
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = particleShapeLayer.opacity
        animation.toValue = 1
        animation.duration = 0.1
        animation.autoreverses = true
        animation.repeatCount = 2
        self.particleShapeLayer.add(animation, forKey: "ParticleFadeOut")
        
        CATransaction.commit()
    }
    
    private func updateScore() {
        scoreInt += 1
        scoreLabelTextAnimation()
    }
    
    private func returnToDefaultScore() {
        scoreInt = 1
        scoreLabelTextAnimation()
    }
    
    private func updateDuration() {
        if duration != durationMinLimitNum {
            duration -= durationMinusValue
        } else {
            patienceCount += 1
            if patienceCount == patientLimitNum {
                patienceCount = 0
                if patientLimitNum != 50 {
                    patientLimitNum += patientPlusValue
                }
                duration = durationMaxLimitNum
            }
        }
    }
    
    private func returnToDefaultDuration() {
        duration = durationMaxLimitNum
        patienceCount = 0
        patientLimitNum = patientPlusValue
    }
    
    private func scoreLabelTextAnimation() {
        UIView.transition(with: scoreLabel,
                          duration: 0.15,
                          options: .transitionFlipFromLeft,
                          animations: {
            self.scoreLabel.text = "\(self.scoreInt)"
        }, completion: nil)
    }
    
    private func labelOpacityAnimation(target: UILabel, duration: CGFloat, targetOpacity: CGFloat, completion: @escaping (Bool) -> Void) {
        UIView.transition(with: target,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            target.alpha = targetOpacity
        }, completion: completion)
    }
    
    private func checkHighScore() {
        if highScore < scoreInt {
            setHighScore(value: scoreInt)
            highScore = scoreInt
        }
    }
    
    private func gameRestart() {
        labelOpacityAnimation(target: gameOverLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        labelOpacityAnimation(target: highScoreNoticeLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        returnToDefaultScore()
        returnToDefaultDuration()
        changePosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
        addOpacityChangeAnimation(duration: duration)
        
        yellowFruitShapeLayer.isHidden = false
        gameOver = false
        gameCanRestart = false
    }
    
}

extension ViewController {
    
    private func drawPoses(_ poses: [HandPose]?, onto frame: CGImage) {
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0

        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
                                                   format: renderFormat)

        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            let inverse = cgContext.ctm.inverted()

            cgContext.concatenate(inverse)

            let pointTransform = CGAffineTransform(scaleX: frameSize.width,
                                                   y: frameSize.height)
            
            guard let poses = poses else { return }

            let yellowFruitShapeMiddlePoint = CGPoint(x: yellowFruitShape.bounds.midX, y: yellowFruitShape.bounds.midY)
            
            for pose in poses {
                let handStatus = pose.drawWireframeToContext(cgContext, applying: pointTransform, point: yellowFruitShapeMiddlePoint, pastStatus: pastHandStatus)
                switch handStatus {
                case .possible:
                    break
                case .pinched:
                    if gameOver == false && pastHandStatus == .possible {
                        DispatchQueue.main.async {
//                            SoundManager.shared.playSFX()
                                self.gameStatusUpdateFunction(middlePoint: yellowFruitShapeMiddlePoint)
                            }
                    }
                case .invalid:
                    if gameCanRestart == true && pastHandStatus == .possible {
                        DispatchQueue.main.async {
                            
                            self.gameRestart()
                        }
                    }
                }
                pastHandStatus = handStatus
            }
        }
        
        DispatchQueue.main.async { self.cameraView.image = frameWithPosesRendering }
    }
    
    private func gameStatusUpdateFunction(middlePoint: CGPoint) {
        if gameStart == false {
            labelOpacityAnimation(target: nameLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
            labelOpacityAnimation(target: highScoreValueLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
            labelOpacityAnimation(target: scoreLabel, duration: 0.25, targetOpacity: 1, completion: { _ in })
            changePosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
            addOpacityChangeAnimation(duration: duration)
            updateScore()
            updateDuration()
            gameStart = true
        } else if gameOver == false {
            drawParticle(centerPoint: middlePoint)
            changePosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
            addOpacityChangeAnimation(duration: duration)
            updateScore()
            updateDuration()
            drawParticle(centerPoint: middlePoint)
            addParticleFadeInOutAnimation()
        }
    }
    
}

