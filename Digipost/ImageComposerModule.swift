//
//  ComposerImageModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import UIKit

class ImageComposerModule: ComposerModule {
    
    var image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    override func htmlRepresentation() -> String {
        let cssClass = "image"
        return "<img class=\"\(cssClass)\" src=\"data:image/png;base64,\(image.base64Representation)\" alt=\"html_inline_image.png\" title=\"html_inline_image.png\">"
    }
    
}