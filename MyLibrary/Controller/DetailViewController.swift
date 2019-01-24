//
//  DetailViewController.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/29/18.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedBook : Book!
    var selectedNewBook : BookModel!
    var details = ["Authors", "Publisher", "Publication Date","Pages","Categories","ISBN","Description"]
    var isNewBook = false
    var authors : String?
    var bookTitle: String?
    var isbn: String?
    var publisher: String?
    var publishedDate: String?
    var bookDesc: String?
    var pageCount: String?
    var previewLink: String?
    var thumbnail: String?
    var id: String?
    var categories: String?
    var connectionManager = ConnectionManager()
    var saveButton : UIBarButtonItem!
    var shareButton : UIBarButtonItem!
    var bookImg = UIImage(named: "placeholder")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isNewBook) {
            authors = selectedNewBook.authors
            bookTitle = selectedNewBook.title
            isbn = selectedNewBook.isbn
            publisher = selectedNewBook.publisher
            publishedDate = selectedNewBook.publishedDate
            bookDesc = selectedNewBook.bookDesc
            pageCount = selectedNewBook.pageCount
            categories = selectedNewBook.categories
            previewLink = selectedNewBook.previewLink
            id = selectedNewBook.id
            saveButton =  UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBook))
            saveButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = saveButton
        }
        else {
            authors = selectedBook.authors
            bookTitle = selectedBook.title
            isbn = selectedBook.isbn
            publisher = selectedBook.publisher
            publishedDate = selectedBook.publishedDate
            bookDesc = selectedBook.bookDesc
            pageCount = selectedBook.pageCount
            categories = selectedBook.categories
            previewLink = selectedBook.previewLink
            id = selectedBook.id
            shareButton =  UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBook))
            shareButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = shareButton
        }
    }
    
    // MARK: - Save and Share Book
    
    @objc func shareBook() {
        if let url = URL(string: previewLink!) {
            let shareItems:Array = [url] as [Any]
            let vc:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            present(vc, animated: true)
        }
        else {
            showAlert(withTitle: "", andMessage: "Link not available")
        }
    }
    
    @objc func saveBook() {
        
        do {
            let booksData : [Book] = try context.fetch(Book.fetchRequest())
            if booksData.contains(where: { $0.id == id }) {
                self.showAlert(withTitle: "", andMessage: "This books already exists in your books list")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "Book", in: context)
                let newBook = NSManagedObject(entity: entity!, insertInto: context) as! Book
                newBook.authors = authors
                newBook.isbn = isbn
                newBook.title = bookTitle
                newBook.publisher = publisher
                newBook.publishedDate = publishedDate
                newBook.bookDesc = bookDesc
                newBook.pageCount = pageCount
                newBook.categories = categories
                newBook.previewLink = previewLink
                newBook.id = id
                if let data:Data = bookImg!.jpegData(compressionQuality: 1.0) {
                    newBook.thumbnail = data
                } else if let data:Data = bookImg?.pngData() {
                    newBook.thumbnail = data
                }
                do {
                    try context.save()
                    let alert = UIAlertController(title: "", message: "Book saved successfully", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default) { action -> Void in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(okButton)
                    self.navigationController!.present(alert, animated: true, completion: nil)
                } catch {
                    showAlert(withTitle: "", andMessage: "Couln not save book. Please try again")
                }
            }
        } catch { }
    }
    
    // MARK: - TableView Datasource and Delegate Metho
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell : BookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailCell
            cell.selectionStyle = .none
            cell.title.text = bookTitle
            if(isNewBook) {
                if let thumbnail = selectedNewBook.thumbnail {
                    connectionManager.downloadImage(imgURL: thumbnail, completion: {
                        (img) -> Void in
                        cell.icon.image = img
                        self.bookImg = img
                    })
                }
            }
            else {
                cell.icon.image = UIImage(data: selectedBook.thumbnail! as Data)
            }
            return cell
        }
        else if (indexPath.row == details.count + 1) {
            let cell : PreviewCell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell", for: indexPath) as! PreviewCell
            cell.previewButton.addTarget(self, action: #selector(openPreview), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = details[indexPath.row-1]
            switch indexPath.row {
            case 1:
                cell.detailTextLabel?.text = authors
            case 2:
                cell.detailTextLabel?.text = publisher
            case 3:
                cell.detailTextLabel?.text = publishedDate
            case 4:
                cell.detailTextLabel?.text = pageCount
            case 5:
                cell.detailTextLabel?.text = categories
            case 6:
                cell.detailTextLabel?.text = isbn
            case 7:
                cell.detailTextLabel?.text = bookDesc
            default:
                break
            }
            return cell
        }
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
    
    // MARK: - Open Preview
    
    @objc func openPreview() {
        if let url = URL(string: previewLink!) {
            UIApplication.shared.open(url)
        }
        else {
            showAlert(withTitle: "", andMessage: "Preview unavailable")
        }
    }
    
    // MARK: - Alert Message
    
    func showAlert(withTitle title : String, andMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
}
