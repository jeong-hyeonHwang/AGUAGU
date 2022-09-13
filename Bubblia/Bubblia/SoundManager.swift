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
        
        let bgmSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: "UGAUGA_AGUAGUBGM", ofType: "mp3")!)
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
        let sfxSource = NSURL(fileURLWithPath: Bundle.main.path(forResource: "AGUAGU_AGUAGUSFX", ofType: "mp3")!)
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: sfxSource as URL)
            sfxPlayer.volume = 0.6
            sfxPlayer.numberOfLoops = 1
            sfxPlayer.prepareToPlay()
        } catch {
            print("BGM CAN'T PLAY")
        }
        sfxPlayer.play()
    }
}
