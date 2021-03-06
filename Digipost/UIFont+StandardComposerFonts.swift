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

extension UIFont {
    
    class func headlineH1() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 22)
    }

    class func headlineH2() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 20)
    }

    class func headlineH3() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 18)
    }

    class func paragraph() -> UIFont {
        return UIFont.systemFont(ofSize: 15)
    }

}

