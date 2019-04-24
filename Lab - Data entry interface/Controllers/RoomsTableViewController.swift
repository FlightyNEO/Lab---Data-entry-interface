//
//  RoomsTableViewController.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 24/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import UIKit

protocol RoomsTableViewControllerDelegate: class {
    func didChangeRoom(_ room: RoomType)
}

class RoomsTableViewController: UITableViewController {
    
    // MARK: ... Private properties
    private var rooms = RoomType.all
    var selectedIndexPath: IndexPath?
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_US")
        
        return formatter
    }
    
    // MARK: ... Properties
    weak var delegate: RoomsTableViewControllerDelegate?
    var idRoom: Int = -1 {
        didSet {
            if idRoom >= 0 {
                selectedIndexPath = IndexPath(row: idRoom, section: 0)
                delegate?.didChangeRoom(rooms[idRoom])
            }
        }
    }
    
    // MARK: ... Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        let room = rooms[indexPath.row]
        
        cell.textLabel?.text = rooms[indexPath.row].name
        
        cell.detailTextLabel?.text = currencyFormatter.string(from: rooms[indexPath.row].price as NSNumber)
        
        //cell.detailTextLabel?.text = String(rooms[indexPath.row].price)
        
        cell.accessoryType = room.id == idRoom ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPaths = [(selectedIndexPath ?? nil), indexPath].compactMap { $0 }
        let room = rooms[indexPath.row]
        
        idRoom = room.id
        tableView.reloadRows(at: indexPaths, with: .automatic)
        
        selectedIndexPath = indexPath
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select room"
    }
    
}

// MARK: - Navigation
extension RoomsTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
}
