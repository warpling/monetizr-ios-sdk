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
    let backgroundColor = UIColor.init(white: 0.15, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enforce dark mode for variant selector
        if #available(iOS 13, *) {
            overrideUserInterfaceStyle = .dark
        }
        
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        
        self.view.backgroundColor = backgroundColor
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
        self.navigationController?.navigationBar.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0xE0093B)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeSelector))
        
        // Register cusotm headers
        tableView.register(VariantSelectionHeaderView.self,
        forHeaderFooterViewReuseIdentifier: "sectionHeader")
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    override func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if selectedValues.count > 0 {
            return 30
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView,
            viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                   "sectionHeader") as! VariantSelectionHeaderView
        if selectedValues.count > 0 {
            var titleText = NSLocalizedString("Selected", comment: "Selected") + ":"
            for value in selectedValues {
                let valueString = value as! String
                let index = selectedValues.index(of: value)
                if index == 0 {
                    titleText = titleText + " " + valueString
                }
                else {
                    titleText = titleText + " " + "•" + " " + valueString
                }
            }
            view.title.text = titleText
            return view
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        
        // Format cell
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = UIColor(hex: 0xE0093B)
        cell.detailTextLabel?.textColor = .lightGray
        
        // Reset cell - need to be clear if reused
        cell.selectionStyle = .none
        cell.textLabel!.text = ""
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .none
        
        // Configyre accesory view
        if level+1 != names.count {
            cell.accessoryType = .disclosureIndicator
        }
        
        // Add title - variant
        cell.textLabel!.text = values[indexPath.row] as? String
        
        // Add subtatle - price
        if level+1 == names.count {
            var availableVariants: [VariantsEdge] = []
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
            if availableVariants.count > 0 {
                let selectedVariant = availableVariants[0].node
                let priceAmount = selectedVariant?.priceV2?.amount ?? "0"
                let priceCurrency = selectedVariant?.priceV2?.currency ?? "USD"
                cell.detailTextLabel?.text = priceAmount.priceFormat(currency: priceCurrency)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Some row selceted
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
