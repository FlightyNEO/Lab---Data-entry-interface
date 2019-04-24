//
//  GuestsTableViewController.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 23/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import UIKit

class GuestsTableViewController: UITableViewController {
    
    // MARK: ... Private properties
    private let cellID = "RegistrationCell"
    
    private var registrations = [Registration]()
    
    private var editingIndexPath: IndexPath?
    private var mode: Mode?
    
    private enum Mode {
        case edit, add, show
        
        var identifier: String {
            switch self {
            case .edit: return "EditRegistrationIdentifier"
            case .add: return "AddGuestIdentifier"
            case .show: return "ShowRegistrationIdentifier"
            }
        }
    }
    
    // MARK: ... Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    // MARK: ... Private methods
    private func fillDetailController(_ controller: AddRegistrationTableViewController, registration: Registration?, title: String?, isEditable: Bool, canEditing: Bool) {
        controller.registration = registration
        controller.title = title
        controller.isEditable = isEditable
        controller.canEditing = canEditing
    }

}

// MARK: - Tble view data source & delegate
extension GuestsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let registration = registrations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = registration.owner.fuulName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            self.editingIndexPath = indexPath
            self.performSegue(withIdentifier: Mode.edit.identifier, sender: indexPath.row)
        }
        
        editAction.backgroundColor = .orange
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            
            self.registrations.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return registrations[indexPath.row].checkInDate.timeIntervalSince1970 > Date().timeIntervalSince1970
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editingIndexPath = indexPath
    }
}

// MARK: - Navigation
extension GuestsTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let addRegistrationDetailViewController = segue.destination as? AddRegistrationTableViewController {
            
            
            addRegistrationDetailViewController.delegate = self
            
            switch segue.identifier {
            case Mode.edit.identifier:
                guard let row = sender as? Int else { return }
                let emoji = registrations[row]
                fillDetailController(addRegistrationDetailViewController, registration: emoji, title: "Edit", isEditable: true, canEditing: true)
                mode = .edit
            case Mode.add.identifier:
                fillDetailController(addRegistrationDetailViewController, registration: nil, title: "Registration", isEditable: true, canEditing: true)
                mode = .add
            case Mode.show.identifier:
                guard let row = tableView.indexPathForSelectedRow?.row else { return }
                let emoji = registrations[row]
                let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
                let canEditing = registrations[indexPath.row].checkInDate.timeIntervalSince1970 > Date().timeIntervalSince1970
                fillDetailController(addRegistrationDetailViewController, registration: emoji, title: nil, isEditable: false, canEditing: canEditing)
                mode = .show
            default: break
            }
            
        }
        
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.editingIndexPath = nil
        self.mode = nil
    }
    
}

// MARK: - Emoji detail view controller delegate
extension GuestsTableViewController: RegistrationDetailViewControllerDelegate {
    
    func didUpdateRegistration(_ registration: Registration) {
        
        guard let mode = mode else { return }

        switch mode {
            
        case .add:
            
            let indexOfRegistration = registrations.insertionIndexOf(registration, <)
            let indexPath = IndexPath(row: indexOfRegistration, section: 0)
            registrations.insert(registration, at: indexOfRegistration)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
        case .edit, .show:

            guard let editingIndexPath = editingIndexPath else { return }
            
            registrations[editingIndexPath.row] = registration
            registrations.sort()
            tableView.reloadData()

        }
        
    }

}
