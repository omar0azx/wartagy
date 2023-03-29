//
//  MainVC.swift
//  وارتقِ
//
//  Created by omar on 07/09/1444 AH.
//

import UIKit
import AVFoundation
import Lottie

class MainVC: UIViewController {
    
    var audioPlayer : AVAudioPlayer!
    var selectedSoundFileName : String = ""

    @IBOutlet weak var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSoundFileName = "ترحيب"
        playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.lottieAnimation(name: "swipeRight")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            self.lottieAnimation(name: "swipeLeft")
        }
    }
    
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            audioPlayer.stop()
            goToNextPage()
        case .left:
            print("left")
        default:
            print("default")
        }
    }
    
    
    //MARK: Displat Audio
    
    func playSound() {
        let soundUrl = Bundle.main.url(forResource: selectedSoundFileName, withExtension: "wav")
        do {
            audioPlayer = try! AVAudioPlayer(contentsOf: soundUrl!)
        } catch {
            print(error)
        }
        audioPlayer.play()
    }
    
    //MARK: - Functions
    
    func lottieAnimation(name: String) {
        animationView.animation = LottieAnimation.named(name)
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
    
    //MARK: - Navigation
    
    func goToNextPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MoshafVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
