//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by bot on 21.10.2025.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // Массив для отслеживания уже заданных вопросов
   private var usedQuestions: [QuizQuestion] = []
    // Массив доступных вопросов (изначально все вопросы)
   private var availableQuestions: [QuizQuestion] = []
    
   init() {
        resetQuestions()
    }
    
    weak var delegate: QuestionFactoryDelegate?
    
    func requestNextQuestion() {
           // Если доступные вопросы закончились, возвращаем nil
           guard !availableQuestions.isEmpty else {
               delegate?.didReceiveNextQuestion(question: nil)
               return
           }
           
           // Выбираем случайный вопрос из доступных
           guard let randomIndex = (0..<availableQuestions.count).randomElement() else {
              delegate?.didReceiveNextQuestion(question: nil)
               return
          }
           
           let question = availableQuestions[randomIndex]
           
           // Удаляем заданный вопрос из доступных и добавляем в использованные
          availableQuestions.remove(at: randomIndex)
           usedQuestions.append(question)
           
           delegate?.didReceiveNextQuestion(question: question)
       }
       
       // Метод для сброса и перемешивания вопросов при новом запуске игры
      func resetQuestions() {
           // Перемешиваем все вопросы
           availableQuestions = questions.shuffled()
           // Очищаем историю использованных вопросов
           usedQuestions.removeAll()
      }
   }
    
