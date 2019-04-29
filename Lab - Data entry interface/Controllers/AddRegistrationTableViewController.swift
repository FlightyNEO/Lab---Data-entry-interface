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
    @IBOutlet weak var wifiLabel: UILabel!
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
    
    private lazy var cancelButton: UIBarButtonItem? = {
        return UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(actionCancel))
    }()
    
    private lazy var currencyFormatter: NumberFormatter = {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_US")
        
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        
        return formatter
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
    
    private var modifiedRegistration: Registration!
    
    // MARK: ... Calculated properties
    /// Return all text fields
    private var textFields: [UITextField] {
        guard
            firstNameTextField != nil,
            lastNameTextField != nil,
            eMailTextField != nil else { return [] }
        
        return [firstNameTextField, lastNameTextField, eMailTextField]
    }
    
    /// Return true if all fields is correct filling
    private var isCompletedForms: Bool {
        
        guard !textFields.isEmpty else { return false }
        
        for textField in textFields {
            if textField.isEmpty { return false }
        }
        
        guard
            Validator.isEmail().apply(eMailTextField.text),
            modifiedRegistration.room != nil else { return false }
        
        return true
    }
    
    
    /// Return number of places for adults
    private var numberOfAdults: Int {
        return Int(numberOfAdultsStepper.value)
    }
    
    /// Return number of places for children
    private var numberOfChildren: Int {
        return Int(numberOfChildrenStepper.value)
    }
    
    // MARK: ... Properties
    var registration: Registration!
    weak var delegate: RegistrationDetailViewControllerDelegate?
    
    var isEditable = false {
        didSet {
            mode = isEditable ? .edit(readyToSave: true) : .review
            updateUI()
        }
    }
    
    var canEditing = true {
        didSet {
            if !canEditing {
                navigationItem.rightBarButtonItems?.removeAll()
            }
        }
    }
    
    // MARK: ... Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        setupUI()
        
        if registration == nil {
            registration = Registration()
        }
        
        modifiedRegistration = registration
        updateUI()
        
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
    
    
    /// Validation of the entered data
    private func checkReadyToSave() {
        saveAndCancelButton?.isEnabled = isCompletedForms
        mode = .edit(readyToSave: isCompletedForms)
    }
    
    private func updateRegistration() {
        /* Info */
        modifiedRegistration.owner.firstName = firstNameTextField.text ?? ""
        modifiedRegistration.owner.lastName = lastNameTextField.text ?? ""
        modifiedRegistration.owner.eMail = eMailTextField.text ?? ""
        
        /* Dates */
        modifiedRegistration.checkInDate = checkInDatePicker.date
        modifiedRegistration.checkOutDate = checkOutDatePicker.date
        
        /* Guests count */
        modifiedRegistration.numberOfAdults = numberOfAdults
        modifiedRegistration.numberOfChildren = numberOfChildren
        
        /* WiFi */
        modifiedRegistration.wifiEnable = wifiSwitch.isOn
    }
    
    private func saveRegistration() {
        registration = modifiedRegistration
        updateRegistration()
        delegate?.didUpdateRegistration(modifiedRegistration)
    }
    
    private func setPossibilityOfEditing() {
        if canEditing {
            navigationItem.rightBarButtonItems?.removeAll { $0 == (isEditable ? editButton : saveAndCancelButton) }
        } else {
            navigationItem.rightBarButtonItems?.removeAll()
        }
        
        if isEditable && canEditing {
            editButton = nil
        } else {
            cancelAndBackButton = nil
            saveAndCancelButton = nil
        }
    }
    
    private func updatePossibilityOfEditing() {
        navigationItem.leftBarButtonItem = isEditable ? (cancelAndBackButton ?? cancelButton) : nil
        
        saveAndCancelButton?.isEnabled = isCompletedForms
        textFields.forEach { $0.isEnabled = isEditable }
        
        tableView.allowsSelection = isEditable
        
        numberOfAdultsStepper.isEnabled = isEditable
        numberOfChildrenStepper.isEnabled = isEditable
        
        wifiSwitch.isEnabled = isEditable
        
        if !isEditable {
            
            isCheckInDatePickerShown = false
            isCheckOutDatePickerShown = false
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: ... Setup UI
    private func setupUI() {
        
        // Set possibility of editing
        setPossibilityOfEditing()
        
        clearsSelectionOnViewWillAppear = true
        
        setupDateViews()
        //updateUI()
    }
    
    private func setupDateViews() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
    }
    
    // MARK: ... Update UI
    private func updateUI() {
        
        fillingForms()
        
        updateDateViews()
        updateNumberOfGuests()
        updateWiFiView(isOn: wifiSwitch?.isOn ?? false)
        updateRoomView()
        
        // Update possibility of editing
        updatePossibilityOfEditing()
    }
    
    private func fillingForms() {
        if let registration = registration {
            
            /* Filling info */
            firstNameTextField?.text = registration.owner.firstName
            lastNameTextField?.text = registration.owner.lastName
            eMailTextField?.text = registration.owner.eMail
            
            /* Filling dates */
            checkInDatePicker?.date = registration.checkInDate
            checkOutDatePicker?.date = registration.checkOutDate
            
            /* Filling guests count */
            numberOfAdultsStepper?.value = Double(registration.numberOfAdults)
            numberOfChildrenStepper?.value = Double(registration.numberOfChildren)
            
            /* Filling wifi */
            wifiSwitch?.isOn = registration.wifiEnable
            
            /* Filling room */
            roomCell?.detailTextLabel?.text = registration.room?.shortName
            roomCell?.accessoryType = .checkmark
            
        }
    }
    
    private func updateDateViews() {
        // Check in date
        checkOutDatePicker?.minimumDate = checkInDatePicker.date.addingTimeInterval(60 * 60 * 24)
        checkOutDateLabel?.text = dateFormatter.string(from: checkOutDatePicker.date)
        checkOutDateLabel?.textColor = checkOutDatePicker.date.timeIntervalSince1970 <= Date().timeIntervalSince1970 ? .red : .darkGray
        
        // Check out date
        checkInDateLabel?.text = dateFormatter.string(from: checkInDatePicker.date)
        checkInDateLabel?.textColor = checkInDatePicker.date.timeIntervalSince1970 <= Date().timeIntervalSince1970 ? .red : .darkGray
    }
    
    private func updateNumberOfGuests() {
        numberOfAdultsLabel?.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel?.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    private func updateWiFiView(isOn: Bool) {
        
        if isOn {
            let price = modifiedRegistration.wifiTotalPrice(0.3)
            guard let sumString = currencyFormatter.string(from: price as NSNumber) else { return }
            wifiLabel?.text = "Wi-Fi: \(sumString)"
        } else {
            wifiLabel?.text = "Wi-Fi"
        }
    }
    
    private func updateRoomView() {
        guard let price = modifiedRegistration?.roomTotalPrice else { return }
        guard let sumString = currencyFormatter.string(from: price as NSNumber) else { return }
        roomCell?.textLabel?.text = "Room type: \(sumString)"
    }
    
}

// MARK: - Actions
extension AddRegistrationTableViewController {
    
    @objc private func actionCancel() {
        modifiedRegistration = registration
        isEditable.toggle()
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {
        
        switch mode {
        case .review:
            isEditable.toggle()
            firstNameTextField.becomeFirstResponder()
        case .edit:
            saveRegistration()
            //title = firstNameTextField.text
            isEditable.toggle()
        }
        
    }
    
    @IBAction func datePickerValueChanged() {
        // Update model
        updateRegistration()
        
        // Update UI
        updateDateViews()
        updateWiFiView(isOn: wifiSwitch.isOn)
        updateRoomView()
    }
    
    @IBAction func stepperValueChanged() {
        // Update model
        updateRegistration()
        
        // Update UI
        updateNumberOfGuests()
        updateWiFiView(isOn: wifiSwitch.isOn)
        updateRoomView()
    }
    
    @IBAction func actionWiFiChange(_ sender: UISwitch) {
        // Update model
        updateRegistration()
        
        // Update UI
        updateWiFiView(isOn: sender.isOn)
    }
    
}

// MARK: - Navigation
extension AddRegistrationTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        
        case "ShowRoomIdentifier":
            let roomsTableViewController = segue.destination as! RoomsTableViewController
            roomsTableViewController.delegate = self
            roomsTableViewController.idRoom = modifiedRegistration.room?.id ?? 0
            
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
        modifiedRegistration.room = room
        
        roomCell.detailTextLabel?.text = room.shortName
        roomCell.accessoryType = .checkmark
        
        updateRoomView()                        // Update for recalculation total price for rooms
        updateWiFiView(isOn: wifiSwitch.isOn)   // Update for recalculation total price for WiFi
        
        checkReadyToSave()
    }
}
