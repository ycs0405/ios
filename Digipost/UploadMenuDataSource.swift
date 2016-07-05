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

import UIKit

class UploadMenuDataSource: NSObject, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("uploadMenuCell", forIndexPath: indexPath) 
        if let uploadMenuCell = cell as? UploadMenuTableViewCell {
            configureCell(uploadMenuCell, indexPath: indexPath)
        }
        
        return cell
    }
    
    func configureCell(cell: UploadMenuTableViewCell, indexPath: NSIndexPath){
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera", comment:"start camera")
            cell.iconImage.image = UIImage(named: "From_camera")
        case 1:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera roll button", comment:"button that uploads from camera roll")
            cell.iconImage.image = UIImage(named: "Upload")
        case 2:
            cell.titleLabel.text = NSLocalizedString( "upload action sheet other file", comment:"From other app")
            cell.iconImage.image = UIImage.templateImage("Upload_apps")
            cell.iconImage.tintColor = UIColor.whiteColor()
        default:
            assert(false)
        }
    }
}
