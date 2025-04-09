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
    let selfLink: Link

    private enum CodingKeys: String, CodingKey {
        case sections = "viaplay:sections"
        case selfLink = "self"
    }
}

struct Link: Codable {
    let tabTitle: String?
    let href: String
    
    private enum CodingKeys: String, CodingKey {
        case tabTitle = "title"
        case href
    }
}
