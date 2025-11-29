//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by bot on 06.11.2025.
//

import Foundation

final class StatisticService {
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    private let storage: UserDefaults = .standard
    private var totalCorrectAnswers: Int {
            get {
                storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
            }
        }
        
        private var totalQuestionsAsked: Int {
            get {
                storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
            }
        }
}


extension StatisticService: StatisticServiceProtocol {
    var bestGame: GameResult {
        get {
            // Чтение значений полей GameResult(correct, total и date) из storage
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            
            // Для получения даты (Date) используем метод object(forKey:), затем безопасно приводим тип Any к Date
            let date: Date
            if let savedDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                date = savedDate
            } else {
                // Если значения ещё не было, используем текущую дату Date()
                date = Date()
            }
            
            // Создаем GameResult от полученных значений
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Запись значений каждого поля из newValue в storage
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
           get {
               // отношение общего числа правильных ответов
               // ко всем заданным вопросам за все игры
               let correct = totalCorrectAnswers
               let total = totalQuestionsAsked
               
               // Избегаем деления на ноль
               guard total > 0 else {
                   return 0
               }
               
               // Вычисляем процент правильных ответов
               let accuracy = Double(correct) / Double(total) * 100
               return accuracy
           }
       }
    
    func store(correct count: Int, total amount: Int) {
        // Обновляем общее количество правильных ответов
        totalCorrectAnswers += count
               
        // Обновляем общее количество заданных вопросов
        totalQuestionsAsked += amount
               
        // Увеличиваем счетчик игр
        gamesCount += 1
               
         
      // Проверяем и сохраняем лучший результат
         
        let currentGame = GameResult(correct: count, total: amount, date: Date())
               
         
        if currentGame.correct > bestGame.correct {
            bestGame = currentGame
        }
     }
    
    var gamesCount: Int {
            get {
                storage.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
        }
}
