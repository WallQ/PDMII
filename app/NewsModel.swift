import UIKit

struct NewsModel: Codable {
    let id: Int32
    let title : String
    let url : String?
    let imageUrl : String
    let newsSite : String
    let summary : String
    let publishedAt: String?
    let updatedAt: String
    let fav: Bool?
    
    
    
}
