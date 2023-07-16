import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()
    @State private var isActive = false
    @State private var tappedImage = "cat1"
    @State private var tappedIndex = 0
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.images.indices, id: \.self) { index in
                        Image(viewModel.images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth / 3, height: screenWidth / 3)
                            .clipped()
                            .onTapGesture {
                                tappedIndex = index
                                tappedImage = viewModel.images[tappedIndex]
                                isActive = true
                            }
                            .sheet(isPresented: $isActive) {
                                DetailScreen(viewModel: .init(images: viewModel.images), index: $tappedIndex)
                            }
                    }
                }
            }
            .padding(.top, 1)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
