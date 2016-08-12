//
//  PopoverViewController.swift
//  ErlangInstaller
//
//  Created by Inaka on 7/22/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
	
	weak var delegate : PopoverDelegate?
	
	override func viewWillAppear() {
		super.viewWillAppear()
	}
	@IBAction func closePopover(sender: AnyObject) {
			self.delegate?.closePopoverFromMainMenu(sender)
		}
}
