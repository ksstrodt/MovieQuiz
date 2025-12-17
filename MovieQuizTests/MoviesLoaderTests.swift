//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by bot on 03.12.2025.
//

import Foundation

import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError:false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        //When
        
        //так как функция загрузки фильмов - ассинхронная, то нужно ожидание"
        let expectaion = expectation(description: "LoadingExpectation")
        
        loader .loadMovies {result in
            
            //Then
            switch result {
            case.success(let movies):
                //сравниваем данные с тем, что мы предполагали
                XCTAssertEqual(movies.items.count, 2)
                expectaion.fulfill()
            case.failure(_):
                //мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Unexpected failure");   
            }
        }
      waitForExpectations(timeout: 1)
    }
    
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // говорим, что хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
