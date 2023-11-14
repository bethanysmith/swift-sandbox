//
//  DependencyInjectionSandbox.swift
//  SwiftSandbox
//
//  Created by Bethany Smith on 14/11/2023.
//

import SwiftUI
import Combine

struct PostsModel: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class UrlDataService: DataServiceProtocol {
    
    let url: URL
    
    init(url: URL?) {
        self.url = url ?? URL(string: "https://jsonplaceholder.typicode.com/posts")!
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostsModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class MockDataService : DataServiceProtocol{
    
    let testData: [PostsModel]
    
    init(data: [PostsModel]?) {
        self.testData = data ?? [
            PostsModel(userId: 1, id: 1, title: "one", body: "one"),
            PostsModel(userId: 2, id: 2, title: "two", body: "two")
        ]
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        Just(testData)
            .tryMap({ $0 })
            .eraseToAnyPublisher()
    }
}

protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostsModel], Error>
}

class DependencyInjectionViewModel: ObservableObject {
    
    @Published var dataArray: [PostsModel] = []
    var cancellables = Set<AnyCancellable>()
    let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            }
            .store(in: &cancellables)
    }
}

struct DependencyInjectionView: View {
    
    @StateObject private var viewModel: DependencyInjectionViewModel
    
    init(dataService: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: DependencyInjectionViewModel(dataService: dataService))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("List of posts")
                    .font(Font.title.weight(.heavy))
                    .frame(width: 340, alignment: .leading)
                ForEach(viewModel.dataArray) { post in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.title)
                            .padding(.horizontal)
                            .font(Font.headline.weight(.medium))
                            .frame(width: 340, alignment: .leading)
                        
                        Text(post.body)
                            .padding(.horizontal)
                            .font(Font.footnote.weight(.light))
                            .frame(width: 340, alignment: .leading)
                    }
                    .fixedSize(horizontal: false, vertical: false)
                    .padding()
                    .frame(width: 350)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4))
                }
            }
            .padding(.top)
        }
        .fixedSize(horizontal: false, vertical: false)
        .frame(width: 600)
        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

struct DependencyInjectionView_Previews: PreviewProvider {

    static let dataService = UrlDataService(url: nil)
    
//    static let dataService = MockDataService(data: nil)
    
    static var previews: some View {
        DependencyInjectionView(dataService: dataService)
    }
}
