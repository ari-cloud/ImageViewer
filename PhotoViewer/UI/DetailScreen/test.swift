//import SwiftUI
//import Combine
//
//struct test: View {
//    @State private var didZoom = true
//    @State private var defaultZoom: CGFloat = 1
//    @State private var zoomScale: CGFloat = 1
//    private let updateView = PassthroughSubject<Void, Never>()
//    
//    var body: some View {
//        ZStack {
//            Color.black
//                .ignoresSafeArea()
//            ZoomableScrollView(didZoom: $didZoom, defaultZoom: $defaultZoom, zoomScale: $zoomScale, updateView: updateView) {
//                Image("cat1")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: UIScreen.main.bounds.width)
//                    .onAppear {
//                        updateView.send()
//                    }
//            }
//        }
//    }
//}
//
//
//struct ZoomableScrollView<Content: View>: UIViewControllerRepresentable {
//    
//    @Binding var didZoom: Bool
//    @Binding private var defaultZoom: CGFloat
//    @Binding private var zoomScale: CGFloat
//    private let updateView: PassthroughSubject<Void, Never>
//
//    private var content: Content
//
//    init(didZoom: Binding<Bool>,
//         defaultZoom: Binding<CGFloat>,
//         zoomScale: Binding<CGFloat>,
//         updateView: PassthroughSubject<Void, Never>,
//         @ViewBuilder content: () -> Content) {
//        _didZoom = didZoom
//        self.content = content()
//        self.updateView = updateView
//        _zoomScale = zoomScale
//        _defaultZoom = defaultZoom
//    }
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        ViewController(coordinator: context.coordinator, defaultZoom: $defaultZoom, zoomScale: $zoomScale, updateView: updateView)
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
//    
//    class ViewController: UIViewController, UIScrollViewDelegate {
//        
//        private let coordinator: Coordinator
//        private let defaultZoom: Binding<CGFloat>
//        private let zoomScale: Binding<CGFloat>
//        private var hostedView: UIView { coordinator.hostingController.view }
//        private let updateView: PassthroughSubject<Void, Never>
//        private var cancellables = Set<AnyCancellable>()
//        private let scrollView = CenterScrollView()
//        private var contentSizeConstraints: [NSLayoutConstraint] = [] {
//            willSet { NSLayoutConstraint.deactivate(contentSizeConstraints) }
//            didSet { NSLayoutConstraint.activate(contentSizeConstraints) }
//        }
//        
//        init(coordinator: Coordinator,
//             defaultZoom: Binding<CGFloat>,
//             zoomScale: Binding<CGFloat>,
//             updateView: PassthroughSubject<Void, Never>) {
//            self.coordinator = coordinator
//            self.defaultZoom = defaultZoom
//            self.updateView = updateView
//            self.zoomScale = zoomScale
//            super.init(nibName: nil, bundle: nil)
//            view = scrollView
//            
//            scrollView.delegate = self
//            scrollView.showsVerticalScrollIndicator = false
//            scrollView.showsHorizontalScrollIndicator = false
//            scrollView.maximumZoomScale = 5
//            scrollView.minimumZoomScale = 1
//            scrollView.bouncesZoom = true
//            
//            
//            hostedView.translatesAutoresizingMaskIntoConstraints = false
//            
//            scrollView.addSubview(hostedView)
//            NSLayoutConstraint.activate([
//                hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//                hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//                hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//                hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
//            ])
//            
//            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
//            doubleTapGesture.numberOfTapsRequired = 2
//            scrollView.addGestureRecognizer(doubleTapGesture)
//            
//            updateView
//                .sink { [weak self] in
//                    self?.updateContentView()
//                }
//                .store(in: &cancellables)
//        }
//        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        
//        private func updateContentView() {
//            scrollView.zoom(to: hostedView.bounds, animated: false)
//            defaultZoom.wrappedValue = scrollView.zoomScale
//        }
//        
//        override func updateViewConstraints() {
//            super.updateViewConstraints()
//            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
//            contentSizeConstraints = [
//                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
//                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
//            ]
//        }
//
//        override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
//            scrollView.minimumZoomScale = min(scrollView.bounds.width / hostedContentSize.width, scrollView.bounds.height / hostedContentSize.height)
//        }
//
//        func scrollViewDidZoom(_ scrollView: UIScrollView) {
//            self.scrollView.centerView()
//            zoomScale.wrappedValue = scrollView.zoomScale
//        }
//        
//        @objc
//        private func handleDoubleTap(sender: UITapGestureRecognizer) {
//            let scalePoint = sender.location(in: hostedView)
//            let zoomScale = scrollView.zoomScale == scrollView.minimumZoomScale ? 5 : scrollView.minimumZoomScale
//            let width = scrollView.bounds.size.width / zoomScale
//            let height = scrollView.bounds.size.height / zoomScale
//            let rect = CGRect(x: scalePoint.x - (width * 0.5), y: scalePoint.y - (height * 0.5), width: width, height: height)
//            scrollView.zoom(to: rect, animated: true)
//        }
//        
//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            hostedView
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(hostingController: UIHostingController(rootView: self.content), didZoom: $didZoom)
//    }
//
//    func updateUIView(_ uiView: UIScrollView, context: Context) {
//        context.coordinator.hostingController.rootView = self.content
//        assert(context.coordinator.hostingController.view.superview == uiView)
//    }
//
//    class Coordinator: NSObject, UIScrollViewDelegate {
//
//        var hostingController: UIHostingController<Content>
//        @Binding var didZoom: Bool
//
//        init(hostingController: UIHostingController<Content>, didZoom: Binding<Bool>) {
//            self.hostingController = hostingController
//            _didZoom = didZoom
//        }
//
//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            return hostingController.view
//        }
//
//        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//            didZoom = !(scrollView.zoomScale == scrollView.minimumZoomScale)
//        }
//    }
//}
//
//private class CenterScrollView: UIScrollView {
//    func centerView() {
//        subviews[0].frame.origin.x = max(0, bounds.width - subviews[0].frame.width) / 2
//        subviews[0].frame.origin.y = max(0, bounds.height - subviews[0].frame.height) / 2
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        centerView()
//    }
//}


//struct test_Previews: PreviewProvider {
//    static var previews: some View {
//        test()
//    }
//}
