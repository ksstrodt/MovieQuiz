//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by bot on 29.10.2025.
//

import Foundation

struct AlertModel {
    //текст заголовка алерта
    var title : String
    //текст сообщения алерта
    var message : String
    //текст для кнопки алерта
    var buttonText : String
    //замыкание без параметров для действия по кнопке алерта
    var completion: () -> Void
}
