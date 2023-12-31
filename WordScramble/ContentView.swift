//
//  ContentView.swift
//  WordScramble
//
//  Created by Muhammad Fahmi on 27/08/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var usedWordsCount = 0
    
//    Challenge
//    1. One of the best ways to learn is to write your own code as often as possible, so here are three ways you should try extending this app to make sure you fully understand what’s going on:
//
//    2. Disallow answers that are shorter than three letters or are just our start word.
//    Add a toolbar button that calls startGame(), so users can restart with a new word whenever they want to.
//    3. Put a text view somewhere so you can track and show the player’s score for a given root word. How you calculate score is down to you, but something involving number of words and their letter count would be reasonable.
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    Text("\(usedWordsCount)")
                        .font(.largeTitle)
                } header: {
                    Text("Score")
                }
                Section{
                    TextField("", text: $newWord)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("Answer here")
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text("\(word)")
                        }
                    }
                }
            }

            .navigationTitle(rootWord)
            .onSubmit(addWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar(){
                Button("Restart", action: startGame)
            }
        }

    }
    
    func startGame() {
        usedWordsCount = 0
        usedWords = []
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func addWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard newWord.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isEnough(word: answer) else {
            wordError(title: "Word is not enough", message: "Try at least 3 letter!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        
        usedWordsCount += answer.count*1
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isEnough(word: String) -> Bool{
        word.count > 2
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
