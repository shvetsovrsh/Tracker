//
// Created by Ruslan S. Shvetsov on 18.12.2023.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBarAppearance()
        setupViewControllers()
    }

    private func setupTabBarAppearance() {
        tabBar.backgroundColor = UIColor(named: "YPWhite")
        tabBar.barTintColor = UIColor(named: "YPBlue")
        tabBar.tintColor = UIColor(named: "YPBlue")

        let separatorLine = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tabBar.addSubview(separatorLine)
    }

    private func setupViewControllers() {
        let trackersViewController = TrackersViewController(
                categories: [],
                visibleCategories: [],
                completedTrackers: [],
                currentDate: Date()
        )

        let statisticsViewController = StatisticViewController()
        let trackersViewControllerTitle = NSLocalizedString("TabBarViewController.trackersViewController.tabBarItem", comment: "")
        let statisticsViewControllerTitle = NSLocalizedString("TabBarViewController.statisticsViewController.tabBarItem", comment: "")

        trackersViewController.tabBarItem = UITabBarItem(title: trackersViewControllerTitle, image: UIImage(named: "trackersIcon"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statisticsViewControllerTitle, image: UIImage(named: "statisticsIcon"), tag: 1)

        viewControllers = [trackersViewController, statisticsViewController]
    }
}
