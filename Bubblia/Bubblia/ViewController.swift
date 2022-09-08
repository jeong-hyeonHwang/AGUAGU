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
    
    private var cameraView = UIImageView()
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    
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
    private var isTouched = false
    
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
    
    private var particleLayer = CAShapeLayer()
    private var particlePath = UIBezierPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //https://stackoverflow.com/questions/66037782/swiftui-how-do-i-lock-a-particular-view-in-portrait-mode-whilst-allowing-others
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            cameraView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
        ])
        cameraView.backgroundColor = .black
        
        width = view.bounds.maxX
        height = view.bounds.maxY
        
        circleRadius = height * 30 / 844
        
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
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        self.particleLayer.add(animation, forKey: "ParticleFadeOut")
        
        CATransaction.commit()
    }
    func updateScore() {
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
    }
    
}
