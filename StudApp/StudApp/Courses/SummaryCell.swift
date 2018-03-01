//
//  SummaryCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 01.03.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKitUI

final class SummaryCell: UITableViewCell {
    // MARK: - User Interface

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.textContainerInset = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)
        }
    }
}
