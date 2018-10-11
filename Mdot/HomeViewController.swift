//
//  SampleViewController.swift
//  TurbolinksDemo
//
//  Created by Charlon Palacay on 9/30/18.
//  Copyright © 2018 Basecamp. All rights reserved.
//

import UIKit
import WebKit


class HomeViewController: ApplicationController {
    
    override var url: Foundation.URL {
        return Foundation.URL(string: "http://curry.aca.uw.edu:8000/?hybrid=true")!
    }
}
