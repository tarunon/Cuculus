//
//  TestAssets.swift
//  
//
//  Created by tarunon on 2019/09/06.
//

import Foundation

func catBark() -> String {
    return "nyan"
}

func dogBark() -> String {
    return "bowwow"
}

struct CatS {
    static func bark() -> String {
        return "nyan"
    }

    static func _bark() -> String {
        return "bowwow"
    }

    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

enum CatE {
    case tama
    static func bark() -> String {
        return "nyan"
    }

    static func _bark() -> String {
        return "bowwow"
    }

    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

extension CatS {
    func eat(_ food: Any) -> Bool {
        return true
    }
    
    func _eat(_ food: Any) -> Bool {
        return false
    }
    
    func eatCollection<T: Collection>(_ foods: T) -> Bool {
        return !foods.isEmpty
    }
    
    func _eatCollection<T: Collection>(_ foods: T) -> Bool {
        return foods.isEmpty
    }

    func eatVariable(_ foods: Any ...) -> Bool {
        return !foods.isEmpty
    }
    
    func _eatVariable(_ foods: Any ...) -> Bool {
        return foods.isEmpty
    }
}

struct Animal<Food> {
    func eat(_ food: Food) -> Bool {
        return true
    }
    
    func _eat(_ food: Food) -> Bool {
        return false
    }
}
