//
//  ViewController.swift
//  Library_API_Case_Study
//
//  Created by Anthony Rubin on 4/12/19.
//  Copyright © 2019 Anthony Rubin. All rights reserved.
//

import UIKit
import CoreData
class ViewController:   UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let presenter = LibraryPresenter()
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //imported Json data
    var bookArray: [doc] = []
    
    var coreDataBooks = [Item]()
    //variable used by searchBar method
    //executes X seconds after last user input from keyboard
    //var timer:Timer?
    override func viewWillAppear(_ animated: Bool) {
        searchFunction()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BeginSearch.png")
        self.tableView.backgroundView = imageView
        self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
        //set the userdefaults for the settings page
        if(UserDefaults.standard.object(forKey: "0")==nil){
            for i in 0..<7{
                if(i==0){
                    UserDefaults.standard.set(true, forKey: "\(i)")
                }else{
                    UserDefaults.standard.set(false, forKey: "\(i)")
                }
            }
        }
    }
  //**Segue to Detail View Controller
   
    //send data over to our detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toDetail"{
            let DestVC = segue.destination as! DetailViewController
            if(tabBar.selectedSegmentIndex == 0){
                let book = bookArray[(indexPath?.row)!]
                DestVC.TitleName = book.title_suggest
                print("book title suggest is " + "\(book.title_suggest)")
                DestVC.subtitle = book.subtitle
                DestVC.author = book.author_name
                DestVC.cover_i = book.cover_i
                DestVC.publisher = book.publisher
                DestVC.author_alternative_name = book.author_alternative_name
                DestVC.publishDate = book.first_publish_year
                DestVC.addToWishListTextOn = true
                DestVC.internetArchive = internetArchives(input: book.ia)
            }else{
                let book = coreDataBooks[(indexPath?.row)!]
                DestVC.TitleName = book.title_suggest
                DestVC.subtitle = book.subtitle
                if(book.author != nil){
                DestVC.author = [book.author!]
                }
                if(book.author_alternative_name != nil){
                  DestVC.author_alternative_name = [book.author_alternative_name!]
                }
                if(book.publisher != nil){
                 DestVC.publisher = [book.publisher!]
                }
                DestVC.cover_i = Int(book.cover_i)
                DestVC.publishDate = Int(book.publishDate)
                DestVC.addToWishListTextOn = false
                if(book.ia != nil){
                 DestVC.internetArchive = internetArchives(input: [book.ia!])
                }
            }
        }
    }
    //takes an array of internet archive links and turns it into a single string,
    //each array entry is separated by a new line \n
    func internetArchives(input: [String]?) -> String{
       var result = ""
        if input != nil {
            for i in input!{
                result += i + "\n"
            }
        }
   return result
    }
    
    //Tab Bar Method (Toggle between wishlist and Search)
    //reload table view data after each switch
    @IBAction func tabBar(_ sender: UISegmentedControl) {
        if(tabBar.selectedSegmentIndex == 0){
            searchBar.isHidden = false
            if(searchBar.text?.count == 0 || searchBar.text == nil){
                let imageView = UIImageView()
                imageView.image = UIImage(named: "BeginSearch.png")
                self.tableView.backgroundView = imageView
                self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            }else{
            self.tableView.backgroundView = nil
            }
        }else if(tabBar.selectedSegmentIndex == 1){
            searchBar.isHidden = true
            fetchCoreData()
        }
        tableView.reloadData()

    }
    
    //A helper function to fetch Core Data and update the UI if necessary
    func fetchCoreData(){
        presenter.fetchData { (items) in
            self.coreDataBooks = items
            if(items.count < 1){
               // searchBar.isHidden = true
                searchBar.resignFirstResponder()
                let imageView = UIImageView()
                imageView.image = UIImage(named: "emptyWishlist.png")
                self.tableView.backgroundView = imageView
                self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            }else{
                //searchBar.isHidden
                tableView.backgroundView = nil
            }
        }
    }
    
    //This runs a search with the given url and returns the parsed JSON
    //on the table view
    func searchFunction(){
    presenter.searchBooks(keyword: searchBar.text!,
    emptyCompletion: {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "BeginSearch.png")
    self.tableView.backgroundView = imageView
    self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
    bookArray = []
    tableView.reloadData()
    }, searchCompletion: { object in
    self.bookArray = object.docs
    if(self.bookArray.count == 0){
    let imageView = UIImageView()
    imageView.image = UIImage(named: "noResults.png")
    self.tableView.backgroundView = imageView
    self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
    }else{
    self.tableView.backgroundView = nil
    }
    self.tableView.reloadData()
    })
    }
    
//The next two functions pretain to the searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFunction()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
 //Standard Table View Functions
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(tabBar.selectedSegmentIndex == 0){
      return bookArray.count
    }
    return coreDataBooks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        //if 0, we are in search mode
        if(tabBar.selectedSegmentIndex == 0){
            let book = bookArray[indexPath.row]
            cell.initilaization(title: book.title_suggest, author: book.author_name, publishDate: book.first_publish_year, cover_i: book.cover_i)
            
        }
        else{
            let book = coreDataBooks[indexPath.row]
            var tempAuthorArray: [String] = []
            if let author = book.author {
             tempAuthorArray.append(author)
            }
            
            cell.initilaization(title: book.title_suggest, author: tempAuthorArray, publishDate: Int(book.publishDate), cover_i: Int(book.cover_i))
            //cell.indexPath = indexPath
            //cell.segmentedControl = 1
        }
        return cell
    }
    
    
//These three functions handle cell deletion**
//To delete a cell you must swipe the cell left
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete"){  (action, indexPath) in
                self.deleteData(indexPath: indexPath)
            self.fetchCoreData()
                tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(tabBar.selectedSegmentIndex == 1){
         return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}


//**Extsion to handle fetching and deleting Core Data
extension ViewController{
    func deleteData(indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(coreDataBooks[indexPath.row])
        do{
            try managedContext.save()
            tableView.reloadData()
        }catch{
            print("could not save updated data")
        }
    }

}
