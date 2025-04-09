import UIKit

class PageViewController: UIViewController {
    private var page: Page?
    private let href: String
    
    // MARK: - UI Elements
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    /// Initialize with only an href. The page data will be fetched (or loaded from cache) using this href.
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
        view.backgroundColor = UIColor.systemBackground
        setupViews()
        // First try to load from cache.
        if let cachedPage = self.loadCachedPage(for: href) {
            self.page = cachedPage
            updateUI()
        }
        // Then fetch from the network.
        fetchSectionPage(from: href)
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - UI Update
    private func updateUI() {
        guard let page = self.page else { return }
        DispatchQueue.main.async {
            self.descriptionLabel.text = page.description
        }
    }
    
    // MARK: - Network Fetch

    private func fetchSectionPage(from urlString: String) {
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
                self.updateUI()
                self.saveCachedPage(fetchedPage, for: url)
            } catch {
                print("Error decoding section page: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: - Offline Caching Helpers
    
    private func cacheFileURL(for url: URL) -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "page_cache"
        return cachesDirectory.appendingPathComponent(fileName)
    }

    
    /// Saves the Page object to the local cache (as JSON data).
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
    
    /// Loads a cached Page (if available) for a given href.
    private func loadCachedPage(for href: String) -> Page? {
        let cleanUrlString = href.components(separatedBy: "{").first ?? href
        guard let url = URL(string: cleanUrlString) else { return nil }
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
