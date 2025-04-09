import UIKit

struct Page: Codable {
    let title: String
    let description: String
    let pageType: String
    let links: PageLinks

    private enum CodingKeys: String, CodingKey {
        case title, description, pageType
        case links = "_links"
    }
}

struct PageLinks: Codable {
    let sections: [Link]

    private enum CodingKeys: String, CodingKey {
        case sections = "viaplay:sections"
    }
}

struct Link: Codable {
    let title: String
    let href: String
}
