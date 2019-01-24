//
//  BookListCell.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/29/18.
//

import UIKit

class BookListCell: UITableViewCell {
    
      @IBOutlet weak var icon: UIImageView!
      @IBOutlet weak var title: UILabel!
      @IBOutlet weak var authors: UILabel!
      @IBOutlet weak var publisher: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
