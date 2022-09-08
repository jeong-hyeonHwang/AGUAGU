//
//  CodeArchive.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

//    private func handleGestureStateChange(state: HandGestureProcessor.State) {
//        let pointsPair = gestureProcessor.lastProcessedPointsPair
//        let drawPathMiddlePoint = CGPoint(x: drawPath.bounds.midX, y: drawPath.bounds.midY)
//        let middlePoint = CGPoint.midPoint(p1: pointsPair.thumbTip, p2: pointsPair.middleTip)
//        var tipsColor: UIColor
//        switch state {
//        case .possiblePinch, .possibleApart:
//            tipsColor = middleColor
//        case .pinched:
//            if gameOver == true {
//                gameRestart()
//
//            } else if drawPathMiddlePoint.distance(from: middlePoint) < 45 {
//                if gameStart == false {
//                    labelOpacityAnimation(target: nameLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
//                    labelOpacityAnimation(target: highScoreLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
//                    labelOpacityAnimation(target: scoreLabel, duration: 0.25, targetOpacity: 1, completion: { _ in })
//                    changePosition(layer: layer, path: drawPath)
//                    addOpacityChangeAnimation(duration: duration)
//                    updateScore()
//                    updateDuration()
//                    gameStart = true
//                } else if isTouched == false && gameOver == false {
//                    print(":::PINCH:::")
//                    if drawPathMiddlePoint.distance(from: middlePoint) < 45 {
//                        drawParticle(centerPoint: middlePoint)
//                        changePosition(layer: layer, path: drawPath)
//                        addOpacityChangeAnimation(duration: duration)
//                        updateScore()
//                        updateDuration()
//                        drawParticle(centerPoint: middlePoint)
//                        addParticleFadeInOutAnimation()
////                        playSound(tone: sfxSequence[sequenceInt])
////                        if sequenceInt < sfxSequence.count-1 {
////                            sequenceInt += 1
////                        } else {
////                            sequenceInt = 0
////                        }
//                    }
//                    isTouched = true
//                }
//            }
//            tipsColor = activeColor
//        case .apart, .unknown:
//            if isTouched == true {
//                print(":::APART:::")
//                isTouched = false
//            }
//            tipsColor = disactiveColor
//        }
//        cameraView.showPoints([pointsPair.thumbTip, pointsPair.middleTip], color: tipsColor)
//    }

// MARK: Camera Session Check
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

