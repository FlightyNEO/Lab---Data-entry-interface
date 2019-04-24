//
//  AddRegistrationTableViewController.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 23/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

// Validatr
// https://github.com/gkaimakas/SwiftValidators

import UIKit
import SwiftValidators

protocol RegistrationDetailViewControllerDelegate: class {
    func didUpdateRegistration(_ registration: Registration)
}

class AddRegistrationTableViewController: UITableViewController {
    
    // MARK: ... IBOutlets
    /* navigation items */
    @IBOutlet weak var saveAndCancelButton: UIBarButtonItem!
    @IBOutlet weak var cancelAndBackButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    /* Guest info */
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var eMailTextField: UITextField!
    
    /* Dates */
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    /* Guests */
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfAdultsStepper: UIStepper!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var numberOfChildrenStepper: UIStepper!
    
    /* Wi-Fi */
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    /* Room */
    @IBOutlet weak var roomCell: UITableViewCell!
    
    
    // MARK: ... Private properties
    private enum Mode {
        case review
        case edit(readyToSave: Bool)
    }
    
    private var mode: Mode = .review {
        didSet {
            switch mode {
            case .review:
                editButton?.title = "Edit"
                editButton.style = .plain
                editButton?.isEnabled = true
            case .edit(readyToSave: let isReady):
                editButton?.title = "Save"
                editButton?.style = isReady ? .done : .plain
                editButton?.isEnabled = isReady ? true : false
            }
        }
    }
    
    private var textFields: [UITextField] {
        guard
            firstNameTextField != nil,
            lastNameTextField != nil,
            eMailTextField != nil else { return [] }
        
        return [firstNameTextField, lastNameTextField, eMailTextField]
    }
    
    private var areFieldsReady: Bool {
        
        guard !textFields.isEmpty else { return false }
        
        for textField in textFields {
            if textField.isEmpty { return false }
        }
        
        guard
            Validator.isEmail().apply(eMailTextField.text),
            registration.room != nil else { return false }
        
        return true
    }
    
    private lazy var cancelButton: UIBarButtonItem? = {
        return UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(actionCancel))
    }()
    
    private let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    private let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    private var isCheckInDatePickerShown = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerShown
        }
    }
    
    private var isCheckOutDatePickerShown = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    private var numberOfAdults: Int {
        return Int(numberOfAdultsStepper.value)
    }
    
    private var numberOfChildren: Int {
        return Int(numberOfChildrenStepper.value)
    }
    
    private var selectedIndexPath: IndexPath?
    
    // MARK: ... Properties
    var registration: Registration!
    weak var delegate: RegistrationDetailViewControllerDelegate?
    
    var isEditable = false {
        didSet {
            mode = isEditable ? .edit(readyToSave: true) : .review
            updateUI()
        }
    }
    
    // MARK: ... Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if registration == nil {
            registration = Registration()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: ... Private methods
    @objc private func textDidChange() {
        checkReadyToSave()
    }
    
    private func checkReadyToSave() {
        saveAndCancelButton?.isEnabled = areFieldsReady
        mode = .edit(readyToSave: areFieldsReady)
    }
    
    private func saveRegistration() {
        /* Info */
        registration.owner.firstName = firstNameTextField.text ?? ""
        registration.owner.lastName = lastNameTextField.text ?? ""
        registration.owner.eMail = eMailTextField.text ?? ""
        
        /* Dates */
        registration.checkInDate = checkInDatePicker.date
        registration.checkOutDate = checkOutDatePicker.date
        
        /* Guests count */
        registration.numberOfAdults = numberOfAdults
        registration.numberOfChildren = numberOfChildren
        
        /* WiFi */
        registration.wifiEnable = wifiSwitch.isOn
        
        delegate?.didUpdateRegistration(registration)
    }
    
    func setupDateViews() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
    }
    
    func updateDateViews() {
        checkOutDatePicker?.minimumDate = checkInDatePicker.date.addingTimeInterval(60 * 60 * 24)
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        checkInDateLabel?.text = formatter.string(from: checkInDatePicker.date)
        checkOutDateLabel?.text = formatter.string(from: checkOutDatePicker.date)
    }
    
    func updateNumberOfGuests() {
        numberOfAdultsLabel?.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel?.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    private func setupUI() {
        
        // Set possibility of editing
        navigationItem.rightBarButtonItems?.removeAll { $0 == (isEditable ? editButton : saveAndCancelButton) }
        
        if isEditable {
            editButton = nil
        } else {
            cancelAndBackButton = nil
            saveAndCancelButton = nil
        }
        
        clearsSelectionOnViewWillAppear = true
        
        setupDateViews()
        
        if let registration = registration {
            
            /* Filling info */
            firstNameTextField.text = registration.owner.firstName
            lastNameTextField.text = registration.owner.lastName
            eMailTextField.text = registration.owner.eMail
            
            /* Filling dates */
            checkInDatePicker.date = registration.checkInDate
            checkOutDatePicker.date = registration.checkOutDate
            
            /* Filling guests count */
            numberOfAdultsStepper.value = Double(registration.numberOfAdults)
            numberOfChildrenStepper.value = Double(registration.numberOfChildren)
            
            /* Filling wifi */
            wifiSwitch.isOn = registration.wifiEnable
            
            /* Filling room */
            roomCell.detailTextLabel?.text = registration.room?.shortName
            roomCell.accessoryType = .checkmark
            
        }
        
        updateUI()
    }
    
    private func updateUI() {
        
        navigationItem.leftBarButtonItem = isEditable ? (cancelAndBackButton ?? cancelButton) : nil
        
        updateDateViews()
        updateNumberOfGuests()
        
        // Update possibility of editing
        saveAndCancelButton?.isEnabled = areFieldsReady
        textFields.forEach { $0.isEnabled = isEditable }
        
        tableView.allowsSelection = isEditable
        
        numberOfAdultsStepper.isEnabled = isEditable
        numberOfChildrenStepper.isEnabled = isEditable
        
        wifiSwitch.isEnabled = isEditable
        
    }
    
}

// MARK: - Actions
extension AddRegistrationTableViewController {
    
    @objc private func actionCancel() {
        isEditable.toggle()
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {
        
        switch mode {
        case .review:
            isEditable.toggle()
            firstNameTextField.becomeFirstResponder()
        case .edit:
            saveRegistration()
            title = firstNameTextField.text
            isEditable.toggle()
        }
        
    }
    
    @IBAction func datePickerValueChanged() {
        updateDateViews()
    }
    
    @IBAction func stepperValueChanged() {
        updateNumberOfGuests()
    }
    
    @IBAction func actionWiFiChange(_ sender: UISwitch) {
        
    }
}

// MARK: - Navigation
extension AddRegistrationTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        
        case "ShowRoomIdentifier":
            let roomsTableViewController = segue.destination as! RoomsTableViewController
            roomsTableViewController.delegate = self
            roomsTableViewController.idRoom = registration.room?.id ?? 0
            
        case "SaveSegue":
            saveRegistration()
            
        default:
            break
            
        }
        
    }
    
}

// MARK: - UITextFieldDelegate
extension AddRegistrationTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let index = textFields.firstIndex(of: textField) else { return false }
        
        let nextIndex = index + 1
        
        guard nextIndex < textFields.count else {
            
            textField.resignFirstResponder()
            return true
        }
        
        textFields[nextIndex].becomeFirstResponder()
        return true
        
    }
    
}


// MARK: - Table view delegate & data source
extension AddRegistrationTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let autoHeight = UITableView.automaticDimension
        
        switch indexPath {
            
        case checkInDatePickerCellIndexPath: return isCheckInDatePickerShown ? autoHeight : 0
            
        case checkOutDatePickerCellIndexPath: return isCheckOutDatePickerShown ? autoHeight : 0
            
        default: return autoHeight
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
            
        case checkInDatePickerCellIndexPath.prevRow:
            
            isCheckInDatePickerShown.toggle()
            isCheckOutDatePickerShown = isCheckInDatePickerShown ? false : isCheckOutDatePickerShown
            
        case checkOutDatePickerCellIndexPath.prevRow:
            
            isCheckOutDatePickerShown.toggle()
            isCheckInDatePickerShown = isCheckOutDatePickerShown ? false : isCheckInDatePickerShown
            
        default:
            return
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
}

// MARK: - RoomsTableViewControllerDelegate
extension AddRegistrationTableViewController: RoomsTableViewControllerDelegate {
    func didChangeRoom(_ room: RoomType) {
        registration.room = room
        
        roomCell.detailTextLabel?.text = room.shortName
        roomCell.accessoryType = .checkmark
        
        checkReadyToSave()
    }
}
