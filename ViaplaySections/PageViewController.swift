import UIKit

class PageViewController: UIViewController {
    var page: Page?
    var href: String?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
       label.numberOfLines = 0
       label.textAlignment = .center
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 16)
       label.numberOfLines = 0
       label.textAlignment = .center
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
       super.viewDidLoad()
       view.backgroundColor = .white
       setupViews()
       
       // If a Page has been set (from first fetch) update UI.
       // Otherwise, if only href is provided, then fetch the section page.
       if let _ = page {
           updateUI()
       } else if let href = href {
           fetchSectionPage(from: href)
       }
    }
    
    private func setupViews() {
       view.addSubview(titleLabel)
       view.addSubview(descriptionLabel)
       
       DispatchQueue.main.async {
           NSLayoutConstraint.activate([
               // Title Label Constraints
               self.titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
               self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
               self.titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
               
               // Description Label Constraints
               self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),
               self.descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
               self.descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
           ])
       }
    }
    
    private func updateUI() {
       DispatchQueue.main.async {
         self.titleLabel.text = self.page?.title
         self.descriptionLabel.text = self.page?.description
       }
    }
    
    // In case you need to fetch a section page from its href
    private func fetchSectionPage(from urlString: String) {
       guard let url = URL(string: urlString) else {
         print("Invalid URL string: \(urlString)")
         return
       }
       URLSession.shared.dataTask(with: url) { data, response, error in
         if let error = error {
           print("Error fetching section page: \(error.localizedDescription)")
           return
         }
         guard let data = data else {
           print("No data received for section page")
           return
         }
         let decoder = JSONDecoder()
         do {
           let fetchedPage = try decoder.decode(Page.self, from: data)
           self.page = fetchedPage
           self.updateUI()
         } catch {
           print("Error decoding section page: \(error.localizedDescription)")
         }
       }.resume()
    }
}
