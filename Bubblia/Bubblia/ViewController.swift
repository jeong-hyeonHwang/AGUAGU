//
//  ViewController.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation
import Vision

final class ViewController: UIViewController {
    
    var isCameraSessionAuth: CameraSessionSetupStatus! = .success
    
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
    
    private let opacityAnimDuration: CGFloat = 0.25
    
    private let accentColor: UIColor = .accentColor ?? .yellow
    
    private var scoreInt: Int = 0
    private var highScore: Int = 0
    
    private var duration: CGFloat = 3
    private let durationMinusValue: CGFloat = 0.025
    private let durationMinLimitNum: CGFloat = 0.75
    private let durationMaxLimitNum: CGFloat = 3
    private var patienceCount: Int = 0
    private var patientLimitNum = 10
    private var patientMaxLimitNum = 50
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
        
        SoundManager.shared.playBGM()
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
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        
        [highScoreNoticeLabel, highScoreValueLabel, nameLabel, gameOverLabel].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            highScoreNoticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreNoticeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            highScoreNoticeLabel.heightAnchor.constraint(equalToConstant: 80),
            highScoreNoticeLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        labelSetting(label: highScoreNoticeLabel, text: "HIGHSCORE", fontSize: 24, weight: .regular)
        highScoreNoticeLabel.alpha = 0
        
        view.addSubview(scoreLabel)
        scoreLabel.frame = CGRect(x: 0, y: height/2 - 75, width: width, height: 150)
        scoreLabel.center = CGPoint(x: width/2, y: height/2)
        
        labelSetting(label: scoreLabel, text: "", fontSize: 60, weight: .regular)
        scoreLabel.alpha = 0
        
        NSLayoutConstraint.activate([
            highScoreValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreValueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height * 0.12),
            highScoreValueLabel.heightAnchor.constraint(equalToConstant: 36),
            highScoreValueLabel.widthAnchor.constraint(equalToConstant: width)
        ])

        highScore = getHighScore()
        let highScoreText = highScore == 0 ? "" : "\(highScore)"
        labelSetting(label: highScoreValueLabel, text: highScoreText, fontSize: 48, weight: .medium)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: highScoreValueLabel.topAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 88),
            nameLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        labelSetting(label: nameLabel, text: "AGUAGU", fontSize: 64, weight: .bold)
        NSLayoutConstraint.activate([
            gameOverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameOverLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            gameOverLabel.heightAnchor.constraint(equalToConstant: 80),
            gameOverLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        labelSetting(label: gameOverLabel, text: "GAME OVER", fontSize: 36, weight: .semibold)
        gameOverLabel.alpha = 0
    }
    
    private func labelSetting(label: UILabel, text: String, fontSize: CGFloat, weight: UIFont.Weight) {
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = accentColor
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
                            self.isCameraSessionAuth = .notAuthorized
                        }
                    })
                default:
                    isCameraSessionAuth = .notAuthorized
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

        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        for i in 0..<6 {
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
    
    private func changeFruitPosition(layer: CAShapeLayer, path: UIBezierPath) {
        layer.opacity = 0
        
        let randomX = CGFloat.random(in: 100...width-100)
        let randomY = CGFloat.random(in: 200...height-200)
        
        path.removeAllPoints()
        path.addArc(withCenter: CGPoint(x: randomX, y: randomY), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        layer.path = path.cgPath
        layer.fillColor = accentColor.cgColor
        layer.opacity = 1
    }
    
    private func addYellowFruitOpacityAnimation(duration: CGFloat) {
        // https://ios-development.tistory.com/937
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [self] in
            // https://stackoverflow.com/questions/20244933/get-current-caanimation-transform-value
            let currentOpacity = yellowFruitShapeLayer.presentation()?.value(forKeyPath: "opacity") ?? 0.0
            if (currentOpacity as! Double) <= 0.001 {
                SoundManager.shared.playSFX_GameOver()
                SoundManager.shared.changeBGMVolume(volume: 0.2, duration: 0.3)
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
        
        labelOpacityAnimation(target: gameOverLabel, duration: opacityAnimDuration, targetOpacity: 1, completion: { [self] _ in
            if highScore < scoreInt {
                labelOpacityAnimation(target: highScoreNoticeLabel, duration: opacityAnimDuration, targetOpacity: 1, completion: { _ in
                    self.checkHighScore()
                })
            }
            
            yellowFruitShape.removeAllPoints()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.gameCanRestart = true
            })
        })
    }
    
    private func addParticleBlinkAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [self] in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = particleShapeLayer.opacity
            animation.toValue = 0
            animation.duration = 0.1
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            particleShapeLayer.add(animation, forKey: "ParticleFadeIn")
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = particleShapeLayer.opacity
        animation.toValue = 1
        animation.duration = 0.1
        animation.autoreverses = true
        animation.repeatCount = 2
        particleShapeLayer.add(animation, forKey: "ParticleFadeOut")
        
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
                if patientLimitNum != patientMaxLimitNum {
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
    
    private func labelOpacityAnimation(target: UILabel, duration: CGFloat, targetOpacity: CGFloat, completion: ((Bool) -> Void)? = nil) {
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
        labelOpacityAnimation(target: gameOverLabel, duration: opacityAnimDuration, targetOpacity: 0, completion: nil)
        labelOpacityAnimation(target: highScoreNoticeLabel, duration: opacityAnimDuration, targetOpacity: 0, completion: nil)
        changeFruitPosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
        addYellowFruitOpacityAnimation(duration: duration)
        returnToDefaultScore()
        returnToDefaultDuration()
        
        yellowFruitShapeLayer.isHidden = false
        gameOver = false
        gameCanRestart = false
        
        SoundManager.shared.changeBGMVolume(volume: 0.5, duration: 0.5)
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
                            SoundManager.shared.playSFX_Eat()
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
            labelOpacityAnimation(target: nameLabel, duration: opacityAnimDuration, targetOpacity: 0, completion: nil)
            labelOpacityAnimation(target: highScoreValueLabel, duration: opacityAnimDuration, targetOpacity: 0, completion: nil)
            labelOpacityAnimation(target: scoreLabel, duration: opacityAnimDuration, targetOpacity: 1, completion: nil)
            changeFruitPosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
            addYellowFruitOpacityAnimation(duration: duration)
            updateScore()
            updateDuration()
            gameStart = true
        } else if gameOver == false {
            drawParticle(centerPoint: middlePoint)
            changeFruitPosition(layer: yellowFruitShapeLayer, path: yellowFruitShape)
            addYellowFruitOpacityAnimation(duration: duration)
            updateScore()
            updateDuration()
            drawParticle(centerPoint: middlePoint)
            addParticleBlinkAnimation()
        }
    }
}

