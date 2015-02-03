//
//  AccountViewController.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-01-13.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem!
    
    var logoutBarButtonVariable: UIBarButtonItem?
    var refreshControl: UIRefreshControl?
    var dataSource: AccountTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutBarButtonVariable = logoutBarButtonItem
        
        let firstVC: UIViewController = navigationController!.viewControllers[0] as UIViewController
        if firstVC.navigationItem.rightBarButtonItem == nil {
            firstVC.navigationItem.setRightBarButtonItem(logoutBarButtonItem, animated: false)
        }

        firstVC.navigationItem.leftBarButtonItem = nil
        firstVC.navigationItem.rightBarButtonItem = nil
        firstVC.navigationItem.titleView = nil
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext) {
                if rootResource == true {
                    performSegueWithIdentifier("gotoDocumentsFromAccountsSegue", sender: self)
                }
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.digipostGreyOne()
        refreshControl?.addTarget(self, action: "refreshContentFromServer", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    func refreshContentFromServer() {
        updateContentsFromServerUseInitiateRequest(0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.registerNib(UINib(nibName: Constants.Account.mainAccountCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.mainAccountCellIdentifier)
        tableView.registerNib(UINib(nibName: Constants.Account.accountCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.accountCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        var tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.digipostAccountViewBackground()
        
        dataSource = AccountTableViewDataSource(asDataSourceForTableView: tableView)
        tableView.delegate = self
        
        let title = NSLocalizedString("Accounts title", comment: "Title for navbar at accounts view")
        logoutButton.setTitle(NSLocalizedString("log out button title", comment: "Title for log out button"), forState: .Normal)
        logoutButton.setTitleColor(UIColor.digipostLogoutButtonTextColor(), forState: .Normal)
        
        if let showingItem: UINavigationItem = navigationController?.navigationBar.backItem {
            
            showingItem.hidesBackButton = true
                        
            if showingItem.respondsToSelector("setLeftBarButtonItem:") {
                showingItem.setLeftBarButtonItem(nil, animated: false)
            }
            
            if showingItem.respondsToSelector("setRightBarButtonItem:") {
                showingItem.setRightBarButtonItem(logoutBarButtonVariable, animated: false)
            }
            if showingItem.respondsToSelector("setBackBarButtonItem:") {
                showingItem.backBarButtonItem = nil
            }
            
            showingItem.title = title
        }

        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        
        navigationController?.navigationBar.topItem?.setRightBarButtonItem(logoutBarButtonItem, animated: false)
        navigationController?.navigationBar.topItem?.title = title
        
        updateContentsFromServerUseInitiateRequest(0)
    }
    
    func updateContentsFromServerUseInitiateRequest(userDidInitiateRequest: Int) {
        APIClient.sharedClient.updateRootResource(success: { (response) -> Void in
            if let actualRefreshControl = self.refreshControl {
                self.refreshControl?.endRefreshing()
            }
        }) { (error) -> () in
            if let actualRefreshControl = self.refreshControl {
                self.refreshControl?.endRefreshing()
            }
            // Notify user about error?
        }
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
        
        performSegueWithIdentifier("PushFolders", sender: self)
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushFolders" {
            let mailbox: POSMailbox = dataSource?.managedObjectAtIndexPath(tableView.indexPathForSelectedRow()!) as POSMailbox
            let folderViewController: POSFoldersViewController = segue.destinationViewController as POSFoldersViewController
            folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress
            POSModelManager.sharedManager().selectedMailboxDigipostAddress = mailbox.digipostAddress
        } else if segue.identifier == "gotoDocumentsFromAccountsSegue" {
            let documentsView: POSDocumentsViewController = segue.destinationViewController as POSDocumentsViewController
            let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
            let nameDescriptor: NSSortDescriptor = NSSortDescriptor(key: "owner", ascending: true)
            let mailboxes: NSArray = rootResource.mailboxes.sortedArrayUsingDescriptors([nameDescriptor])
            
            let userMailbox: POSMailbox = mailboxes[0] as POSMailbox
            documentsView.mailboxDigipostAddress = userMailbox.digipostAddress
            documentsView.folderName = kFolderInboxName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Logout

    @IBAction func logoutButtonTapped(sender: UIButton) {
        logoutUser()
    }
    
    func logoutUser() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIAlertView.showWithTitle(NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), message: "", cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), otherButtonTitles:[NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out")], tapBlock: { (alert: UIAlertView!, buttonIndex: Int) -> Void in
                if buttonIndex == 1 {
                    self.userDidConfirmLogout()
                }
            })
        } else {
            UIActionSheet.showFromBarButtonItem(logoutBarButtonItem, animated: true, withTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), destructiveButtonTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out"), otherButtonTitles: nil, tapBlock: { (actionSheet: UIActionSheet!, buttonIndex: Int) -> Void in
                if buttonIndex == 0 {
                    self.userDidConfirmLogout()
                }
            })
        }
    }
    
    func userDidConfirmLogout() {
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
            letterViewController.receipt = nil
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil)
        tableView.reloadData()
        //POSAPIManager.sharedManager().logout()
    }

}
