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
    var name: String {
        return "tama"
    }
    
    var _name: String {
        return "mike"
    }
    
    static var name: String {
        return "tama"
    }
    
    static var _name: String {
        return "mike"
    }
    
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
    
    func 和名() -> String {
        return "たま"
    }

    func _和名() -> String {
        return "みけ"
    }
    
    func stand() throws {
        
    }
    
    func _stand() throws {
        struct _Error: Error {}
        throw _Error()
    }
    
    subscript(_ i: Int) -> Int {
        return i
    }
    
    subscript(hooked i: Int) -> Int {
        return i + 1
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

class CatC {
    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

class CatCSubclass: CatC {
    override func bark() -> String {
        return "nyan2"
    }

    func _bark2() -> String {
        return "bowwow2"
    }
}

protocol CatP {
    
}

extension CatP {
    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

struct CatPInstance: CatP {
    
}
