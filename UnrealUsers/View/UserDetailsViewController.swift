//
//  UserDetailsViewController.swift
//  UnrealUsers
//
//  Created by Oded Golden on 20/10/2020.
//

import UIKit
import CoreData

class UserDetailsViewController: UITableViewController {
    struct ViewData {
        let context: NSManagedObjectContext
        let user: User?
    }

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var phoneTextField: UITextField!
    
    private var data: ViewData?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        navigationItem.title = data?.user?.name ?? "New User"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUser))
        
        if let user = data?.user {
            nameTextField.text = user.name
            imageView.image = UIImage(data: user.imageData!)
            imageView.layer.cornerRadius = 20
            emailTextField.text = user.email
            phoneTextField.text = user.phone
        } else {
            activityIndicatorView.startAnimating()
            let url = URL(string: "https://thispersondoesnotexist.com/image")!
            downloadImage(from: url) { [weak self] (image) in
                self?.imageView.image = image
                self?.imageView.layer.cornerRadius = 20
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    
    private func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        getImageData(from: url) { (data, response, error) in
            guard let data = data,error == nil else { return }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
    }
    
    @objc private func saveUser() {
        guard let context = data?.context,
              let name = nameTextField.text,
              let phone = phoneTextField.text,
              let email = emailTextField.text,
              let image = imageView.image else {
            return
        }
        
        let userToSave = data?.user ?? User(context: context)
        userToSave.name = name
        userToSave.phone = phone
        userToSave.email = email
        userToSave.imageData = image.jpegData(compressionQuality: 0.5)
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            fatalError("Core Data could not save")
        }
    }

}

extension UserDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
