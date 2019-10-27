//
//  Filters.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//

import EVGPUImage2
import Foundation
import CoreLocation

struct Filter: Codable, Identifiable {
    var id: Int
    var name: String
    var title: String
    var desc: String
    var filter: String
    var price: Double
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
        return customFilter("schindlers-list")
    case "joker":
        return customFilter("joker")
    case "happy-together":
        return SoftElegance()
    case "matrix":
        return customFilter("matrix")
    case "sin-city":
        let filter = LuminanceThreshold()
        filter.threshold = 0.5
        return filter
    default:
        return FalseColor()
    }
}

func customFilter(_ name: String) -> BasicOperation {
    // 获取文件路径
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "fsh")!)
    var customFilter: BasicOperation
    
    do {
        // 从文件中创建自定义滤镜
        customFilter = try BasicOperation(fragmentShaderFile: url)
    } catch {
        return FalseColor()
    }
    
    return customFilter
}