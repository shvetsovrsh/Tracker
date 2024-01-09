//
// Created by Ruslan S. Shvetsov on 09.01.2024.
//

import UIKit


final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var onOnboardingCompleted: (() -> Void)?

    private let firstPageOnboardingView = OnboardingView()
    private let secondPageOnboardingView = OnboardingView()
    var pages: [UIViewController] = []

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private let startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()

    init(onOnboardingCompleted: @escaping () -> Void) {
        self.onOnboardingCompleted = onOnboardingCompleted
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func startButtonTapped() {
        onOnboardingCompleted?()
    }

    private func createOnboardingPage(imageName: String, text: String) -> UIViewController {
        let onboardingView = OnboardingView()
        onboardingView.configure(with: UIImage(named: imageName), text: text)

        let page = UIViewController()
        page.view.addSubview(onboardingView)
        onboardingView.frame = page.view.bounds
        onboardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return page
    }

    private func setupPages() {
        let firstPage = createOnboardingPage(imageName: "firstOnboardingPage",
                text: "Отслеживайте только то, что хотите")
        let secondPage = createOnboardingPage(imageName: "secondOnboardingPage",
                text: "Даже если это не литры воды и йога")

        pages = [firstPage, secondPage]
    }

    private func setupPageControl() {
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupStartButton() {
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }

    private func configurePageViewController() {
        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPages()
        setupPageControl()
        setupStartButton()
        configurePageViewController()
    }


    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return pages.last
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return pages.first
        }

        return pages[nextIndex]
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
