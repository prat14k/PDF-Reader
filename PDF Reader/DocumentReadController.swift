//
//  DocumentReadController.swift
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


class DocumentReadController: UIViewController {

    var bookName : String = ""
    
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
    
    private let documentsDirectory : URL? = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }()
    
    
    
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
                        
                        if let textParagraphs = self?.readPage(pageNum), textParagraphs.count > 0 {
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
    
        self.speechSynthesizer.continueSpeaking()
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


extension DocumentReadController {
    
    func readPage(_ num : Int) -> [NSAttributedString] {
        
        if pdfDoc == nil {
            if let directory = documentsDirectory {
                let pdfFilePath = directory.path.appending("/\(bookName)")
                if FileManager.default.fileExists(atPath: pdfFilePath){
                    let bookURL = URL(fileURLWithPath: pdfFilePath)
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
            else {
                showAlertView(withMessage: "Unable To access the directory")
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

    
    func loadPDF(){
        
        if let directory = documentsDirectory {
            
            let pdfFilePath = directory.path.appending("/\(bookName)")
            
            if FileManager.default.fileExists(atPath: pdfFilePath){
                let bookURL = URL(fileURLWithPath: pdfFilePath)
                webView.loadFileURL(bookURL, allowingReadAccessTo: bookURL)
            }else{
                showAlertView(withMessage: "Unable to find the pdf")
            }
            
        }
        
    }
}



