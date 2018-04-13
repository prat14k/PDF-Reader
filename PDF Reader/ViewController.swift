//
//  ViewController.swift
//  PDF Reader
//
//  Created by Prateek Sharma on 08/04/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import WebKit
import PDFKit
import Speech



enum Txt2SpeechState {
    case playing
    case paused
    case notPlaying
}


class ViewController: UIViewController {

    let bookName2 = "core-ios-developer"
    let bookName = "StanfordLecture11"
    
    let bookExtention = "pdf"
    
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var stopAction: UIBarButtonItem!
    @IBOutlet weak var playAction: UIBarButtonItem!
    @IBOutlet weak var pauseAction: UIBarButtonItem!
    
    private var state : Txt2SpeechState = .notPlaying
    
    var totalUtterance : Int = 0
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var pdfDoc : PDFDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopAction.isEnabled = false
        pauseAction.isEnabled = false
        toolbar.isHidden = true
        loadPDF()
    }
    
    
    @IBAction func readAction(_ sender: UIBarButtonItem) {
        
        let alertView = UIAlertController(title: "Read Page", message: "Enter the page number you want to dictate", preferredStyle: .alert)
        
        alertView.addTextField { (textField) in
            textField.placeholder = "Page number"
            textField.keyboardType = .numberPad
        }
        
        alertView.addAction(UIAlertAction(title: "Play", style: .default, handler: { [weak self] (action) in
            if let page = alertView.textFields?.first?.text {
                if let pageNum = Int(page) {
                    
                    self?.state = .playing
                    self?.playAction.isEnabled = false
                    self?.pauseAction.isEnabled = true
                    self?.stopAction.isEnabled = true
                    self?.toolbar.isHidden = false
                    
                    if !(self?.speechSynthesizer.isSpeaking)! {
                        
                        if let textParagraphs = self?.readPage(pageNum) {
                            self?.totalUtterance = textParagraphs.count
                            
                            for paragraph in textParagraphs {
                                let speechUtterance = AVSpeechUtterance(attributedString: paragraph)
                                let voice = AVSpeechSynthesisVoice(language: "en-EN")
                                speechUtterance.voice = voice
                                
                                self?.speechSynthesizer.speak(speechUtterance)
                            }
                        }
                    }

                }
            }
        }))
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func readPage(_ num : Int) -> [NSAttributedString] {
        
        if pdfDoc == nil {
            if let bookPath = Bundle.main.path(forResource: bookName, ofType: bookExtention) {
                let bookURL = URL(fileURLWithPath: bookPath)
                if let pdf = PDFDocument(url: bookURL) {
                    pdfDoc = pdf
                }
                else {
                    showAlertView(withMessage: "Unable To load the pdf")
                    return []
                }
            }
            else {
                showAlertView(withMessage: "Unable To find the pdf")
                return []
            }
        }
        
        
        if (pdfDoc?.pageCount)! < num || num < 1 {
            return []
        }
        
        var pageSplittedContent = [NSAttributedString]()
        guard let page = pdfDoc?.page(at: (num - 1)) else { return [] }
        guard let pageContent = page.attributedString else { return [] }
        
        let pageString = pageContent.string
        
        let splittedStringArray = pageString.components(separatedBy: "\n")
        
        var start = 0
        
        for paragraph in splittedStringArray {
            let range = NSMakeRange(start, paragraph.count)
            
            let attributedString = pageContent.attributedSubstring(from: range)
            pageSplittedContent.append(attributedString)
            
            start = start + range.length + "\n".count
        }
        
        return pageSplittedContent
    }
    
    
    func showAlertView(withMessage message : String) {
        
        let alertView = UIAlertController(title: "Error occured", message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func readBook(){
        if let bookPath = Bundle.main.path(forResource: bookName, ofType: bookExtention) {
            
            let bookURL = URL(fileURLWithPath: bookPath)
            
            
            if let pdf = PDFDocument(url: bookURL) {
                
                let pageCount = pdf.pageCount
                
                print(pageCount)
                
                let documentContent = NSMutableAttributedString()
                
                for i in 1 ..< pageCount {
                    guard let page = pdf.page(at: i) else { continue }
                    guard let pageContent = page.attributedString else { continue }
                    
                    print(pageContent)
                    print(" ")
                    print(pageContent.string)
                    print(" ")
                    print(" ")
                    
                    documentContent.append(pageContent)
                }
                
            }
            
        }
        
    }
    
    func loadPDF(){
        if let bookPath = Bundle.main.path(forResource: bookName, ofType: bookExtention) {
            let bookURL = URL(fileURLWithPath: bookPath)
            webView.load(URLRequest(url: bookURL))
        }
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
        
        toolbar.isHidden = true
    }
    
    @IBAction func playSpeech(_ sender : UIBarButtonItem) {
        
        if state == .playing {
            return
        }
        
        state = .playing
        playAction.isEnabled = false
        pauseAction.isEnabled = true
        stopAction.isEnabled = true
        
//        if !self.speechSynthesizer.isSpeaking {
//
//            let textParagraphs = self.textView.text.components(separatedBy: "\n")
//            totalUtterance = textParagraphs.count
//
//            for paragraph in textParagraphs {
//                let speechUtterance = AVSpeechUtterance(string: paragraph)
//                let voice = AVSpeechSynthesisVoice(language: "en-EN")
//                speechUtterance.voice = voice
//
//                self.speechSynthesizer.speak(speechUtterance)
//            }
//
//        }
//        else{
            self.speechSynthesizer.continueSpeaking()
//        }
        
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

