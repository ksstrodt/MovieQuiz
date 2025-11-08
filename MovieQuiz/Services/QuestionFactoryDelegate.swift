//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by bot on 25.10.2025.
//

import Foundation
// Создаем протокол QuestionFactoryDelegate, который используется в фабрике как делегата
protocol QuestionFactoryDelegate: AnyObject {
 // Объявляем метод, который должен быть у делегата фабрики — его будет вызывать фабрика, чтобы отдать готовый вопрос квиза.
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
