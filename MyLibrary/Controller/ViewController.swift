//
//  ViewController.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/28/18.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var bookList: UITableView!
    @IBOutlet weak var bookGrid: UICollectionView!
    @IBOutlet weak var segmetedControl: UISegmentedControl!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var booksData = [Book]()
    var selectedBook : Book!
    var isListView : Bool!
    var listButton : UIBarButtonItem!
    var gridButton : UIBarButtonItem!
    var sortCriteria : String!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listButton = UIBarButtonItem(image: UIImage(named: "list"), style: .plain, target: self, action: #selector(changeView))
        listButton.tintColor = UIColor.white
        gridButton =  UIBarButtonItem(image: UIImage(named: "grid"), style: .plain, target: self, action: #selector(changeView))
        gridButton.tintColor = UIColor.white
        segmetedControl.addTarget(self, action: #selector(sortCriteriaChanged), for:.valueChanged)
        isListView = UserDefaults.standard.bool(forKey: "isListView")
        sortCriteria = UserDefaults.standard.string(forKey: "sortCriteria")
        
        if(isListView) {
            self.view.bringSubviewToFront(bookList)
            bookList.reloadData()
            self.navigationItem.leftBarButtonItem = listButton
        }
        else {
            self.view.bringSubviewToFront(bookGrid)
            bookGrid.reloadData()
            self.navigationItem.leftBarButtonItem = gridButton
        }
        
        switch sortCriteria {
        case "Title":
            segmetedControl.selectedSegmentIndex = 0
        case "Author":
            segmetedControl.selectedSegmentIndex = 1
        default:
            segmetedControl.selectedSegmentIndex = 0
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    // MARK: - Button Actions
    
    @objc func sortCriteriaChanged() {
        if segmetedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.set("Title", forKey: "sortCriteria")
            sortCriteria = "Title"
        }
        else {
            sortCriteria = "Author"
            UserDefaults.standard.set("Author", forKey: "sortCriteria")
        }
        sortWithKey(key: sortCriteria)
    }
    
    @objc func changeView() {
        isListView = !isListView
        UserDefaults.standard.set(isListView, forKey: "isListView")
        UserDefaults.standard.synchronize()
        if(isListView) {
            self.view.bringSubviewToFront(bookList)
            bookList.reloadData()
            self.navigationItem.leftBarButtonItem = listButton
        }
        else {
            self.view.bringSubviewToFront(bookGrid)
            bookGrid.reloadData()
            self.navigationItem.leftBarButtonItem = gridButton
        }
    }
    
    
    // MARK: - TableView Datasource and Delegate Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// return airport.count
        return booksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BookListCell = tableView.dequeueReusableCell(withIdentifier: "bookListCell", for: indexPath) as! BookListCell
        
        cell.selectionStyle = .none
        cell.title.text = (booksData[indexPath.row] as Book).title
        cell.authors.text = (booksData[indexPath.row] as Book).authors
        cell.publisher.text = (booksData[indexPath.row] as Book).publisher
        cell.icon.image = UIImage(data: (booksData[indexPath.row] as Book).thumbnail! as Data)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 100
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return UITableView.automaticDimension
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook =  booksData[indexPath.row]
        performSegue(withIdentifier: "bookDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(self.booksData[indexPath.row])
            self.booksData.remove(at: indexPath.row)
            do {
                try context.save()
            } catch { }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if booksData.isEmpty {
                self.bookList.isHidden = true
                self.bookGrid.isHidden = true
            }
        }
    }
    
    // MARK: - CollectionView Datasource and Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksData.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookGridCell", for: indexPath)  as! BookGridCell
        cell.icon.image = UIImage(data: (booksData[indexPath.row] as Book).thumbnail! as Data)
        cell.title.text = (booksData[indexPath.row] as Book).title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.view.frame.size.width - 60)/2
        return CGSize(width: cellWidth, height: (cellWidth*3)/2);
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBook =  booksData[indexPath.item]
        performSegue(withIdentifier: "bookDetailsSegue", sender: self)
    }
    
    // MARK: - Core Data Fetch
    
    func fetchData() {
        do {
            booksData = try context.fetch(Book.fetchRequest())
            if(booksData.isEmpty) {
                self.bookList.isHidden = true
                self.bookGrid.isHidden = true
            }
            else {
                self.bookList.isHidden = false
                self.bookGrid.isHidden = false
            }
            self.sortWithKey(key: sortCriteria)
        } catch { }
    }
    
    func sortWithKey(key : String) {
        switch key {
        case "Title":
            booksData = booksData.sorted { $0.title?.localizedCaseInsensitiveCompare($1.title ?? "") == ComparisonResult.orderedAscending }
        case "Author":
            booksData = booksData.sorted { $0.authors?.localizedCaseInsensitiveCompare($1.authors ?? "") == ComparisonResult.orderedAscending }
        default:
            booksData = booksData.sorted { $0.title?.localizedCaseInsensitiveCompare($1.title ?? "") == ComparisonResult.orderedAscending }
        }
        self.bookGrid.reloadData()
        self.bookList.reloadData()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "bookDetailsSegue" {
            let vc = segue.destination as!  DetailViewController
            vc.selectedBook = self.selectedBook
            vc.isNewBook = false
        }
    }
    
}


