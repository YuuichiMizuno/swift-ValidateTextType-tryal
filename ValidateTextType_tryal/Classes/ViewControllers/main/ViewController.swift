//
//  ViewController.swift
//  ValidateTextType_tryal
//
//  Created by Yuuichi Watanabe on 2018/11/19.
//  Copyright © 2018 Yuuichi Watanabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        /* sample */
        if let mixCheck = ValidateTextType.catchWithVerify(target: "aa@aa.cc", types: [.eMailAddress]) {
			print("// mixCheck - NG: ", mixCheck)
		}
    }

}

