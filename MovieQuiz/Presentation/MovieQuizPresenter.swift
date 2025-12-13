//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by bot on 13.12.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
       
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
       currentQuestionIndex += 1
    }
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    

    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    func yesButtonClicked() {
        // Блокируем кнопки сразу при нажатии
        viewController?.setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
       // guard let currentQuestion else {
         //          return
         //   }
        let givenAnswer = true
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        // Блокируем кнопки сразу при нажатии
        viewController?.setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
