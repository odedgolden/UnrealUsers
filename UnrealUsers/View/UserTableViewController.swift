//
//  UserTableViewController.swift
//  UnrealUsers
//
//  Created by Oded Golden on 20/10/2020.
//

import UIKit
import CoreData

class UserTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    private var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 50
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    @IBOutlet var addBarButtonItem: UIBarButtonItem!
    @IBOutlet var deleteBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Users"
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
      
        
        deleteBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItems = [addBarButtonItem, deleteBarButtonItem]
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Core Data fetch error.")
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addBarButtonItem.isEnabled = !editing
        deleteBarButtonItem.isEnabled = editing
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let user = fetchedResultsController.object(at: indexPath)
        let userImage: UIImage?
        if let imageData = user.imageData {
            userImage = UIImage(data: imageData)
        } else {
            userImage = nil
        }
        cell.configure(data: .init(image: userImage, userName: user.name ?? ""))
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let user = fetchedResultsController.object(at: indexPath)
            context.delete(user)
            try? context.save()
        case .insert, .none:
            break
        @unknown default:
            print("Unknown table view edit.")
        }
    }
    
    // MARK: Fetched results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // Navigation
    
    @IBSegueAction func showDetails(_ coder: NSCoder) -> UserDetailsViewController? {
        var user: User?
        if let indexPath = tableView.indexPathForSelectedRow{
            user = fetchedResultsController.object(at: indexPath)
        } else {
            user = nil
        }
        let userDetailsViewController = UserDetailsViewController(coder: coder)
        userDetailsViewController?.inject(data: .init(context: context, user: user))
        return userDetailsViewController
    }
    

    
    @IBSegueAction func showNewUser(_ coder: NSCoder) -> UserDetailsViewController? {
        let userDetailsViewController = UserDetailsViewController(coder: coder)
        userDetailsViewController?.inject(data: .init(context: context, user: nil))
        return userDetailsViewController

    }
}
