//
//  playsound.swift
//  cookies
//
//  Created by User12 on 2022/5/18.
//

import Foundation
import AVFoundation
var player: AVAudioPlayer!

func playSound(key: String){
    
    let url = Bundle.main.url(forResource: key, withExtension:"mp3")
    
    guard url != nil else {
        return}
    do{
        player = try AVAudioPlayer(contentsOf: url!)
        player?.play()
    }catch{
        print("\(error)")
    }
}

