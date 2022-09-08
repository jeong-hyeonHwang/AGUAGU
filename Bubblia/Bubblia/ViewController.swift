//
//  ViewController.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation
import Vision

private enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

class ViewController: UIViewController {
    
    private var isAuth: SessionSetupResult! = .success
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private var lastObservationTimestamp = Date()
    
    private var lastDrawPoint: CGPoint?
    private var isTouched = false
    
    private var gestureProcessor = HandGestureProcessor()
    
    private var layer = CAShapeLayer()
    private var drawPath = UIBezierPath()
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    private var nameLabel = UILabel()
    private var scoreLabel = UILabel()
    private var highScoreLabel = UILabel()
    private var gameOverLabel = UILabel()
    
    private var scoreInt: Int = 0
    
    private var gameStart = false
    private var gameOver = false
    
    private var highScore: Int = 0
    
    private let accentColor: UIColor = .accentColor
    ?? .yellow
    private let activeColor: UIColor = .activeColor ?? .green
    private let middleColor: UIColor = .activeColor ?? .orange
    private let disactiveColor: UIColor = .disactiveColor ?? .red
    
//    private var duration: CGFloat = 3
//    private var patienceCount: Int = 0
//    private let durationMinusValue: CGFloat = 0.025
//    private let durationMinLimitNum: CGFloat = 0.75
//    private let durationMaxLimitNum: CGFloat = 3
//    private var patientLimitNum = 10
//    private let patientPlusValue: Int = 10
    
    private let highScoreNoticeLabel = UILabel()
    
    private var duration: CGFloat = 3
    private var patienceCount: Int = 0
    private let durationMinusValue: CGFloat = 0.5
    private let durationMinLimitNum: CGFloat = 1.5
    private let durationMaxLimitNum: CGFloat = 3
    private var patientLimitNum = 10
    private let patientPlusValue: Int = 10
    
    private var circleRadius: CGFloat = 60
    
    private let sfxSequence: [String] = ["E", "A", "B", "D", "C", "A", "C", "F"]
    
    private var sequenceInt: Int = 0
    
    private var particleLayer = CAShapeLayer()
    private var particlePath = UIBezierPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //https://stackoverflow.com/questions/66037782/swiftui-how-do-i-lock-a-particular-view-in-portrait-mode-whilst-allowing-others
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        width = view.bounds.maxX
        height = view.bounds.maxY
        
        circleRadius = height * 30 / 844
        
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        drawPath.addArc(withCenter: CGPoint(x: width/2, y: height * 0.38), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        layer.path = drawPath.cgPath
        layer.fillColor = accentColor.cgColor
        view.layer.addSublayer(layer)
        
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
        print("Recorded High Score is \(highScore)")
        scoreLabel.text = highScore == 0 ? "" : "\(highScore)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 60, weight: .regular)
        scoreLabel.textColor = accentColor
        scoreLabel.alpha = 0
        
        view.addSubview(highScoreLabel)
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height * 0.12),
            highScoreLabel.heightAnchor.constraint(equalToConstant: 36),
            highScoreLabel.widthAnchor.constraint(equalToConstant: width)
        ])

        highScoreLabel.text = highScore == 0 ? "" : "\(highScore)"
        highScoreLabel.textAlignment = .center
        highScoreLabel.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        highScoreLabel.textColor = accentColor
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            nameLabel.bottomAnchor.constraint(equalTo: highScoreLabel.topAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 88),
            nameLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        nameLabel.text = "AGUAGU"//"KR◎KR◎N" //"KR◎◎RK"//"B◎BBLIA"
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
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    break
                case .notDetermined:
                    videoDataOutputQueue.suspend()
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                        if !granted {
                            self.isAuth = .notAuthorized
                        }
                        self.videoDataOutputQueue.resume()
                    })
                default:
                    isAuth = .notAuthorized
                }
        view.layer.addSublayer(particleLayer)
        drawParticle(centerPoint: CGPoint(x: width/2, y: height/2))
        particleLayer.fillColor = UIColor.accentColor?.cgColor
        particleLayer.opacity = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        videoDataOutputQueue.async {
//                    switch self.isAuth {
//                    case .success:
//                        //self.session.startRunning()
//                        break
//                    // 카메라 접근 권한이 없는 경우에는 카메라 접근이 불가능하다는 Alert를 띄워줍니다
//                    case .notAuthorized:
//                        DispatchQueue.main.async {
//                            let message = NSLocalizedString("Permissions are required to use the camera for hand detection. You can set permissions in [Settings] > [Privacy] > [Camera].",
//                                                            comment: "Alert message when the user has denied access to the camera")
//                            let actions = [
//                                UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                              style: .cancel,
//                                              handler: nil),
//                                UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
//                                              style: .`default`,
//                                              handler: { _ in
//                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//                                                                          options: [:],
//                                                                          completionHandler: nil)
//                                })
//                            ]
//
//                            self.alert(title: "AGUAGU", message: message, actions: actions)
//                            }
//                    case .configurationFailed:
//                        DispatchQueue.main.async {
//
//                            let message = NSLocalizedString("Can't use camera.",
//                                                            comment: "Alert message when something goes wrong during capture session configuration")
//
//                            self.alert(title: "AGUAGU",
//                                       message: message,
//                                       actions: [UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                                               style: .cancel,
//                                                               handler: nil)])
//                        }
//                    case .none:
//                        return
//                    }
//                }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func processPoints(thumbTip: CGPoint?, middleTip: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let middlePoint = middleTip else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let middlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middlePoint)
        
        // Process new points
        gestureProcessor.processPointsPair((thumbPointConverted, middlePointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        let drawPathMiddlePoint = CGPoint(x: drawPath.bounds.midX, y: drawPath.bounds.midY)
        let middlePoint = CGPoint.midPoint(p1: pointsPair.thumbTip, p2: pointsPair.middleTip)
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            tipsColor = middleColor
        case .pinched:
            if gameOver == true {
                gameRestart()
                
            } else if drawPathMiddlePoint.distance(from: middlePoint) < 45 {
                if gameStart == false {
                    labelOpacityAnimation(target: nameLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
                    labelOpacityAnimation(target: highScoreLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
                    labelOpacityAnimation(target: scoreLabel, duration: 0.25, targetOpacity: 1, completion: { _ in })
                    changePosition(layer: layer, path: drawPath)
                    addOpacityChangeAnimation(duration: duration)
                    updateScore()
                    updateDuration()
                    gameStart = true
                } else if isTouched == false && gameOver == false {
                    print(":::PINCH:::")
                    if drawPathMiddlePoint.distance(from: middlePoint) < 45 {
                        drawParticle(centerPoint: middlePoint)
                        changePosition(layer: layer, path: drawPath)
                        addOpacityChangeAnimation(duration: duration)
                        updateScore()
                        updateDuration()
                        drawParticle(centerPoint: middlePoint)
                        addParticleFadeInOutAnimation()
//                        playSound(tone: sfxSequence[sequenceInt])
//                        if sequenceInt < sfxSequence.count-1 {
//                            sequenceInt += 1
//                        } else {
//                            sequenceInt = 0
//                        }
                    }
                    isTouched = true
                }
            }
            tipsColor = activeColor
        case .apart, .unknown:
            if isTouched == true {
                print(":::APART:::")
                isTouched = false
            }
            tipsColor = disactiveColor
        }
        cameraView.showPoints([pointsPair.thumbTip, pointsPair.middleTip], color: tipsColor)
    }
    
    func alert(title: String, message: String, actions: [UIAlertAction]) {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            actions.forEach {
                alertController.addAction($0)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    
    func drawParticle(centerPoint: CGPoint) {
        let startXDistance: CGFloat = 55
        let startYDistance: CGFloat = 18
//        let centerPoint = CGPoint(x: 300, y: 300)

//        let xValue: CGFloat = 18
//        let yValue: CGFloat = 8
//        let radius: CGFloat = 5
        let xValue: CGFloat = 12
        let yValue: CGFloat = 5
        let radius: CGFloat = 3
        
        particlePath.removeAllPoints()

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
            particlePath.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y - yDistance))
            particlePath.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y - yDistance), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            particlePath.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y))
            particlePath.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            particlePath.move(to: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y + yDistance))
            particlePath.addArc(withCenter: CGPoint(x: centerPoint.x - xDistance, y: centerPoint.y + yDistance), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        particleLayer.path = particlePath.cgPath
    }
    
    func changePosition(layer: CAShapeLayer, path: UIBezierPath) {
        layer.opacity = 0
        
        let randomX = CGFloat.random(in: 100...width-100)
        let randomY = CGFloat.random(in: 200...height-200)
        
        path.removeAllPoints()
        path.addArc(withCenter: CGPoint(x: randomX, y: randomY), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        layer.path = path.cgPath
        layer.fillColor = accentColor.cgColor
        layer.opacity = 1
    }
    
    func addOpacityChangeAnimation(duration: CGFloat) {
        // https://ios-development.tistory.com/937
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            // https://stackoverflow.com/questions/20244933/get-current-caanimation-transform-value
            let currentOpacity = self.layer.presentation()?.value(forKeyPath: "opacity") ?? 0.0
            if (currentOpacity as! Double) <= 0.01 {
                print("-----GAME OVER-----")
                self.layer.isHidden = true
                
                self.labelOpacityAnimation(target: self.gameOverLabel, duration: 0.25, targetOpacity: 1, completion: { _ in
                    
                    print(self.highScore)
                    print(self.scoreInt)
                    if self.highScore < self.scoreInt {
                        self.labelOpacityAnimation(target: self.highScoreNoticeLabel, duration: 0.25, targetOpacity: 1, completion: { _ in
                            self.checkHighScore()
                        })
                    }
                    
                    self.drawPath.removeAllPoints()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.gameOver = true
                    })
                })
            } else {
                print(">>> GOGOGO!!! <<<")
            }
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = layer.opacity
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "changeOpacity")
        
        CATransaction.commit()
    }
    
    func addParticleFadeInOutAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = self.particleLayer.opacity
            animation.toValue = 0
            animation.duration = 3
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            self.particleLayer.add(animation, forKey: "ParticleFadeIn")
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = particleLayer.opacity
        animation.toValue = 1
        animation.duration = 0.1
        animation.autoreverses = true
        animation.repeatCount = 2
//        animation.fillMode = .forwards
//        animation.isRemovedOnCompletion = true
        self.particleLayer.add(animation, forKey: "ParticleFadeOut")
        
        CATransaction.commit()
    }
    func updateScore() {
//        scoreLabel.textColor = .yellow
        scoreInt += 1
        scoreLabelTextAnimation()
    }
    
    func returnToDefaultScore() {
        scoreInt = 1
        scoreLabelTextAnimation()
    }
    
    func updateDuration() {
        if duration != durationMinLimitNum {
            duration -= durationMinusValue
            print("CURRENT DURATION IS \(duration)")
        } else {
            patienceCount += 1
            print("BE PATIENT \(patienceCount)")
            if patienceCount == patientLimitNum {
                patienceCount = 0
                if patientLimitNum != 50 {
                    patientLimitNum += patientPlusValue
                }
                duration = durationMaxLimitNum
                print("PATIENT IS OVER")
            }
        }
    }
    
    func returnToDefaultDuration() {
        duration = durationMaxLimitNum
        patienceCount = 0
        patientLimitNum = patientPlusValue
    }
    
    func scoreLabelTextAnimation() {
        UIView.transition(with: scoreLabel,
                          duration: 0.15,
                          options: .transitionFlipFromLeft,
                          animations: {
            self.scoreLabel.text = "\(self.scoreInt)"
        }, completion: nil)
    }
    
    func labelOpacityAnimation(target: UILabel, duration: CGFloat, targetOpacity: CGFloat, completion: @escaping (Bool) -> Void) {
        UIView.transition(with: target,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            target.alpha = targetOpacity
        }, completion: completion)
    }
    
    func checkHighScore() {
        if highScore < scoreInt {
            setHighScore(value: scoreInt)
            highScore = scoreInt
            print("### HIGHSCORE \(highScore) ###")
        } else {
            print(">>> SAME HIGHSCORE <<<")
        }
    }
    
    func gameRestart() {
        labelOpacityAnimation(target: gameOverLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        labelOpacityAnimation(target: highScoreNoticeLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        returnToDefaultScore()
        returnToDefaultDuration()
        changePosition(layer: layer, path: drawPath)
        addOpacityChangeAnimation(duration: duration)
        
        layer.isHidden = false
        gameOver = false
        isTouched = false
        sequenceInt = 0
    }
    
}
