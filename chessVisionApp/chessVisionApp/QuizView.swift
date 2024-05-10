import SwiftUI
import Firebase
import FirebaseFirestore

struct Question: Identifiable {
    let id: String
    let text: String
    let correctAnswer: String
    let options: [String]
    let imageURL: String?
}

struct QuizView: View {
    @State private var highScore = 0
    @State private var score = 0
    @State private var currentQuestionIndex = 0
    @State private var questions: [Question] = []
    @State private var isQuizStarted = false // New state variable to track quiz start
    @State private var selectedOptionIndex: Int? // State to track the index of the selected option
    
    var body: some View {
        ZStack {
            Color(red: 40/255, green: 39/255, blue: 39/255)
                .ignoresSafeArea()
            
            if !isQuizStarted {
                // Start page
                VStack {
                    Text("Welcome to the Quiz!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Display high score on start page
                    Text("High Score: \(highScore)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    Button(action: {
                        // Start the quiz
                        isQuizStarted = true
                        fetchQuestionsFromFirebase()
                    }) {
                        Text("Start Quiz")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Quiz view
                VStack(spacing: 20) {
                    Text("Quiz")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Highest Score: \(highScore)")
                            .font(.system(size: 20))
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Score: \(score)")
                            .font(.system(size: 20))
                            .padding(.trailing, 20)
                    }
                    
                    // Display current question
                    if !questions.isEmpty && currentQuestionIndex < questions.count {
                        Text(questions[currentQuestionIndex].text)
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        // Display image if imageURL is available
                        if let imageURL = questions[currentQuestionIndex].imageURL,
                           let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding()
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        // Display options
                        ForEach(questions[currentQuestionIndex].options.indices, id: \.self) { index in
                            let option = questions[currentQuestionIndex].options[index]
                            Button(action: {
                                // Check if the selected option is correct
                                if option == questions[currentQuestionIndex].correctAnswer {
                                    score += 1
                                } else {
                                    // Mark the incorrect answer by setting selectedOptionIndex
                                    selectedOptionIndex = index
                                }
                                
                                // Always mark the correct answer by setting selectedOptionIndex
                                selectedOptionIndex = questions[currentQuestionIndex].options.firstIndex(of: questions[currentQuestionIndex].correctAnswer)
                                
                                // Move to the next question
                                nextQuestion()
                            }) {
                                HStack {
                                    Spacer()
                                    Text(option)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .background(selectedOptionIndex == index && option == questions[currentQuestionIndex].correctAnswer ? Color.green : selectedOptionIndex == index ? Color.red : Color.white) // Change background color to green for the correct answer option and red for the incorrect answer option
                                // this part still bug
                                .cornerRadius(10)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
                .foregroundColor(.white)
                .navigationTitle("Quiz")
            }
        }
    }
    
    private func fetchQuestionsFromFirebase() {
        let db = Firestore.firestore()
        db.collection("ChessQuestion").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            self.questions = snapshot?.documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                let text = data["question"] as? String ?? ""
                let correctAnswer = data["correctAnswer"] as? String ?? ""
                let options = data["option"] as? [String] ?? []
                let imageURL = data["imageURL"] as? String
                return Question(id: id, text: text, correctAnswer: correctAnswer, options: options, imageURL: imageURL)
            } ?? []
            
            // Shuffle the questions array
            self.questions.shuffle()
            
            // Reset currentQuestionIndex when questions are fetched
            currentQuestionIndex = 0
        }
    }
    
    private func nextQuestion() {
        // Move to the next question or end the quiz if all questions have been answered
        if currentQuestionIndex < questions.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Move to the next question
                self.currentQuestionIndex += 1
                // Reset selectedOptionIndex
                self.selectedOptionIndex = nil
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Update the high score if the current score is higher
                if score > highScore {
                    highScore = score
                }
                
                // Reset score and quiz state
                score = 0
                isQuizStarted = false
                // Reset selectedOptionIndex when starting over
                selectedOptionIndex = nil
            }

        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}
