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

final class SettingsController: UITableViewController, Routable {
    private var observations: Set<NSKeyValueObservation> = []

    // MARK: - View Model

    var viewModel: SettingsViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            observations = self.observations(for: viewModel)
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.Terms.settings.localized
        downloadsCell.textLabel?.text = Strings.Terms.downloads.localized
        removeAllDownloadsCell.textLabel?.text = Strings.Actions.removeAllDownloads.localized
        signOutCell.textLabel?.text = Strings.Actions.signOut.localized

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.updateNotificationSettings()
    }

    @objc
    private func willEnterForeground() {
        viewModel?.updateNotificationSettings()
    }

    private func observations(for viewModel: SettingsViewModel) -> Set<NSKeyValueObservation> {
        return [
            viewModel.observe(\.areNotificationsAllowed) { [weak self] (_, _) in
                self?.view.setNeedsLayout()
            },
            viewModel.observe(\.areNotificationsEnabled) { [weak self] (_, _) in
                self?.view.setNeedsLayout()
            },
            viewModel.observe(\.areNotificationsProvisional, options: [.old, .new]) { [weak self] (_, change) in
                self?.areNotificationsProvisionalDidChange(change: change)
                self?.view.setNeedsLayout()
            },
        ]
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case .settings = route else { fatalError() }
        viewModel = SettingsViewModel()
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case documents, notifications, account

        static let showAlertsCellIndexPath = IndexPath(row: 2, section: Sections.notifications.rawValue)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .notifications? where !(viewModel?.areNotificationsEnabled ?? false): return 2
        default: return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?: return Strings.Terms.documents.localized
        case .notifications?: return "Notifications"
        case .account?, nil: return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?:
            return Strings.Callouts.downloadsSizeDisclaimer.localized
        case .account?:
            guard let currentUser = User.current else { return nil }
            let currentUserFullName = currentUser.nameComponents.formatted(style: .long)
            return Strings.Callouts.signedInAsAt.localized(currentUserFullName, currentUser.organization.title)
        case .notifications?, nil:
            return nil
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath) {
        case removeAllDownloadsCell?:
            removeAllDownloads()
        case configureNotificationsCell?:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url) { _ in }
        case showAlertsCell?:
            viewModel?.requestAlerts()
        case signOutCell?:
            signOut()
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    override func viewWillLayoutSubviews() {
        downloadsCell.detailTextLabel?.text = viewModel?.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
        notificationsSwitch.isEnabled = viewModel?.areNotificationsAllowed ?? false
        notificationsSwitch.isOn = viewModel?.areNotificationsEnabled ?? false
    }

    // MARK: Managing Downloads

    @IBOutlet var downloadsCell: UITableViewCell!

    @IBOutlet var removeAllDownloadsCell: UITableViewCell!

    private func removeAllDownloads() {
        let confirmation = UIAlertController(confirmationWithAction: removeAllDownloadsCell.textLabel?.text,
                                             sourceView: removeAllDownloadsCell) { _ in
            try? self.viewModel?.removeAllDownloads()
            self.view.setNeedsLayout()
        }
        present(confirmation, animated: true, completion: nil)
    }

    // MARK: Managing Notifications

    @IBOutlet var notificationsSwitch: UISwitch!

    @IBOutlet var configureNotificationsCell: UITableViewCell!

    @IBOutlet var showAlertsCell: UITableViewCell!

    @IBAction
    func notificationsSwitchValueChanged(_: Any) {
        viewModel?.areNotificationsEnabled.toggle()
        view.setNeedsLayout()
    }

    private func areNotificationsProvisionalDidChange(change: NSKeyValueObservedChange<Bool>) {
        guard change.oldValue != change.newValue else { return }

        tableView.update { tableView in
            if change.newValue ?? false {
                tableView.insertRows(at: [Sections.showAlertsCellIndexPath], with: .automatic)
            } else {
                tableView.deleteRows(at: [Sections.showAlertsCellIndexPath], with: .automatic)
            }
        }
    }

    // MARK: Signing Out

    @IBOutlet var signOutCell: UITableViewCell!

    private func signOut() {
        let confirmation = UIAlertController(confirmationWithAction: signOutCell.textLabel?.text, sourceView: signOutCell) { _ in
            self.performSegue(withRoute: .unwindToAppAndSignOut)
        }
        present(confirmation, animated: true, completion: nil)
    }
}
