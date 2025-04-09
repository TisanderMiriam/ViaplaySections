import UIKit

class SectionsTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDynamicTypeObserver()
        fetchRootPage()
    }
    
    private func setupDynamicTypeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
    }
    
    @objc private func handleContentSizeCategoryDidChange(notification: Notification) {
        let dynamicFont = UIFont.preferredFont(forTextStyle: .footnote)
        let attributes: [NSAttributedString.Key: Any] = [.font: dynamicFont]
        
        if let items = tabBar.items {
            for item in items {
                item.setTitleTextAttributes(attributes, for: .normal)
                item.setTitleTextAttributes(attributes, for: .selected)
            }
        }
    }
    
    
    private func fetchRootPage() {
        guard let url = URL(string: "https://content.viaplay.com/ios-se") else {
            print("Invalid root URL")
            return
        }
        
        // Attempt to load a cached Page first.
        if let cachedPage = loadCachedPage(for: url) {
            setupTabs(with: cachedPage)
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching root page: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received for root page")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let rootPage = try decoder.decode(Page.self, from: data)
                DispatchQueue.main.async {
                    self.setupTabs(with: rootPage)
                }
                self.saveCachedPage(rootPage, for: url)
            } catch {
                print("Error decoding root page: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func setupTabs(with rootPage: Page) {
        let sectionsLinks = rootPage.links.sections
        var viewControllers: [UIViewController] = []
        
        for sectionLink in sectionsLinks {
            let title = sectionLink.tabTitle ?? "Section"
            let pageVC = PageViewController(href: sectionLink.href)
            pageVC.navigationItem.title = title
            
            let navVC = UINavigationController(rootViewController: pageVC)
            navVC.tabBarItem.title = title
            viewControllers.append(navVC)
        }
        
        self.viewControllers = viewControllers
    }
    
    // MARK: - Offline Caching Helpers
    
    /// Safely returns a file URL in the caches directory based on the given URL.
    private func cacheFileURL(for url: URL) -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "page_cache"
        return cachesDirectory.appendingPathComponent(fileName)
    }
    
    /// Saves a Page object as JSON to the caches directory.
    private func saveCachedPage(_ page: Page, for url: URL) {
        let fileURL = cacheFileURL(for: url)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(page)
            try data.write(to: fileURL)
        } catch {
            print("Error caching page: \(error.localizedDescription)")
        }
    }
    
    /// Loads a cached Page object from the caches directory if it exists.
    private func loadCachedPage(for url: URL) -> Page? {
        let fileURL = cacheFileURL(for: url)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let cachedPage = try decoder.decode(Page.self, from: data)
                return cachedPage
            } catch {
                print("Error loading cached page: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
