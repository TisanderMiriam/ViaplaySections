import UIKit

class PageViewController: UIViewController {
    var page: Page?
    var href: String?    //TODO: Maybe remove? Don't need this for this simple test?
    
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
       
       if let href = href {
           fetchSectionPage(from: href)
       } else {
           updateUI()
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
    
    // MARK: - Data Loading
//TODO: Remove? not sure I need this.
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
           let page = try decoder.decode(Page.self, from: data)
           self.page = page
           
           self.updateUI()
         } catch {
           print("Error decoding section page: \(error.localizedDescription)")
         }
       }.resume()
    }
    
    // Updates the UI elements on the main thread.
    private func updateUI() {
       DispatchQueue.main.async {
         self.titleLabel.text = self.page?.title
         self.descriptionLabel.text = self.page?.description
         self.navigationItem.title = self.page?.title
       }
    }
}
