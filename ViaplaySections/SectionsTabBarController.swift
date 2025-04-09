import UIKit

class SectionsTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRootPage()
    }
    /// Fetch the root page from the API and then set up the tabs for each section.
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
                let sectionsLinks = rootPage.links.sections
                
                DispatchQueue.main.async {
                    var viewControllers: [UIViewController] = []
                    for sectionLink in sectionsLinks {
                        // Initialize PageViewController with the section's own href.
                        let title = sectionLink.tabTitle ?? "Section"
                        let pageVC = PageViewController(href: sectionLink.href)
                        pageVC.navigationItem.title = title
                        let navVC = UINavigationController(rootViewController: pageVC)
                        
                        navVC.tabBarItem.title = title
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
