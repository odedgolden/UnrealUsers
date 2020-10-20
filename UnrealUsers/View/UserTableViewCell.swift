//
//  UserTableViewCell.swift
//  UnrealUsers
//
//  Created by Oded Golden on 20/10/2020.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    struct ViewData {
        let image: UIImage?
        let userName: String
    }
    
    @IBOutlet private var userImageView: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView?.layer.cornerRadius = userImageView.bounds.height/2
    }
    
    func configure(data: ViewData){
        userImageView.image = data.image ?? UIImage(systemName: "peron.fill")
        userNameLabel.text = data.userName
    }
}
