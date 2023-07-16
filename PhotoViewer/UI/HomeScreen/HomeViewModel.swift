import Foundation
import Combine

class HomeViewModel: ObservableObject {
    let images = ["cat1", "cat2", "cat3", "cat4", "cat5", "cat6", "cat7"]
    
    private let networkManager = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        let url = "https://pexelsdimasv1.p.rapidapi.com/v1/search?query=world&locale=en-US&per_page=15&page=1"
        let headers = [
            "Authorization": "<REQUIRED>",
            "X-RapidAPI-Key": "ddce45999amsh588fa7631557c3ap11a3f0jsnb48f7b18929f",
            "X-RapidAPI-Host": "PexelsdimasV1.p.rapidapi.com"
        ]
        let publisher: AnyPublisher<[ImageDTO]?, Error> = networkManager.request(httpMethod: .get, url: url, headers: headers)
        publisher.sink { completion in
            switch completion {
            case .failure(let error):
                print("DEBUG: finish with \(error)")
            case .finished:
                print("DEBUG: FINISH")
            }
        } receiveValue: { images in
            guard let images = images else {
                print("ERROR WITH IMAGES IN RECIVE VALUE")
                return
            }
        }
        .store(in: &cancellables)
    }
}
