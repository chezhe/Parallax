//
//  ShadertoyFilter.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/7.
//  Copyright © 2019 王亮. All rights reserved.
//

import EVGPUImage2


class CustomFilter: BasicOperation {
    public var strength: Float = 1.0 { didSet { uniformSettings["strength"] = strength } }
    public var inputs: [PictureInput]? {
        didSet {
            if let inputs_ = inputs {
                for (index, input) in inputs_.enumerated() {
                    input.addTarget(self, atTargetIndex: UInt(index + 1))
                    input.processImage()
                }
            }
        }
    }
    
    public init(fragmentShader: String, numberOfInputs: Int = 1) {
        super.init(fragmentShader: fragmentShader, numberOfInputs: UInt(numberOfInputs))
        ({strength = 1.0})()
    }
}

//class Matrix: BasicOperation {
//    public init() {
//        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "matrix", ofType: "fsh")!)
//        try super.init(fragmentShaderFile: url)
//        self.shader.setValue(<#T##value: [GLfloat]##[GLfloat]#>, forUniform: <#T##String#>)
//    }
//}

//class ShadertoyFilter: CustomFilter {
//
//    public override init(fragmentShader: String, numberOfInputs: Int) {
//        super.init(fragmentShader: fragmentShader, numberOfInputs: numberOfInputs)
//
//        ({strength = 1.0})()
//
//        shader.se
//    }
//}
