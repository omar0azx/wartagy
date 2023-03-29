//
//  ViewController.swift
//  وارتقِ
//
//  Created by omar on 26/08/1444 AH.
//

import UIKit
import Speech
import AVFoundation

class MoshafVC: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lb_speech: UILabel!

    @IBOutlet weak var btn_start: UIButton!
    
    @IBOutlet var pointsView: [UIView]!
    
    
    //MARK: - Audio
    
    var audioPlayer : AVAudioPlayer!
    var selectedSoundFileName : String = ""
    let quranArray = ["البسملة", "الاولى", "الثانية", "الثالثة", "الرابعة"]
    let tafsserArray = ["تفسير1", "تفسير2", "تفسير3", "تفسير4"]
    
    //MARK: - Speech Recognizer
    
    let audioEngine = AVAudioEngine()
    let speechReconizer : SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ar"))
    var request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    
    //MARK: - Varibles
    
    var text = ""
    var num = 0
    var isStart : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.selectedSoundFileName = "تعليمات"
            self.playSound()
        }
        
        
    }
    
    //MARK: IBAction
    
    @IBAction func btn_start_stop(_ sender: Any) {
        reading()
        btn_start.setTitle("توقف", for: .normal)
        btn_start.backgroundColor = .systemGreen
        if num > 1 {
            pointsView[num - 1].backgroundColor = .clear
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
    
    //MARK: Start and stop speech recognization

    func startSpeechRecognization(){
        let node = audioEngine.inputNode
               let recordingFormat = node.outputFormat(forBus: 0)
               node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                   self.request.append(buffer)
               }

               audioEngine.prepare()
               do {
                   try audioEngine.start()
               }
               catch {
                //   self.sendAlert(message: "There has been an audio engine error.")
                   return print (error)
               }

               guard let myRecognizer = SFSpeechRecognizer() else
               {
                  // self.sendAlert(message: "Speech recognition is not supported for your current locale.")
                   return
               }

               if !myRecognizer.isAvailable
               {
                 //  self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
                   return
               }

               task = speechReconizer?.recognitionTask(with: request, resultHandler:
               { result, error in
                   if result != nil
                   {
                       if let result = result
                       {
                           let bestString = result.bestTranscription.formattedString
                           self.lb_speech.text = bestString
                           self.text = bestString
                       }

                       else if let error = error
                       {
                     //      self.sendAlert(message: "There has been a speech recognition error.")
                           print(error)
                       }
                   }
               })
        }
    

    func cancelSpeechRecognization() {
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
      //  audioEngine.inputNode.removeTap(onBus: 0)
        
       // MARK: UPDATED
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
    }
    
    //MARK: FUNCTION
    
    func reading() {

            switch num {
            case 0:
                selectedSoundFileName = quranArray[num]
                playSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [self] in
                    num = 1
                    reading()
                }
            case 1:
                displayAudio(aya: "‏قل هو الله أحد", number: 1, timeForTafsser: 5)
            case 2:
                displayAudio(aya: "‏الله الصمد", number: 2, timeForTafsser: 5)
            case 3:
                displayAudio(aya: "‏لم يلد ولم يولد", number: 3, timeForTafsser: 6.5)
            case 4:
                displayAudio(aya: "‏ولم يكن له كفوا أحد", number: 4, timeForTafsser: 4)
            default:
                print("error")
            }
    }
    
    func displayAudio(aya: String, number: Int, timeForTafsser: Double) {
        
        selectedSoundFileName = quranArray[number]
        playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                startSpeechRecognization()
            UIView.animate(withDuration: 0.7, delay: 0, options: .repeat) {
                self.btn_start.backgroundColor = .systemBrown
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [self] in
                UIView.animate(withDuration: 0) {
                    self.btn_start.backgroundColor = .systemGreen
                }
                cancelSpeechRecognization()
                if text == "‏فسر" {
                    selectedSoundFileName = tafsserArray[number - 1]
                    playSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeForTafsser) { [self] in
                        reading()
                    }
                } else if text == "‏قف" || text == "‏توقف" || text == "‏حسبك" {
                    audioPlayer.stop()
                    btn_start.setTitle("إبدا", for: .normal)
                    btn_start.backgroundColor = .systemBrown
                    pointsView[num - 1].backgroundColor = .systemBrown
                } else if text == aya {
                    if number == 4 {
                        num = 0
                        btn_start.setTitle("إبدا", for: .normal)
                        btn_start.backgroundColor = .systemBrown
                        return
                    }
                    num = number + 1
                    reading()
                } else {
                    reading()
                }
            }
        }
    }
    
}

