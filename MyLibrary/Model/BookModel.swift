//
//  BookModel.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/31/18.
//

import UIKit

class BookModel: NSObject {
        var authors: String?
        var title: String?
        var isbn: String?
        var publisher: String?
        var publishedDate: String?
        var bookDesc: String?
        var pageCount: String?
        var previewLink: String?
        var thumbnail: String?
        var id: String?
        var categories: String?
    
    override init() {
        super.init()
    }
}
