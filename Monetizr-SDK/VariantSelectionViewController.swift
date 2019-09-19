//
//  VariantSelectionViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 07/05/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit

// Protocol used for sending data back to product view
protocol VariantSelectionDelegate: class {
    func closeOptionsSelector()
    func optionValuesSelected(selectedValues: NSMutableArray)
}

class VariantSelectionViewController: UITableViewController, VariantSelectionDelegate {
    func closeOptionsSelector() {
        delegate?.closeOptionsSelector()
    }
    
    func optionValuesSelected(selectedValues: NSMutableArray) {
        delegate?.optionValuesSelected(selectedValues: selectedValues)
    }
    
    weak var delegate: VariantSelectionDelegate? = nil
    var variants: [VariantsEdge] = []
    var level = 0
    var name = String()
    var values: NSMutableArray = []
    var names: NSMutableArray = []
    var selectedValues: NSMutableArray = []
    var availableVariants: [VariantsEdge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        
        self.view.backgroundColor = .clear
        
        // Available variants for level
        if selectedValues.count > 0 {
            for variant in variants {
                let optionsValues: NSMutableArray = []
                for option in (variant.node?.selectedOptions)! {
                    optionsValues.add(option.value!)
                }
                if selectedValues.allSatisfy(optionsValues.contains) {
                    availableVariants.append(variant)
                }
            }
        }
        if selectedValues.count == 0 {
            availableVariants = variants
        }
        
        // Setup name for level
        if variants.count > 0 {
            for variant in variants {
                for option in (variant.node?.selectedOptions)! {
                    if !names.contains(option.name!) {
                        names.add(option.name!)
                    }
                }
            }
            name = names[level] as! String
        }
        
        // Values for level
        for variant in availableVariants {
            for option in (variant.node?.selectedOptions)! {
                if option.name == name {
                    if !values.contains(option.value!) {
                        values.add(option.value!)
                    }
                }
            }
        }
        
        // Setup navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0xE0093B)
        self.title = name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeSelector))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Deselect option value when going back lavel
        if selectedValues.count > 0 {
            if selectedValues.count > level {
                selectedValues.removeObject(at: level)
            }
        }
    }
    
    @objc func closeSelector() {
        delegate?.closeOptionsSelector()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return values.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        cell.backgroundColor = .clear
        if level+1 != names.count {
            // cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel!.text = values[indexPath.row] as? String
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Some row selceted
        //selectedValues.add(values[indexPath.row])
        selectedValues[level] = values[indexPath.row]
        if level+1 < names.count {
            let variantSelectionViewController = VariantSelectionViewController()
            variantSelectionViewController.variants = availableVariants
            variantSelectionViewController.level = level+1
            variantSelectionViewController.selectedValues = selectedValues
            
            variantSelectionViewController.delegate = self
            self.navigationController?.pushViewController(variantSelectionViewController, animated: true)
        }
        if level+1 == names.count {
            tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            delegate?.optionValuesSelected(selectedValues: selectedValues)
            delegate?.closeOptionsSelector()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
       
    }
}
