//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import StudKit
import StudKitUI

final class EventListController: UITableViewController, DataSourceDelegate, Routable {
    private var viewModel: EventListViewModel?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: dateTabBar.bounds.height, left: 0, bottom: 0, right: 0)
        }

        refreshControl?.addTarget(self, action: #selector(refreshControlTriggered(_:)), for: .valueChanged)

        navigationItem.title = "Events".localized

        tableView.register(DateHeader.self, forHeaderFooterViewReuseIdentifier: DateHeader.typeIdentifier)
        tableView.tableHeaderView = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let navigationController = splitViewController?.detailNavigationController ?? self.navigationController
        (navigationController as? BorderlessNavigationController)?.toolBarView = dateTabBarContainer

        if let nowIndexPath = viewModel?.nowIndexPath {
            tableView.scrollToRow(at: nowIndexPath, at: .top, animated: true)
        }

        reloadDateTabBar()
        viewModel?.update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let nowIndexPath = viewModel?.nowIndexPath {
            tableView.scrollToRow(at: nowIndexPath, at: .top, animated: true)
            updateDateTabBarSelection()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.toolBarView = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard self == navigationController?.topViewController else {
            return super.viewWillTransition(to: size, with: coordinator)
        }

        let controller = splitViewController?.detailNavigationController as? BorderlessNavigationController
        controller?.toolBarView = nil

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            let controller = self.splitViewController?.detailNavigationController as? BorderlessNavigationController
            controller?.toolBarView = self.dateTabBarContainer
        }, completion: nil)
    }

    func prepareContent(for route: Routes) {
        guard case let .eventList(for: optionalContainer) = route else { fatalError() }

        defer { tableView.reloadData() }

        guard let container = optionalContainer else { return viewModel = nil }

        viewModel = EventListViewModel(container: container)
        viewModel?.delegate = self
        viewModel?.fetch()
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel?.container.objectIdentifier.rawValue, forKey: ObjectIdentifier.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let restoredObjectIdentifier = coder.decodeObject(forKey: ObjectIdentifier.typeIdentifier) as? String,
            let course = Course.fetch(byObjectId: ObjectIdentifier(rawValue: restoredObjectIdentifier)) {
            prepareContent(for: .eventList(for: course))
        }

        super.decodeRestorableState(with: coder)
    }

    // MARK: - User Interface

    @IBOutlet var dateTabBarContainer: UIView!

    @IBOutlet var dateTabBar: DateTabBarView!

    private func reloadDateTabBar() {
        guard let viewModel = viewModel, dateTabBar != nil, viewModel.numberOfSections > 0 else { return }
        dateTabBar.isDateEnabled = viewModel.contains
        dateTabBar.didSelectDate = didSelect
        dateTabBar.startsAt = viewModel[sectionAt: 0]
        dateTabBar.endsAt = viewModel[sectionAt: viewModel.numberOfSections - 1]
        dateTabBar.reloadData()
    }

    private func updateDateTabBarSelection() {
        guard let viewModel = viewModel, let indexPath = tableView.topMostIndexPath else { return }
        dateTabBar.selectedDate = viewModel[sectionAt: indexPath.section]
    }

    // MARK: - User Interaction

    @objc
    func refreshControlTriggered(_: Any) {
        viewModel?.update(forced: true) {
            self.refreshControl?.endRefreshing()
        }
    }

    private func didSelect(date: Date) {
        guard let viewModel = viewModel, let sectionIndex = viewModel.sectionIndex(for: date) else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: sectionIndex), at: .top, animated: true)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { fatalError() }

        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.typeIdentifier, for: indexPath)
        (cell as? EventCell)?.event = viewModel[rowAt: indexPath]
        return cell
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return DateHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel else { fatalError() }

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateHeader.typeIdentifier)
        (header as? DateHeader)?.date = viewModel[sectionAt: section]
        return header
    }

    // MARK: - Scroll View Delegate

    override func scrollViewDidEndDecelerating(_: UIScrollView) {
        updateDateTabBarSelection()
    }

    // MARK: - Reacting to Data Changes

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
        reloadDateTabBar()
        updateDateTabBarSelection()
    }
}
