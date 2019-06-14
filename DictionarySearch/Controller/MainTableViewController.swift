//
//  MainTableViewController.swift
//  DictionarySearch
//
//  Created by hwjoy on 2019/5/25.
//  Copyright © 2019 redant. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext? = CoreDataStackManager.sharedInstance.managedObjectContext
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        return searchController
    }()
    var searchText: String?
    
    let CellReuseIdentifier = "dictionaryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "DictionaryTableViewCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier)
        tableView.tableHeaderView = searchController.searchBar
        tableView.rowHeight = 44
        tableView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: managedObjectContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .NSManagedObjectContextObjectsDidChange,
                                                  object: managedObjectContext)
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<DictionaryData> {
        if searchText == searchController.searchBar.text {
            if _fetchedResultsController != nil {
                return _fetchedResultsController!
            }
        }
        searchText = searchController.searchBar.text
        
        let fetchRequest: NSFetchRequest<DictionaryData> = DictionaryData.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        if var searchText = searchText {
            if searchText.count > 0 {
                searchText = "*\(searchText)*"
                let predicate = NSPredicate(format: "key like[c] %@", searchText)
                fetchRequest.predicate = predicate
            }
        }
        
        let sortDescriptorWeight = NSSortDescriptor(key: "weight", ascending: true)
        let sortDescriptorKey = NSSortDescriptor(key: "key", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorWeight, sortDescriptorKey]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: searchText ?? "DefaultName")
        aFetchedResultsController.delegate = nil
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            #if DEBUG
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            #endif
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<DictionaryData>? = nil
    
    func loadData() {
        tableView.reloadData()
    }
    
    @objc func managedObjectContextObjectsDidChange() {
        print("[D] managedObjectContextObjectsDidChange")
        _fetchedResultsController = nil
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = CellReuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DictionaryTableViewCell

        let dataItem = fetchedResultsController.object(at: indexPath)
        configureCell(cell: cell, data: dataItem, highlightText: searchText)

        return cell
    }
    
    func configureCell(cell: DictionaryTableViewCell, data: DictionaryData, highlightText: String?) {
        guard let dataKey = data.key else {
            cell.titleLabel.text = nil
            cell.subtitleLabel.text = nil
            return
        }
        
        if highlightText != nil && highlightText!.count > 0 {
            let attributedText = NSMutableAttributedString(string: dataKey)
            let range = dataKey.lowercased().range(of: highlightText!.lowercased())!
            attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(range, in: dataKey))
            cell.titleLabel.attributedText = attributedText
        } else {
            cell.titleLabel.text = dataKey
        }
        
        cell.subtitleLabel.text = data.paraphrase
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        loadData()
    }
    
}
