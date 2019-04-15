//
//  LibraryPresenter.swift
//  Library_API_Case_Study
//
//  Created by Anthony Rubin on 4/14/19.
//  Copyright © 2019 Anthony Rubin. All rights reserved.
//

import UIKit
import CoreData
class LibraryPresenter: NSObject {
    var settings = searchSettings()
    
    
    //**Imports JSON data from given URL
    func importJson(url: String, completion: @escaping (BookObject) -> Void){
        let ValidUrl = URL(string: url)
        guard let jsonUrl = ValidUrl else {
            return
        }
        URLSession.shared.dataTask(with: jsonUrl, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            do{
                let object = try JSONDecoder().decode(BookObject.self, from: data)

                print(object)
                DispatchQueue.main.async {
                    completion(object)
                }
            }catch{
                print(error)
            }
        }).resume()
        print("escaping")
    }
    
    func getUrl(rawUrl: String) -> String {
        let url = rawUrl.replacingOccurrences(of: " ", with: "+")
        print("url is " + "\(url)")
        return url
    }
    
    var timer: Timer?
    var searchCompletion: ((BookObject) -> Void)?

    func searchBooks(keyword: String, emptyCompletion: () -> Void, searchCompletion: @escaping (BookObject) -> Void) {
        timer?.invalidate()
        self.searchCompletion = searchCompletion
        if keyword.isEmpty {
            emptyCompletion()
            return
        }
        var url = "https://openlibrary.org/search.json?q=" + "\(keyword)"
        
        //This is where the url is modified depending on the options in settings
        for (i,c) in settings.url_endings.enumerated(){
            if(UserDefaults.standard.bool(forKey: "\(i)") == true){
                if(c.1 == false){
                    url = url + c.0
                }else{
                    url = c.0 + "\(keyword)"
                }
            }
        }
        print("url is " + url)
        let passData = (url: url, completion: searchCompletion)
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(startSearching), userInfo: url, repeats: false)
    }
    
    //**This function will fire once every .35 seconds
    //**Since we dont want to reload json for every button click
    @objc func startSearching() {
        let url = timer!.userInfo as! String
        let finalUrl = getUrl(rawUrl: url)
        guard let completion = searchCompletion else { return }
        importJson(url: finalUrl, completion: completion)
    }
}

//**Fetches Json data
extension LibraryPresenter {
    func fetchData(completion: ([Item]) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do{
            let data = try managedContext.fetch(request) as! [Item]
            completion(data)
        }catch{
            completion([])
        }
    }
    
}
