//
//  settingsView.swift
//  Library_API_Case_Study
//
//  Created by Anthony Rubin on 4/14/19.
//  Copyright © 2019 Anthony Rubin. All rights reserved.
//

import Foundation
import UIKit
class searchSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //The names of each of the categories in settings
    var searchTypes = ["Relevance", "Most Editions", "First Published", "Most Recent", "By Title", "By Author"]
  
    
    //**tuples
   //**Value is false if url_endings[x] is to be postfixed to the end of another url
   //**Value is true if url_endings[x] is to be prefixed before search word
    var url_endings = [("&mode=everything",false), ("&sort=editions&mode=everything",false), ("&sort=old&mode=everything",false), ("&sort=new&mode=everything",false), ("https://openlibrary.org/search.json?title=", true), ("https://openlibrary.org/search.json?author=", true)]
    
    //**Basic table view initialization 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! settingsCell
      
        cell.wordGroupSwitch.isOn = isSwitchOn(at: indexPath.row)
        cell.wordLabel.text = searchTypes[indexPath.row]
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.switchChanged = { [weak self] isOn in
            self?.wordGroup(at: indexPath.row , changedTo: isOn)
        }
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    
    //Function to do any error checking on the settings page
    //Since the settings page always needs to have exactly 1
    //switch selected at any given time
    func wordGroup(at index: Int, changedTo value: Bool) {
        let numberOfGroupsTurnedOn = Array(0..<7).map {
            isSwitchOn(at: $0)
            }.filter { $0 }.count
        
        if  (value == true) {
            //display a message
            for i in 0..<7{
                if(UserDefaults.standard.bool(forKey: "\(i)") == true && i != index){
                    UserDefaults.standard.set(false, forKey: "\(i)")
                }
            }
            UserDefaults.standard.set(value, forKey: "\(index)")
            UserDefaults.standard.synchronize()
            tableView.reloadData()
        }
        if  (value == false) {
            //display a message
            let alertController = UIAlertController(title: "Error", message: "you must select one search option", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { [weak self]  _ in
                self?.tableView.reloadData()
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {  }
            }
    }
    
    //helper function
    func isSwitchOn(at index: Int) -> Bool {
        return UserDefaults.standard.value(forKey: "\(index)") as? Bool ?? true
    }
    
    
}
