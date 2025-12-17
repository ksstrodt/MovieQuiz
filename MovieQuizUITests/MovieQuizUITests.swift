//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by bot on 06.12.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton () {
        sleep(3)
        
        let firstPoster = app.images ["Poster"] //находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() //находим кнопку "да" и нажимаем её
        sleep(3)
        
        let secondPoster = app.images ["Poster"] //ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        
        
        XCTAssertNotEqual(firstPosterData,secondPosterData) //проверяем, что постеры разные
        //XCTAssertTrue(firstPoster.exists)
        //XCTAssertTrue(secondPoster.exists)
    }
    
    func testNoButton () {
        sleep(3)
        
        let firstPoster = app.images ["Poster"] //находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() //находим кнопку "нет" и нажимаем её
        sleep(3)
        
        let secondPoster = app.images ["Poster"] //ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        
        
        XCTAssertNotEqual(firstPosterData,secondPosterData) //проверяем, что постеры разные
        //XCTAssertTrue(firstPoster.exists)
        //XCTAssertTrue(secondPoster.exists)
    }
  
    func testGameFinish() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
 /*   @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
*/
}
