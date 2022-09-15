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
    private var sfxEatPlayer = AVAudioPlayer()
    private var sfxGameOverPlayer = AVAudioPlayer()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback,
                options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch let error {
            print(error)
        }
        
        bgmPlayer = playerPrepare(source: "UGAUGA_BGM3", loop: true, volume: 0.5)
        let index = Int.random(in: 1...2)
        sfxEatPlayer = playerPrepare(source: "AGUAGU_SFX\(index)", loop: false, volume: 0.7)
        sfxGameOverPlayer = playerPrepare(source: "AGUAGU_GAMEOVER2", loop: false, volume: 1.0)
    }
    
    func playerPrepare(source: String, loop: Bool, volume: Float) -> AVAudioPlayer {
        
        var player = AVAudioPlayer()
        
        let soundSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: source, ofType: "mp3")!)
        do {
            player = try AVAudioPlayer(contentsOf: soundSource as URL)
            if loop {
                player.numberOfLoops = -1
            }
            player.volume = volume
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
    
    func changeBGMVolume(volume: Float, duration: CGFloat) {
        bgmPlayer.setVolume(volume, fadeDuration: duration)
    }
    
    func prepareSFX_Eat() {
        let index = Int.random(in: 1...2)
        sfxEatPlayer = playerPrepare(source: "AGUAGU_SFX\(index)", loop: false, volume: 1.0)
    }
    
    func playSFX_Eat() {
        prepareSFX_Eat()
        sfxEatPlayer.play()
    }
    
    func playSFX_GameOver() {
        sfxGameOverPlayer.play()
    }
}
