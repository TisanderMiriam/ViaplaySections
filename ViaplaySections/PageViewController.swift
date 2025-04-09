import UIKit

class PageViewController: UIViewController {
    private var page: Page?
    private var href: String
    
    // MARK: - UI Elements
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    init(href: String) {
        self.href = href
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        fetchSectionPage(from: href)
    }
    
    private func setupViews() {
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.descriptionLabel.text = self.page?.description
        }
    }
    
    // Fetches the complete Page from the URL specified in href.
    private func fetchSectionPage(from urlString: String) {
        // Remove any URI templating by keeping only the part of the string before the "{".
        let cleanUrlString = urlString.components(separatedBy: "{").first ?? urlString
        guard let url = URL(string: cleanUrlString) else {
            print("Invalid URL string: \(cleanUrlString)")
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
                print("Fetched page: \(fetchedPage)")
                self.updateUI()
            } catch {
                print("Error decoding section page: \(error.localizedDescription)")
            }
        }.resume()
    }

}
