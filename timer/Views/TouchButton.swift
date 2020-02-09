//
//  TouchButton.swift
//  timer
//
//  Created by Valerii Petrychenko on 08.02.2020.
//  Copyright © 2020 Valerii Petrychenko. All rights reserved.
//

import UIKit

class TouchButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        self.layer.cornerRadius = self.frame.height / 2
        self.setTitleColor(.white, for: .normal)
    }
}
