//
//  DocumentsListController.swift
//  PDF Reader
//
//  Created by Prateek Sharma on 13/04/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class DocumentsListController: UIViewController {
    
    var pdfFilesNames = [String]()
    
    @IBOutlet weak var tableView : UITableView!
    
    private let documentsDirectory : URL? = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async(execute: { [weak self] in
            self?.getPDFfiles()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdfAdded(_:)), name: NSNotification.Name(rawValue: "PDF_ADDED"), object: nil)
        
    }
    
    
    @objc func pdfAdded(_ notification : Notification){
        
        if let userInfo = notification.userInfo as? [String : String] {
            if let fileName = userInfo["fileName"] {
                pdfFilesNames.append(fileName)
                tableView.insertRows(at: [IndexPath(row: pdfFilesNames.count-1, section: 0)], with: .top)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func getPDFfiles(){
        let fileManager = FileManager.default
        
        if let docDirectory = documentsDirectory {
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: docDirectory.path)
                
                pdfFilesNames.removeAll()
                
                for fileName in files {
                    if let ext = fileName.components(separatedBy: ".").last {
                        if ext == "pdf" {
                            pdfFilesNames.append(fileName)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.tableView.reloadData()
                })
            }
            catch {
                print(error)
            }
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "readDocument" {
            
            if let destinationVC = segue.destination as? DocumentReadController , let bookName = sender as? String {
                destinationVC.bookName = bookName
            }
            
        }
    }
    

}

extension DocumentsListController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "readDocument", sender: pdfFilesNames[indexPath.row])
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdfFilesNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = pdfFilesNames[indexPath.row]
        return cell
    }
    
}
