//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

class InvoiceOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var bankTableView: UITableView!
    
    let kInvoiceBankSegue = "invoiceBankSegue"
    var banks: [InvoiceBank] = [];
    
    @IBAction func readMoreButton(sender: AnyObject) {
        let readMoreUrl = NSURL(string: "https://www.digipost.no")!
        UIApplication.sharedApplication().openURL(readMoreUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bankTableView.delegate = self
        bankTableView.dataSource = self
        bankTableView.registerNib(UINib(nibName: Constants.Invoice.InvoiceBankTableViewCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Invoice.InvoiceBankTableViewCellNibName)
        
        addInvoiceBanks();
    }
    
    func addInvoiceBanks(){
        banks.append(InvoiceBank(name:"DNB", url:"https://m.dnb.no/appo/logon/startmobile", logo:"invoice-bank-dnb"))
        banks.append(InvoiceBank(name:"KLP", url:"https://dnb.no", logo:"invoice-bank-klp"))
        banks.append(InvoiceBank(name:"Skandiabanken", url:"https://dnb.no", logo:"invoice-bank-skandia"))
        bankTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Invoice.InvoiceBankTableViewCellNibName, forIndexPath: indexPath) as! InvoiceBankTableViewCell
        
        let invoiceBank = banks[indexPath.row]
        cell.invoiceBankLogo.image = UIImage(named: invoiceBank.logo)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == kInvoiceBankSegue{
            if let viewController = segue.destinationViewController as? InvoiceBankViewController {
                viewController.invoiceBank = banks[(sender as! NSIndexPath).row]
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(kInvoiceBankSegue, sender: indexPath)
    }
}