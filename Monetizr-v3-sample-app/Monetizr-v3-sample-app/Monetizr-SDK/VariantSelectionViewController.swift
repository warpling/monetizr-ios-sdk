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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        
        // Available variants
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
            //name = (variants[0].node?.selectedOptions![level].name)!
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
        self.title = name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeSelector))
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        if level+1 != names.count {
            cell.accessoryType = .disclosureIndicator
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
