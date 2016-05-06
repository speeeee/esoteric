//
//  TerseTableViewController.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//
import UIKit

class TerseTableViewController: UITableViewController {
    
    //   var notes : [Note]!
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terseStore.sharedInstance.getCount() }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TerseCell", forIndexPath: indexPath) as! TerseTableViewCell
        
        cell.setupCell(terseStore.sharedInstance.getPrgm(indexPath.row))
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            terseStore.sharedInstance.deletePrgm(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editPrgmSegue" {
            let trseDetailVC = segue.destinationViewController as! TerseDetailViewController
            let tableCell = sender as! TerseTableViewCell
            trseDetailVC.tc = tableCell.tc
        }
    }
    
    @IBAction func saveNoteDetail(segue: UIStoryboardSegue) {
        let trseDetailVC = segue.sourceViewController as! TerseDetailViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            // NoteStore.sharedInstance.updateNote(noteDetailVC.note, index: indexPath.row)
            //terseStore.sharedInstance.sort()
            var indexPaths = [NSIndexPath]()//tells us which is changed
            for index in 0...indexPath.row{
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
            }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
            terseStore.sharedInstance.addPrgm(trseDetailVC.tc)
            // let indexPath = NSIndexPath(forRow: NoteStore.sharedInstance.getCount() - 1, inSection: 0)
            // tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadData()
        }
    }
    @IBAction func justDontDoAnything(segue: UIStoryboardSegue) { 2; } // It's fine, I swear.
}
