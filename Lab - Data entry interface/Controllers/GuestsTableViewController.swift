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
    
    private var rows = [[Registration]]()
    private var sections = [Date]()
    
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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        
        return formatter
    }()
    
    private lazy var sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM YYYY"
        
        return formatter
    }()
    
    // MARK: ... Calculated properties
    private var registrations: [Registration] {
        return rows.flatMap { $0 }
    }
    
    // MARK: ... Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        updateSections(with: Registration.sampleLoad())
        
    }
    
    // MARK: ... Private methods
    private func fillDetailController(_ controller: AddRegistrationTableViewController, registration: Registration?, title: String?, isEditable: Bool, canEditing: Bool) {
        controller.registration = registration
        controller.title = title
        controller.isEditable = isEditable
        controller.canEditing = canEditing
    }
    
    private func configureCell(_ cell: UITableViewCell, registration: Registration) {
        let attributedText = createAttributedDatesString(fromDate: registration.checkInDate, toDate: registration.checkOutDate)
        
        cell.textLabel?.text = registration.owner.fulName
        cell.detailTextLabel?.attributedText = attributedText
        
    }
    
    private func createAttributedDatesString(fromDate: Date, toDate: Date) -> NSMutableAttributedString {
        
        let fromDateString = dateFormatter.string(from: fromDate)
        let toDateString = dateFormatter.string(from: toDate)
        let datesString = fromDateString + " - " + toDateString
        
        if fromDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 {
            var range: NSRange
            
            if toDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 {
                range = (datesString as NSString).range(of: datesString)
            } else {
                range = (datesString as NSString).range(of: fromDateString)
            }
            
            let attributedText = NSMutableAttributedString(string: datesString)
            attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: range)
            
            return attributedText
        }
        
        return NSMutableAttributedString(string: datesString)
    }
    
    private func updateSections(with registrations: [Registration]) {
        
        var rows = [[Registration]]()
        
        let dates = registrations.reduce(into: [Date]()) { (result, reg) in
            guard let lastDate = result.last else {
                result.append(reg.checkInDate)
                rows.append([reg])
                return
            }
            
            let componentsLastDate = Calendar.current.dateComponents([.month, .year], from: lastDate)
            let componentsDate = Calendar.current.dateComponents([.month, .year], from: reg.checkInDate)
            
            if componentsDate.month != componentsLastDate.month {
                result.append(reg.checkInDate)
                rows.append([reg])
            } else {
                rows[rows.endIndex - 1].append(reg)
            }
            
        }
        
        sections = dates
        self.rows = rows
        
    }

}

// MARK: - Tble view data source & delegate
extension GuestsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let registration = rows[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        configureCell(cell, registration: registration)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDateFormatter.string(from: sections[section])
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            self.editingIndexPath = indexPath
            self.performSegue(withIdentifier: Mode.edit.identifier, sender: indexPath)
        }
        
        editAction.backgroundColor = .orange
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            
            self.rows.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return rows[indexPath.section][indexPath.row].checkInDate.timeIntervalSince1970 > Date().timeIntervalSince1970
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
                
                guard let indexPath = sender as? IndexPath else { return }
                let registration = rows[indexPath.section][indexPath.row]
                fillDetailController(addRegistrationDetailViewController,
                                     registration: registration,
                                     title: "Edit",
                                     isEditable: true,
                                     canEditing: true)
                mode = .edit
                
            case Mode.add.identifier:
                
                fillDetailController(addRegistrationDetailViewController,
                                     registration: nil,
                                     title: "Registration",
                                     isEditable: true,
                                     canEditing: true)
                mode = .add
                
            case Mode.show.identifier:
                
                let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
                let registration = rows[indexPath.section][indexPath.row]
                let canEditing = rows[indexPath.section][indexPath.row].checkInDate.timeIntervalSince1970 > Date().timeIntervalSince1970
                
                fillDetailController(addRegistrationDetailViewController,
                                     registration: registration,
                                     title: nil,
                                     isEditable: false,
                                     canEditing: canEditing)
                mode = .show
                
            default:
                
                break
                
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
            
        case .edit, .show:
            
            guard let editingIndexPath = editingIndexPath else { return }
            rows[editingIndexPath.section].remove(at: editingIndexPath.row)
            fallthrough
            
        case .add:
            
            var registrations = self.registrations
            let indexOfRegistration = registrations.insertionIndexOf(registration, <)
            registrations.insert(registration, at: indexOfRegistration)
            updateSections(with: registrations)
            tableView.reloadData()

        }
        
    }

}
