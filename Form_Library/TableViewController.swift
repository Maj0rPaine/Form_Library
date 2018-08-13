//
//  TableViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

struct Section {
    var cells: [FormCell]
    var footerTitle: String?
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
}

class TableViewController: UITableViewController {
    var toggle = UISwitch()
    
    var sections: [Section] = []
    
    var state = Hotspot() {
        didSet {
            print(state)
            sections[0].footerTitle = state.enabledSectionTitle
            sections[1].cells[0].detailTextLabel?.text = state.password
            
            reloadSectionFooters()
        }
    }
    
    func buildSections() {
        let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
        toggleCell.textLabel?.text = "Personal Hotspot"
        toggleCell.contentView.addSubview(toggle)
        toggle.isOn = state.isEnabled
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        toggleCell.contentView.addConstraints([
            toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
        passwordCell.textLabel?.text = "Password"
        passwordCell.detailTextLabel?.text = state.password
        passwordCell.accessoryType = .disclosureIndicator
        passwordCell.shouldHighlight = true
        
        let passwordVC = PasswordViewController(password: state.password) { [unowned self] in
            self.state.password = $0
        }
        
        passwordCell.didSelect = { [unowned self] in
            self.navigationController?.pushViewController(passwordVC, animated: true)
        }
        
        sections = [
            Section(cells: [
                toggleCell
                ], footerTitle: state.enabledSectionTitle),
            Section(cells: [
                passwordCell
                ], footerTitle: nil),
        ]
    }
    
    func reloadSectionFooters() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        
        for index in sections.indices {
            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()
        }
        
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    init() {
        super.init(style: .grouped)
        buildSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return sections[indexPath.section].cells[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
    
    @objc func toggleChanged(_ sender: Any) {
        state.isEnabled = toggle.isOn
    }
}

class PasswordViewController: UITableViewController {
    let textField = UITextField()
    let onChange: (String) -> ()
    
    init(password: String, onChange: @escaping (String) -> ()) {
        self.onChange = onChange
        super.init(style: .grouped)
        textField.text = password
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hotspot Password"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Password"
        cell.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(editingField(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(editingDidEnter(_:)), for: .editingDidEndOnExit)
        cell.contentView.addConstraints([
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
        return cell
    }
    
    @objc func editingField(_ sender: Any) {
        onChange(textField.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender: Any) {
        onChange(textField.text ?? "")
        navigationController?.popViewController(animated: true)
    }
}
