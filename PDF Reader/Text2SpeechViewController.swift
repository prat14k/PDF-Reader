//
//  Text2SpeechViewController.swift
//  PDF Reader
//
//  Created by Prateek Sharma on 13/04/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import Speech

class Text2SpeechViewController: UIViewController // , SFSpeechRecognizerDelegate
{
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stopAction: UIBarButtonItem!
    @IBOutlet weak var playAction: UIBarButtonItem!
    @IBOutlet weak var pauseAction: UIBarButtonItem!
    
    private var state : Txt2SpeechState = .notPlaying
    
    var totalUtterance : Int = 0
    
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//
//    private let audioEngine = AVAudioEngine()
//
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopAction.isEnabled = false
        pauseAction.isEnabled = false
        
        
        textView.text = "This pilcrow symbol is sometimes used to show where a paragraph begins.\nA paragraph is a group of words put together to form a group that is usually longer than a sentence. Paragraphs are often made up of many sentences. They are usually between four to eight sentences. Paragraphs can begin with an indentation (about five spaces), or by missing a line out, and then starting again; this makes telling when one paragraph ends and another begins easier.\nIn most organized forms of writing, such as essays, paragraphs contain a topic sentence . This topic sentence of the paragraph tells the reader what the paragraph will be about. Essays usually have multiple paragraphs that make claims to support a thesis statement, which is the central idea of the essay.\nA pilcrow mark is sometimes used to show where a paragraph begins.\nParagraphs are important to essays, papers, columns, whatever you are writing. Paragraphs help separate ideas and let the audience know when you change partial topics. Each paragraph has maybe an average of 3 - 7 sentences, depending on the topic and how much information is required."
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
//        speechRecognizer?.delegate = self
//
//        SFSpeechRecognizer.requestAuthorization { (permitStatus) in
//
//            OperationQueue.main.addOperation({ [weak self] in
//                switch permitStatus {
//                case .authorized:
//                    self?.playAction.isUserInteractionEnabled = true
//                default:
//                    self?.playAction.isUserInteractionEnabled = false
//                }
//            })
//
//        }
     
        
        
    }
    
    
    @IBAction func stopSpeech(_ sender : UIBarButtonItem) {
    
        if state == .notPlaying {
            return
        }
        
        state = .notPlaying
        playAction.isEnabled = true
        pauseAction.isEnabled = false
        stopAction.isEnabled = false
        
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    @IBAction func playSpeech(_ sender : UIBarButtonItem) {
        
        if state == .playing {
            return
        }
        
        state = .playing
        playAction.isEnabled = false
        pauseAction.isEnabled = true
        stopAction.isEnabled = true
        
        if !self.speechSynthesizer.isSpeaking {
            
            let textParagraphs = self.textView.text.components(separatedBy: "\n")
            totalUtterance = textParagraphs.count
            
            for paragraph in textParagraphs {
                let speechUtterance = AVSpeechUtterance(string: paragraph)
                let voice = AVSpeechSynthesisVoice(language: "en-EN")
                speechUtterance.voice = voice
                
                self.speechSynthesizer.speak(speechUtterance)
            }
            
        }
        else{
            self.speechSynthesizer.continueSpeaking()
        }
        
    }
    
    @IBAction func pauseSpeech(_ sender : UIBarButtonItem) {
        if state == .paused || state == .notPlaying {
            return
        }
        
        state = .paused
        playAction.isEnabled = true
        pauseAction.isEnabled = false
        stopAction.isEnabled = true
        
        self.speechSynthesizer.pauseSpeaking(at: .immediate)
    }
    
}
