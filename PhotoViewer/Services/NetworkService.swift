import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class NetworkManager {
    func request<T: Codable>(httpMethod: HTTPMethod, url: String, headers: [String : String]?) -> AnyPublisher<T?, Error> {
        guard let url = URL(string: url) else {
            fatalError("DEBUG: Error with URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        } else {
            print("DEBUG: ERROR WITH HEADERS")
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> T? in
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode <= 300
                else {
                    throw URLError(.badServerResponse)
                }
                let data = try? JSONDecoder().decode(T.self, from: data)
                return data
            }
            .mapError {
                return $0
            }
            .eraseToAnyPublisher()
    }
}
