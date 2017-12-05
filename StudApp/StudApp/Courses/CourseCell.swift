//
//  CourseCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseCell: UITableViewCell {
    // MARK: - Life Cycle

    var course: Course! {
        didSet {
            titleLabel?.text = course.title
            lecturersLabel?.text = course.lecturers
                .map { $0.nameComponents.formatted() }
                .joined(separator: ", ")
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var colorView: UIView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var lecturersGlyph: UIImageView!

    @IBOutlet weak var lecturersLabel: UILabel!
}