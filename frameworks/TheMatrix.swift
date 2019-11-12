//
//  TheMatrix.swift
//  GPUImage_iOS
//
//  Created by 王亮 on 2019/11/12.
//  Copyright © 2019 Red Queen Coder, LLC. All rights reserved.
//

public class TheMatrix: BasicOperation {
    public var threshold:Float = 0.5 { didSet { uniformSettings["threshold"] = threshold } }
    
    public init() {
        super.init(fragmentFunctionName: "theMatrixFragment", numberOfInputs:1)
        
        ({threshold = 0.5})()
    }
    
    public override func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        ({threshold = Float.random(in: 0...1.0)})()
        super.newTextureAvailable(texture, fromSourceIndex: fromSourceIndex)
    }
}

