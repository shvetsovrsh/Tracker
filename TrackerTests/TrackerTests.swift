//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ruslan S. Shvetsov on 20.01.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    var sut: TrackersViewController?

    override func setUp() {
        super.setUp()

        sut = TrackersViewController(
                categories: [],
                visibleCategories: [],
                completedTrackers: [],
                currentDate: Date()
        )
        sut?.loadViewIfNeeded()
    }

    func testTrackersViewController() {
        let size = CGSize(width: 375, height: 812)
        let config = ViewImageConfig.iPhoneX
        assertSnapshot(matching: sut!, as: .image(on: config, size: size))
    }

    func testTrackersViewControllerLight() {
        let size = CGSize(width: 375, height: 812)
        assertSnapshot(matching: sut!, as: .image(on: .iPhoneX(.portrait), size: size, traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersViewControllerDark() {
        let size = CGSize(width: 375, height: 812)
        assertSnapshot(matching: sut!, as: .image(on: .iPhoneX(.portrait), size: size, traits: .init(userInterfaceStyle: .dark)))
    }
}
