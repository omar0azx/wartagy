//
//  ViewController.swift
//  وارتقِ
//
//  Created by omar on 26/08/1444 AH.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lb_speech: UILabel!
    @IBOutlet weak var view_color: UIView!
    @IBOutlet weak var btn_start: UIButton!
    
    //MARK: - Audio
    
    var audioPlayer : AVAudioPlayer!
    var selectedSoundFileName : String = ""
    let quranArray = ["البسملة", "الاولى", "الثانية", "الثالثة", "الرابعة"]
    let tafsserArray = ["تفسير1", "تفسير2", "تفسير3", "تفسير4"]
    
    //MARK: - Speech Recognizer
    
    let audioEngine = AVAudioEngine()
    let speechReconizer : SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ar"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    
    //MARK: - Varibles
    
    var text = ""
    var num = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: IBAction
    
    @IBAction func btn_start_stop(_ sender: Any) {
        //MARK:- Coding for start and stop sppech recognization...!
        reading()
        btn_start.setTitle("توقف هنا", for: .normal)
        btn_start.backgroundColor = .systemGreen
        
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

    func startSpeechRecognization() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("Error: ", error.localizedDescription)
        }
        
        node.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat, block: { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.request.append(buffer)
        })
        
        audioEngine.prepare()
        do {
               try audioEngine.start()
           } catch let error {
               print("Error comes here for starting the audio listner = \(error.localizedDescription)")
           }
           
           guard let myRecognization = SFSpeechRecognizer() else { return }

           task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
               guard let response = response else { return }
               
               let message = response.bestTranscription.formattedString
               self.lb_speech.text = message
               self.text = message
               
               
               var lastString: String = ""
               for segment in response.bestTranscription.segments {
                   let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                   lastString = String(message[indexTo...])
               }
               
           })
       }
    

        func cancelSpeechRecognization() {
            task.finish()
            task.cancel()
            task = nil
            
            request.endAudio()
            audioEngine.stop()
            
            //MARK: UPDATED
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
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
            do {
                try! startSpeechRecognization()
            } catch {
                print("error")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [self] in
                cancelSpeechRecognization()
                if text == "‏فسر" {
                    selectedSoundFileName = tafsserArray[number - 1]
                    playSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeForTafsser) { [self] in
                        reading()
                    }
                } else if text == aya {
                    if number == 4 {
                        btn_start.setTitle("إبدا التلآوة", for: .normal)
                        btn_start.backgroundColor = .systemOrange
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

