//
//  SearchViewController.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/29/18.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bookList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var booksArray = [BookModel]()
    var selectedBook : BookModel!
    var searchCriteria = "intitle"
    var connectionManager = ConnectionManager()
    var cache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookList.estimatedRowHeight = 120
        searchBar.scopeButtonTitles = ["Title","Author","Publisher","ISBN"]
        searchBar.becomeFirstResponder()
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - TableView Datasource and Delegate Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BookListCell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookListCell
        
        cell.selectionStyle = .none
        let bookItem = booksArray[indexPath.row]
        cell.icon.image = UIImage(named: "placeholder")
        cell.title.text = bookItem.title
        cell.authors.text = bookItem.authors
        cell.publisher.text = bookItem.publisher
        let id = bookItem.id ?? "\(indexPath.row)"
        if let thumbnail = bookItem.thumbnail {
            if (self.cache.object(forKey: id as AnyObject) != nil){
                cell.icon.image = self.cache.object(forKey: id as AnyObject) as? UIImage
            }
            else {
                connectionManager.downloadImage(imgURL: thumbnail, completion: {
                    (img) -> Void in
                    cell.icon.image = img
                    self.cache.setObject((img), forKey: id as AnyObject)
                })
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook =  booksArray[indexPath.row]
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "newBookDetailsSegue", sender: self)
    }
    
    // MARK: - JSON Parsing
    
    func parseJsonData(results : NSDictionary) {
        if let total = results["totalItems"] as? NSNumber {
            let totalCount = total.intValue
            if(totalCount > 0) {
                let itemsArray = results["items"] as! NSArray
                for i in 0..<itemsArray.count {
                    if let bookItem = itemsArray[i] as? NSDictionary {
                        let book = BookModel()
                        if let volumeInfo = bookItem["volumeInfo"] as? NSDictionary {
                            if let bookTitle = volumeInfo["title"] as? String {
                                book.title = bookTitle
                            }
                            if let bookAuthors = volumeInfo["authors"] as? [String] {
                                book.authors = bookAuthors.joined(separator:", ")
                            }
                            if let publisher = volumeInfo["publisher"] as? String {
                                book.publisher = publisher
                            }
                            if let publishDate = volumeInfo["publishedDate"] as? String {
                                book.publishedDate = publishDate
                            }
                            if let categories = volumeInfo["categories"] as? [String] {
                                book.categories = categories.joined(separator:", ")
                            }
                            if let description = volumeInfo["description"] as? String {
                                book.bookDesc = description
                            }
                            if let pageCount = volumeInfo["pageCount"] as? NSNumber {
                                book.pageCount = pageCount.stringValue
                            }
                            if let previewLink = volumeInfo["previewLink"] as? String {
                                book.previewLink = previewLink
                            }
                            if let imgLinks = volumeInfo["imageLinks"] as? NSDictionary {
                                if let thumbnail = imgLinks["thumbnail"] as? String {
                                    book.thumbnail = thumbnail
                                }
                            }
                        }
                        if let id = bookItem["id"] as? String {
                            book.id = id
                        }
                        booksArray.append(book)
                    }
                }
            }
            else {
                showAlert(withTitle: "", andMessage: "No books found")
            }
        }
        bookList.reloadData()
    }
    
    // MARK: - Alert Message
    
    func showAlert(withTitle title : String, andMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Refine search
    
    func refineSearch(_ searchBar: UISearchBar) {
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        switch scopeString {
        case "Title":
            searchCriteria = "intitle"
        case "Author":
            searchCriteria = "inauthor"
        case "Publisher":
            searchCriteria = "inpublisher"
        case "ISBN":
            searchCriteria = "isbn"
        default:
            searchCriteria = "intitle"
        }
    }
    
    // MARK: - dismiss View Controller
    
    @IBAction func dismissSearch(_ sender: Any) {
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "newBookDetailsSegue" {
            let vc = segue.destination as!  DetailViewController
            vc.selectedNewBook = self.selectedBook
            vc.isNewBook = true
        }
    }
    
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        refineSearch(searchBar)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text?.isEmpty)!
        { return }
        
        searchBar.resignFirstResponder()
        booksArray.removeAll()
        waitIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        connectionManager.requestGetAPIService(searchString: searchBar.text!, criteria: searchCriteria, success: { (jsonResult) -> Void in
            DispatchQueue.main.async {
                self.waitIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.parseJsonData(results: jsonResult)
            }
        }
            ,
                                               failure: { (errMsg) -> Void in
                                                DispatchQueue.main.async {
                                                    self.waitIndicator.stopAnimating()
                                                    self.view.isUserInteractionEnabled = true
                                                    self.booksArray.removeAll()
                                                    self.cache.removeAllObjects()
                                                    self.bookList.reloadData()
                                                    self.showAlert(withTitle: "Error", andMessage: errMsg)
                                                }
        })
    }
    
}

