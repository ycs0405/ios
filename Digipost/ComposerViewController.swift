//
//  ComposerViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import AHKActionSheet
import SingleLineKeyboardResize


@objc protocol TableViewReorderingDelegate{
    func tableView(tableView: UITableView, didStartReorderingRowAtPoint point: CGPoint)
}

class ComposerViewController: UIViewController, ModuleSelectorViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDelegateReorderExtension {

    @IBOutlet var tableView: UITableView!
    var deleteComposerModuleView: DeleteComposerModuleView!
    
    @IBOutlet weak var previewButton: UIBarButtonItem!
    @IBOutlet weak var documentTitleLabel: UILabel!
    @IBOutlet weak var documentTitleTextField: UITextField!
    var tableViewDataSource: ComposerTableViewDataSource!
    var recipients = [Recipient]()

    // used when calculating size of textviews for cells that are bigger than one line
    var exampleTextView : UITextView?

    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("composer view navigation bar title", comment: "Composer title")
        previewButton.title = NSLocalizedString("composer view preview button title", comment: "Preview button title")
        documentTitleLabel.text = NSLocalizedString("composer view document title label", comment: "Title label")
        documentTitleTextField.placeholder = NSLocalizedString("composer view title placeholder", comment: "Title placeholder text")
        documentTitleTextField.delegate = self
        setupTableView()
    }
    
    
    @IBAction func previewButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("goToPreview", sender: self)
    }
    

    
    // MARK: - TableView Setup
    
    func setupTableView(){
        tableViewDataSource = ComposerTableViewDataSource(asDataSourceForTableView: tableView)
        let textModuleTableViewCellNib = UINib(nibName: "TextModuleTableViewCell", bundle: nil)
        tableView.registerNib(textModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.textModuleCellIdentifier)
        let imageModuleTableViewCellNib = UINib(nibName: "ImageModuleTableViewCell", bundle: nil)
        tableView.registerNib(imageModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.imageModuleCellIdentifier)
        tableView.delegate = self

        setupKeyboardNotifcationListenerForScrollView(self.tableView)
    }

    // MARK: - UITextView Delegate
    
    func textViewDidChange(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = tableViewDataSource.tableData[indexPath.row] as? TextComposerModule {
                textModule.text = textView.text
                textModule.textAlignment = textView.textAlignment
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func indexPathForCellContainingTextView(textView: UITextView) -> NSIndexPath? {
        let location = tableView.convertPoint(textView.center, fromView: textView)
        return tableView.indexPathForRowAtPoint(location)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - ModuleSelectorViewController Delegate
    
    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule) {
        tableViewDataSource.tableData.append(module)
        tableView.reloadData()
        if let imageModule = module as? ImageComposerModule {
            let squareSize = CGSizeMake(tableView.frame.width, tableView.frame.width)
            if let imageModule = module as? ImageComposerModule {
                imageModule.image.scaleToSize(squareSize)
            }
        } else if let imageModule = module as? TextComposerModule {
            if let indexPath = tableViewDataSource.indexPath(module: module) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell
                let textModule = module as? TextComposerModule
                cell?.moduleTextView.font = textModule?.font
                cell?.setLabel(textModule!.font)
                cell?.moduleTextView.becomeFirstResponder()
                cell?.moduleTextView.delegate = self
            }
        }
        
        let dimView = view as? DimView
        dimView?.dim()
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController) {
        let dimView = view as? DimView
        dimView?.dim()
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancelButtonAction(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: NSLocalizedString("composer view close alert title", comment: "alert title"),
            message: NSLocalizedString("composer view close alert message", comment: "close alert message"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveDraftAction = UIAlertAction(title: NSLocalizedString("composer view close alert save draft button title", comment: "button title"),
            style: UIAlertActionStyle.Default)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
                println("Saved")
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        let quitAction = UIAlertAction(title: NSLocalizedString("composer view close alert quit button title", comment: "button title"),
            style: UIAlertActionStyle.Destructive)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
                
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        alertController.addAction(saveDraftAction)
        alertController.addAction(quitAction)
        
        if tableViewDataSource.tableData.isEmpty{
            self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        } else {
            presentViewController(alertController, animated: true, completion: nil)
        }
    
    }

    override func didReceiveMemoryWarning() {	
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let moduleSelectViewController = segue.destinationViewController  as? ModuleSelectorViewController{
            moduleSelectViewController.delegate = self
            
            let dimView = view as? DimView
            dimView?.dim()
        }
        
        if let previewViewController = segue.destinationViewController as? PreviewViewController{

            previewViewController.recipients = recipients
            previewViewController.modules = tableViewDataSource.tableData
            previewViewController.mailboxDigipostAddress = mailboxDigipostAddress
        }
    }
}
