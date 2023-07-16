import Foundation

class DetailViewModel: ObservableObject {
    var images: [String]
    
    public init(images: [String]) {
        self.images = images
    }
}
