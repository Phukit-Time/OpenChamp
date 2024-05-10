import SwiftUI
import Firebase
import FirebaseFirestore

struct OpeningDetail: View {
    var opening: Opening
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                HStack{
                    Text(opening.name)
                        .font(.title.bold())
                        .padding()
                    
                    HStack {
                        Image(systemName: "eye")
                            .font(.headline)

                        Text("\(opening.viewCount)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 20)
                
                Text("Starting Position")
                    .font(.title)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 0)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                if let imageURL = URL(string: opening.imageURL) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.horizontal, 20)
                }
                
                
                Text("Description")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                Text(opening.description)
                    .padding()
                
                Text("Pros")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(opening.pros, id: \.self) { pro in
                        Text("• \(pro)")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                
                Text("Cons")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(opening.cons, id: \.self) { con in
                        Text("• \(con)")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Text("Variations")
                    .font(.title)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                if let imageURL = URL(string: opening.imageURL) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.horizontal, 20)
                }
                // Convert variations dictionary to array of key-value pairs
                ForEach(opening.variations.sorted(by: { $0.key < $1.key }), id: \.key) { variation in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(variation.key)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(variation.value)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        .background(Color(red: 40/255, green: 39/255, blue: 39/255))
        .foregroundColor(.white)
        .navigationTitle(opening.name)
        .onAppear {
            incrementViewCount(for: opening)
        }
    }
    
    private func incrementViewCount(for opening: Opening) {
        let db = Firestore.firestore()
        let query = db.collection("ChessOpening").whereField("name", isEqualTo: opening.name)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching opening document: \(error)")
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("Opening document not found")
                return
            }
            
            let docRef = document.reference
            docRef.updateData(["viewCount": FieldValue.increment(Int64(1))]) { error in
                if let error = error {
                    print("Error updating view count: \(error)")
                } else {
                    print("View count updated successfully")
                }
            }
        }
    }
}
