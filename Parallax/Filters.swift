//
//  Filters.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//

import GPUImage
import Foundation
import CoreLocation

struct Filter: Codable, Identifiable {
    var id: Int
    var name: String
    var title: String
    var desc: String
    var price: Double
    var productID: String?
    
    func locked() -> Bool {
        if productID != nil && price > 0 {
            return UserDefaults.standard.string(forKey: productID!) != "unlocked"
        }
        return false
    }
}

let FILTERS: [Filter] = load("filters.json")


func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func getFilter(name: String) -> ImageProcessingOperation {
    switch name {
    case "shadow":
        let filter = SepiaToneFilter()
        filter.intensity = 1.0
        return filter
    case "schindlers-list":
        return SchindlersList()
    case "joker":
        return Joker()
    case "happy-together":
        return SoftElegance()
    case "matrix":
        return TheMatrix()
    case "west-world":
        return RedAlert()
    case "shape-of-water":
        return Rain()
    default:
        return FalseColor()
    }
}

func getIndexOf(filterName: String) -> Int? {
    return FILTERS.map{filter in filter.name}.firstIndex(of: filterName)
}
