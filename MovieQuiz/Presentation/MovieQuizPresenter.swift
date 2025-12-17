//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by bot on 13.12.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
            self.viewController = viewController
            
            statisticService = StatisticService()
        
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    // MARK: - QuestionFactoryDelegate
        
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
    func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
        }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
                    correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
       currentQuestionIndex += 1
    }
    // метод конвертации, который принимает вопрос и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswer(isYes: false)
        }
    
    private func didAnswer(isYes: Bool) {
        // Блокируем кнопки сразу при нажатии
        viewController?.setButtonsEnabled(false)
           guard let currentQuestion = currentQuestion else {
               return
           }
           
           let givenAnswer = isYes
           
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    func proceedWithAnswer(isCorrect: Bool) {
    
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            // Сохраняем результаты в статистику
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            // Получаем статистику для отображения
                       let bestGame = statisticService.bestGame
                       let totalGames = statisticService.gamesCount
                       let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
                       
                       // Форматируем дату лучшей игры
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                       let bestGameDate = dateFormatter.string(from: bestGame.date)
            
            // Формируем текст с результатами и статистикой
            let currentResultText = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
                        let message = """
                        \(currentResultText)
                        Количество сыгранных квизов: \(totalGames)
                        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))
                        Средняя точность: \(totalAccuracy)%
                        """
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel) // 3
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
