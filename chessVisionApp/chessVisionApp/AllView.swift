import SwiftUI
import Firebase
import FirebaseFirestore

struct AllView: View {
    @State private var openings: [Opening] = []
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBarr(text: $searchText, placeholder: "Search for Openings")
                        .padding(.horizontal)

                    Text("All Openings")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 20)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)

                    let columns = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredOpenings) { opening in
                            NavigationLink(destination: OpeningDetail(opening: opening)) {
                                VStack {
                                    Text(opening.name)
                                        .padding(.bottom, -5)
                                    if let imageURL = URL(string: opening.imageURL) {
                                        AsyncImage(url: imageURL) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                fetchOpeningsFromFirebase()
            }
            .background(Color(red: 40/255, green: 39/255, blue: 39/255))
            .foregroundColor(.white)
        }
    }
    
    private var filteredOpenings: [Opening] {
        if searchText.isEmpty {
            return openings
        } else {
            return openings.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func fetchOpeningsFromFirebase() {
        let db = Firestore.firestore()
        db.collection("ChessOpening").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            self.openings = snapshot?.documents.compactMap { document in
                let data = document.data()
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let imageURL = data["imageURL"] as? String ?? ""
                let viewCountInt = data["viewCount"] as? Int ?? 0
                let viewCount = String(viewCountInt)
                let pros = data["pros"] as? [String] ?? []
                let cons = data["cons"] as? [String] ?? []
                
                // Handle variations
                var variations: [String: String] = [:]
                if let variationsData = data["variations"] as? [String: String] {
                    variations = variationsData
                }
                
                return Opening(name: name, imageURL: imageURL, description: description, pros: pros, cons: cons, viewCount: viewCount, variations: variations)
            } ?? []
        }
    }
    

}
struct Opening: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: String
    let description: String
    let pros: [String]
    let cons: [String]
    let viewCount: String
    let variations: [String: String]
}
struct All_Previews: PreviewProvider {
    static var previews: some View {
        AllView()
    }
}
