//
//  ViewController.swift
//  HelloMetal
//
//  Created by Krisztian Gyuris on 04/12/15.
//  Copyright © 2015 Krisztian Gyuris. All rights reserved.
//

// iOS 8 Metal Tutorial with Swift: Getting Started
// Source: http://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started

import UIKit
import MetalKit
import QuartzCore

class ViewController: UIViewController {

    var device : MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    
    let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]
    
    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var timer: CADisplayLink! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        device = MTLCreateSystemDefaultDevice()
        
        // Creating layer
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .BGRA8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        metalLayer.frame = view.layer.frame  // 5
        view.layer.addSublayer(metalLayer)   // 6
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0]) 
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
        // Creating pipeline
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
            
        } catch _ {
            print("Failed to create pipeline state")
        }
        
        
        // Creating command queue
        commandQueue = device.newCommandQueue()
        
        timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        
        
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

