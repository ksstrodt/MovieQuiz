import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton! 
    @IBOutlet private var noButton: UIButton!
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        // Блокируем кнопки сразу при нажатии
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // Блокируем кнопки сразу при нажатии
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
    }
    
    // Метод для включения/выключения кнопок
        private func setButtonsEnabled(_ enabled: Bool) {
            yesButton.isEnabled = enabled
            noButton.isEnabled = enabled
            
            yesButton.alpha = enabled ? 1.0 : 0.5
            noButton.alpha = enabled ? 1.0 : 0.5
        }
    
    //Исользуем отложенную инициализацию фабрики, чтобы иметь доступ к свойству делегата(delegate) у класса фабрики, ведь в протоколе такого свойства нет.
    private var questionFactory: QuestionFactoryProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Инициализируем сервис статистики
        statisticService = StatisticService()
        imageView.layer.cornerRadius = 20
        //Создаём экземпляр фабрики для ее настройки.
        let questionFactory = QuestionFactory()
        //Устанавливаем связь фабрика – делегат.
        questionFactory.delegate = self
        //Сохраняем подготовленный экземпляр в свойство вью-контроллера, для этого используем обращение через self. Обращение к self нужно, потому что название переменной внутри функции viewDidLoad совпадает с названием свойства класса. Если названия будут различны (вы можете это проверить!), то self можно опустить.
        self.questionFactory = questionFactory  // 4
        self.questionFactory?.requestNextQuestion()
    }
        // MARK: - QuestionFactoryDelegate
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }

            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
    
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
   // private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = ResultAlertPresenter()
    // Добавляем сервис статистики
    private var statisticService: StatisticServiceProtocol!
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // 4
        return questionStep
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        // Включаем кнопки после отображения нового вопроса
        setButtonsEnabled(true)
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
                correctAnswers += 1 // 2
            }
        
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // Сохраняем результаты в статистику
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            // Получаем статистику для отображения
                       let bestGame = statisticService.bestGame
                       let totalGames = statisticService.gamesCount
                       let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
                       
                       // Форматируем дату лучшей игры
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                       let bestGameDate = dateFormatter.string(from: bestGame.date)
            
            // Формируем текст с результатами и статистикой
                        let currentResultText = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
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
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
            // Используем текст из viewModel вместо вызова несуществующего метода
            let message = result.text
            
            let model = AlertModel(
                title: result.title,
                message: message,
                buttonText: result.buttonText
            ) { [weak self] in
                guard let self = self else { return }
                self.restartGame()
            }
            
            // Используем правильное имя переменной alertPresenter
            alertPresenter.show(in: self, model: model)
        }
        
        // Добавляем метод для перезапуска игры
        private func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.resetQuestions()
            questionFactory?.requestNextQuestion()
        }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
