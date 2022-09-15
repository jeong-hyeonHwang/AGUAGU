//
//  SoundManager.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/13.
//

import AVFoundation

class SoundManager {
    static var shared = SoundManager()
    private var bgmPlayer = AVAudioPlayer()
    private var sfx_EatPlayer = AVAudioPlayer()
    private var sfx_GameOverPlayer = AVAudioPlayer()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback,
                options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch let error {
            print(error)
        }
        
        bgmPlayer = playerPrepare(source: "UGAUGA_BGM3", loop: true)
        let index = Int.random(in: 1...2)
        sfx_EatPlayer = playerPrepare(source: "AGUAGU_SFX\(index)", loop: false)
        sfx_GameOverPlayer = playerPrepare(source: "AGUAGU_SFX1", loop: false)
    }
    
    func playerPrepare(source: String, loop: Bool) -> AVAudioPlayer {
        
        var player = AVAudioPlayer()
        
        let soundSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: source, ofType: "mp3")!)
        do {
            player = try AVAudioPlayer(contentsOf: soundSource as URL)
            if loop {
                player.numberOfLoops = -1
            }
            player.prepareToPlay()
        } catch {
            print("SOUND CAN'T PLAY")
        }
        
        return player
    }
    
    func playBGM() {
        bgmPlayer.play()
    }
    
    func pauseBGM() {
        bgmPlayer.stop()
    }
    
    func prepareSFX_Eat() {
        let index = Int.random(in: 1...2)
        sfx_EatPlayer = playerPrepare(source: "AGUAGU_SFX\(index)", loop: false)
    }
    
    func playSFX_Eat() {
        prepareSFX_Eat()
        sfx_EatPlayer.play()
    }
    
    func playSFX_GameOver() {
        sfx_GameOverPlayer.play()
    }
}
