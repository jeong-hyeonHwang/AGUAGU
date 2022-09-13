//
//  VideoProcessingChain.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import Vision
import Combine
import CoreImage

protocol VideoProcessingChainDelegate: AnyObject {
    
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [HandPose]?,
                              in frame: CGImage)
    
}

struct VideoProcessingChain {
    
    weak var delegate: VideoProcessingChainDelegate?

    var upstreamFramePublisher: AnyPublisher<Frame, Never>! {
        didSet { buildProcessingChain() }
    }
    
    private var frameProcessingChain: AnyCancellable?

    private let humanHandPoseRequest = VNDetectHumanHandPoseRequest()
    
}

extension VideoProcessingChain {
    
    private mutating func buildProcessingChain() {
        guard upstreamFramePublisher != nil else { return }

        frameProcessingChain = upstreamFramePublisher
            .compactMap(imageFromFrame)
            .sink(receiveValue: findPosesInFrame(_:))

    }
    
}

extension VideoProcessingChain {
    
    func setOneHandDetection() {
        humanHandPoseRequest.maximumHandCount = 1
    }
    
}

extension VideoProcessingChain {
    
    private func imageFromFrame(_ buffer: Frame) -> CGImage? {

        guard let imageBuffer = buffer.imageBuffer else {
            print("The frame doesn't have an underlying image buffer.")
            return nil
        }

        let ciContext = CIContext(options: nil)

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        guard let cgImage = ciContext.createCGImage(ciImage,
                                                    from: ciImage.extent) else {
            print("Unable to create an image from a frame.")
            return nil
        }

        return cgImage
    }
    
    private func findPosesInFrame(_ frame: CGImage) {
        let visionRequestHandler = VNImageRequestHandler(cgImage: frame)

        do { try visionRequestHandler.perform([humanHandPoseRequest]) } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }

        let poses = HandPose.fromObservations(humanHandPoseRequest.results)
        
        DispatchQueue.main.async {
            self.delegate?.videoProcessingChain(self, didDetect: poses, in: frame)
        }
    }
}
