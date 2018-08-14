//
//  Forms.swift
//  Form_Library
//
//  Created by Chris Paine on 8/13/18.
//  Copyright © 2018 Chris Paine. All rights reserved.
//

import UIKit

class Section {
    let cells: [FormCell]
    var footerTitle: String?
    
    init(cells: [FormCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
}

class FormViewController: UITableViewController {
    var sections: [Section] = []
    var firstResponder: UIResponder?
    
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
    
    init(sections: [Section], title: String, firstResponder: UIResponder? = nil) {
        self.firstResponder = firstResponder
        self.sections = sections
        super.init(style: .grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
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
}

final class TargetAction {
    let execute: () -> ()
    
    // Init with callback
    init(_ execute: @escaping() -> ()) {
        self.execute = execute
    }
    @objc func action(_ sender: Any) {
        execute()
    }
}

/// Generic observer that manages strong references and update functions.
struct Observer<State> {
    var strongReferences: [Any]
    var update: (State) -> ()
}

/// Generic renderingContext holds state, form changes, and actions.
struct RenderingContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let pushViewController: (UIViewController) -> ()
    let popViewController: () -> ()
}

class FormDriver<State> {
    var formViewController: FormViewController!
    var sections: [Section] = []
    var observer: Observer<State>!
    
    var state:State {
        didSet {
            observer.update(state)
            formViewController.reloadSectionFooters()
        }
    }
    
    // Initialize with free function hotspotForm.
    init(initial state: State, build: (RenderingContext<State>) -> ([Section], Observer<State>)) {
        self.state = state
        
        // Create rendering context with state, change and push functions
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state) // Mutate state
        }, pushViewController: { [unowned self] vc in
            self.formViewController.navigationController?.pushViewController(vc, animated: true)
        }, popViewController: { [unowned self] in
            self.formViewController.navigationController?.popViewController(animated: true)
        })
        
        let (sections, observer) = build(context)
        self.sections = sections
        self.observer = observer
        observer.update(state)
        formViewController = FormViewController(sections: sections, title: "Personal Hotspot Settings")
    }
}
