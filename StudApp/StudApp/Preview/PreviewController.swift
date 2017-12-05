//
//  PreviewController.swift
//  StudApp
//
//  Created by Steffen Ryll on 02.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook
import StudKit

final class PreviewController: QLPreviewController, Routable {
    // MARK: - Life Cycle

    private var file: File!

    func prepareDependencies(for route: Routes) {
        guard case let .preview(file) = route else { fatalError() }

        self.file = file

        dataSource = self
    }
}

extension PreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return file
    }
}