//
//  Created by Ruslan S. Shvetsov on 01.09.2023.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        if UserDefaults.standard.hasSeenOnboarding {
            window.rootViewController = TabBarViewController()
        } else {
            window.rootViewController = OnboardingViewController { [weak window] in
                window?.rootViewController = TabBarViewController()
                UserDefaults.standard.hasSeenOnboarding = true
            }
        }

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
