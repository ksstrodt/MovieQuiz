import UIKit

final class MovieQuizViewController: UIViewController /*QuestionFactoryDelegate*/ {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton! 
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
        
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    private var presenter: MovieQuizPresenter!
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = ResultAlertPresenter()
    // Добавляем сервис статистики
    private var statisticService: StatisticServiceProtocol!
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
   // private var correctAnswers = 0
    
    // Метод для включения/выключения кнопок
        func setButtonsEnabled(_ enabled: Bool) {
            yesButton.isEnabled = enabled
            noButton.isEnabled = enabled
            
            yesButton.alpha = enabled ? 1.0 : 0.5
            noButton.alpha = enabled ? 1.0 : 0.5
        }
   



    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Начальная блокировка кнопок до загрузки данных
        imageView.backgroundColor = .ypBlack
        setButtonsEnabled(false)
        //setupInitialUI()
        showLoadingIndicator()
        // Инициализируем сервис статистики
        statisticService = StatisticService()
        imageView.layer.cornerRadius = 20
        //Создаём экземпляр фабрики для ее настройки.
        //presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = ResultAlertPresenter()
        //presenter.questionFactory?.loadData()
        //presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)
    }
    
   /* func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }*/
    
  /*  func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }*/
    
    //Исользуем отложенную инициализацию фабрики, чтобы иметь доступ к свойству делегата(delegate) у класса фабрики, ведь в протоколе такого свойства нет.
   // private var questionFactory: QuestionFactoryProtocol?
    
        // MARK: - QuestionFactoryDelegate
     /*   func didReceiveNextQuestion(question: QuizQuestion?) {
            presenter.didReceiveNextQuestion(question: question)
        } */
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    // MARK: - Private function
    func show(quiz step: QuizStepViewModel) {
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
  /*  func showAnswerResult(isCorrect: Bool) {
        //if isCorrect { // 1
          //      correctAnswers += 1 // 2
         //   }
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }*/
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
           imageView.layer.masksToBounds = true
           imageView.layer.borderWidth = 8
           imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
        // Делаем кнопки неактивными во время загрузки
        setButtonsEnabled(false)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            // Включаем индикатор загрузки и перезагружаем данные
            self.showLoadingIndicator()
            self.presenter.questionFactory?.loadData() // ← Загружаем данные заново
             }
            
            alertPresenter.show(in: self, model: model)
        }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    /*private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // Сохраняем результаты в статистику
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            // Получаем статистику для отображения
                       let bestGame = statisticService.bestGame
                       let totalGames = statisticService.gamesCount
                       let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
                       
                       // Форматируем дату лучшей игры
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                       let bestGameDate = dateFormatter.string(from: bestGame.date)
            
            // Формируем текст с результатами и статистикой
            let currentResultText = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)"
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
            presenter.switchToNextQuestion()
            presenter.questionFactory?.requestNextQuestion()
        }
    }*/
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
            // Используем текст из viewModel вместо вызова несуществующего метода
            let message = result.text
            
            let model = AlertModel(
                title: result.title,
                message: message,
                buttonText: result.buttonText
            ) { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
            
            // Используем правильное имя переменной alertPresenter
            alertPresenter.show(in: self, model: model)
        }
        
        // Добавляем метод для перезапуска игры
        //private func restartGame() {
         //   self.presenter.restartGame()
            //questionFactory?.requestNextQuestion()
       // }
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
