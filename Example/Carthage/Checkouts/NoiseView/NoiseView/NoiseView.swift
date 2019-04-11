import Foundation
import MetalKit

public class NoiseView: MTKView, MTKViewDelegate {
    private var pipelineState: MTLComputePipelineState?
    private var commandQueue: MTLCommandQueue?
    private var timeBuffer: MTLBuffer?
    private let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)

    private var textureDescriptor: MTLTextureDescriptor {
        return MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(bounds.width * UIScreen.main.scale),
            height: Int(bounds.height * UIScreen.main.scale),
            mipmapped: true
        )
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder: NSCoder) is not implemented")
    }

    public override init(frame: CGRect, device: MTLDevice?) {
        super.init(frame: frame, device: device)

        delegate = self
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        contentScaleFactor = UIScreen.main.scale
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preferredFramesPerSecond = 60
        commandQueue = device?.makeCommandQueue()
        timeBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        timeBuffer?.label = "time"
        setupRenderPipeline()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        #if targetEnvironment(simulator)
        #else
            autoreleasepool {
                guard let texture = device?.makeTexture(descriptor: textureDescriptor) else { return }
                guard let pipelineState = pipelineState else { return }

                updateTimeMemoryValue()

                let threadgroupsPerGrid = MTLSize(
                    width: (texture.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width,
                    height: (texture.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
                    depth: 1
                )

                let commandBuffer = commandQueue?.makeCommandBuffer()
                let encoder = commandBuffer?.makeComputeCommandEncoder()
                encoder?.pushDebugGroup("NoiseView Render Frame")
                encoder?.setComputePipelineState(pipelineState)
                encoder?.setBuffer(timeBuffer, offset: 0, index: 0)
                encoder?.setTexture(texture, index: 0)
                encoder?.setTexture(view.currentDrawable?.texture, index: 1)
                encoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
                encoder?.popDebugGroup()
                encoder?.endEncoding()

                if let drawable = view.currentDrawable {
                    commandBuffer?.present(drawable)
                }
                commandBuffer?.commit()
            }
        #endif
    }

    private func setupRenderPipeline() {
        guard let device = device else { return }
        guard let library = device.makeDefaultLibrary() else { return }
        guard let function = library.makeFunction(name: "adjust_noise") else { return }

        do {
            try pipelineState = device.makeComputePipelineState(function: function)
        } catch {
            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
            return
        }
    }

    private func updateTimeMemoryValue() {
        let m = timeBuffer?.contents().bindMemory(to: Float.self, capacity: 1 / MemoryLayout<Float>.stride)
        m?[0] = Float(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 100000) * 1000)
    }
}
