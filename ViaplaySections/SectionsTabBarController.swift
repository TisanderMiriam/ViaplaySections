import UIKit

class SectionsTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRootPage()
    }
    
    /// Fetches the root page from the API, then sets up the tabs based on section links.
    private func fetchRootPage() {
        guard let url = URL(string: "https://content.viaplay.com/ios-se") else {
            print("Invalid root URL")
            return
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
                if rootPage.pageType != "root" {
                    print("Expected pageType 'root', got \(rootPage.pageType)")
                    return
                }
                guard let links = rootPage.links else {
                    print("No _links found in root page")
                    return
                }
                let sectionsLinks = links.sections
                
                // Create a view controller for each section on the main thread.
                DispatchQueue.main.async {
                    
                    // Create a view controller for each section.
                    var viewControllers: [UIViewController] = []
                    for sectionLink in sectionsLinks {
                        let pageVC = PageViewController()
                        pageVC.href = sectionLink.href
                        pageVC.navigationItem.title = sectionLink.title
                        
                        // Wrap in a navigation controller (so that the navigation bar is shown and the tab bar remains).
                        let navVC = UINavigationController(rootViewController: pageVC)
                        navVC.tabBarItem.title = sectionLink.title
                        viewControllers.append(navVC)
                    }
                    
                    self.viewControllers = viewControllers
                }
            } catch {
                print("Error decoding root page: \(error.localizedDescription)")
            }
        }.resume()
    }
}
