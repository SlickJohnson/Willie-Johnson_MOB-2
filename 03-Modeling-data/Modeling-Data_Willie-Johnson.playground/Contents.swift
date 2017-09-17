import Foundation
import PlaygroundSupport

struct Listing {
    let bathrooms: Double
    let bedrooms: Int
    let beds: Int
    let city: String
    
    init(bathrooms: Double, bedrooms: Int, beds: Int, city: String) {
        self.bathrooms = bathrooms
        self.bedrooms = bedrooms
        self.beds = beds
        self.city = city
    }
}

extension Listing: Decodable {
    enum SearchResultKeys: String, CodingKey
    {
        case listing
    }
    
    enum ListingKeys: String, CodingKey {
        case bathrooms
        case bedrooms
        case beds
        case city
    }
    
    init(from decoder: Decoder) throws {
        // Search results
        let searchResultsContainer = try decoder.container(keyedBy: SearchResultKeys.self)
        
        // Listings
        let listingContainer = try searchResultsContainer.nestedContainer(keyedBy: ListingKeys.self, forKey: .listing)
        
        let bathrooms = try listingContainer.decode(Double.self, forKey: .bathrooms)
        let bedrooms = try listingContainer.decode(Int.self, forKey: .bedrooms)
        let beds = try listingContainer.decode(Int.self, forKey: .beds)
        let city = try listingContainer.decode(String.self, forKey: .city)
        
        self.init(bathrooms: bathrooms, bedrooms: bedrooms, beds: beds, city: city)
    }
}

struct ListingList: Decodable {
    let search_results: [Listing]
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum ListingError: Error {
    case couldNotParse
    case noData
}

class Networking {
    func fetchListingResult(completion: @escaping (Result<[Listing]>) -> Void) {
        let session = URLSession.shared
    
        let url = URL(string: "https://api.airbnb.com/v2/search_results?key=915pw2pnf4h1aiguhph5gc5b2")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { (data, response, error) -> Void in
            
            if let error = error {
                return completion(Result.failure(error))
            }
            
            guard let data = data else {
                return completion(Result.failure(ListingError.noData))
            }
        
            guard let listingList = try? JSONDecoder().decode(ListingList.self, from: data) else {
                return completion(Result.failure(ListingError.couldNotParse))
            }
            
            completion(Result.success(listingList.search_results))
        }.resume()
    }
}

let networking = Networking()
networking.fetchListingResult { (listing) in
    print(listing)
}

PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

