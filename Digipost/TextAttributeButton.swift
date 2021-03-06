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

class TextAttributeButton: UIButton {

    let textAttribute : TextAttribute

    init(textAttribute: TextAttribute, target: UIViewController, selector: Selector) {
        self.textAttribute = textAttribute
        super.init(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        self.setTitle("Test", for: UIControlState())
        self.addTarget(target, action: selector, for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        self.textAttribute = TextAttribute()
        super.init(coder: aDecoder)
    }

    func indicateSelectedIfMatchingStyle(_ anotherTextAttribute : TextAttribute) {
        if self.textAttribute.hasOneOrMoreMatchesWith(textAttribute: anotherTextAttribute) {
            self.backgroundColor = UIColor.red
        } else {
            self.backgroundColor = UIColor.white
        }
    }

}
