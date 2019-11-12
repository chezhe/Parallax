//
//  RedAlert.swift
//  GPUImage_iOS
//
//  Created by 王亮 on 2019/11/12.
//  Copyright © 2019 Red Queen Coder, LLC. All rights reserved.
//

public class RedAlert: BasicOperation {
    public var iTime:Float = 0 { didSet { uniformSettings["iTime"] = iTime } }
    public init() {
        super.init(fragmentFunctionName:"redAlertFragment", numberOfInputs:1)
        ({ iTime = 1.0 })()
    }
    
    public override func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        ({ iTime = iTime + 0.05 })()
        super.newTextureAvailable(texture, fromSourceIndex: fromSourceIndex)
    }
}

