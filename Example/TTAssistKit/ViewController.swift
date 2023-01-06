//
//  ViewController.swift
//  TTAssistKit
//
//  Created by imbatao@outlook.com on 01/06/2023.
//  Copyright (c) 2023 imbatao@outlook.com. All rights reserved.
//

import UIKit
import TTAssistKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TTNetObserver.shared.netStateChange.subscribe(onNext: {[weak self] (hasNet) in guard let self = self else { return }
            print("是否有网\(hasNet)")
        }).disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

