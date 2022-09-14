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
    private var sfxPlayer = AVAudioPlayer()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback,
                options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch let error {
            print(error)
        }
        
        let bgmSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: "UGAUGA_BGM3", ofType: "mp3")!)
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: bgmSource as URL)
            bgmPlayer.numberOfLoops = -1
            bgmPlayer.prepareToPlay()
        } catch {
            print("BGM CAN'T PLAY")
        }
    }
    
    func playBGM() {
        bgmPlayer.play()
    }
    
    func playSFX() {
        let index = Int.random(in: 1...2)
        let sfxSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: "AGUAGU_SFX\(index)", ofType: "mp3")!)
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: sfxSource as URL)
            sfxPlayer.volume = 1.0
            sfxPlayer.prepareToPlay()
        } catch {
            print("SFX CAN'T PLAY")
        }
        sfxPlayer.play()
    }
}
