//
//  FormsViewController.swift
//  Form_Library
//
//  Created by Chris Paine on 4/30/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class FormViewController: UITableViewController {
    var firstResponder: UIResponder?
    
    var sections: [TableSection] = []
    
    var previouslyVisibleSections: [TableSection] = []
    
    var visibleSections: [TableSection] {
        return sections.filter { $0.isVisible }
    }
    
    init(sections: [TableSection], firstResponder: UIResponder? = nil) {
        super.init(style: .grouped)
        self.sections = sections
        previouslyVisibleSections = visibleSections
        self.firstResponder = firstResponder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].cells.count
    }
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return visibleSections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return visibleSections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
    func reloadSections() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let section = sections[index]
            let newIndex = visibleSections.index(of: section)
            let oldIndex = previouslyVisibleSections.index(of: section)
            
            switch (newIndex, oldIndex) {
            case (nil, nil), (.some, .some): break
            case let (newIndex?, nil):
                tableView.insertSections([newIndex], with: .automatic)
            case let (nil, oldIndex?):
                tableView.deleteSections([oldIndex], with: .automatic)
            }
            
            if let i = newIndex {
                let footer = tableView.footerView(forSection: i)
                footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: i)
                footer?.setNeedsLayout()
            }
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        previouslyVisibleSections = visibleSections
    }
}

extension UIViewController {
    func renderChildTableViewController(controller: UITableViewController) {
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        view.addConstraints([
            controller.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            controller.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        controller.didMove(toParentViewController: self)
    }
}
