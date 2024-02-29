//
//  WordModel.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 22.02.2024.
//

import Foundation

struct WordModel: Codable {
    let word: String
    let options: [String]
    let answer: String
    var choose: Bool?
    var know: Bool?
}

struct QuestionsData: Codable {
    var questions: [WordModel]
}
