//
//  AccountsViewController.swift
//  TurbolinksDemo
//
//  Created by Charlon Palacay on 10/1/18.
//  Copyright © 2018 Basecamp. All rights reserved.
//

import UIKit
import WebKit


class AccountsViewController: ApplicationController {
    
    override var url: Foundation.URL {
        return Foundation.URL(string: "http://localhost:8000/accounts/?hybrid=true")!
    }
}
