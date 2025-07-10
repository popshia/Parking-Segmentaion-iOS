//
//  DetectionView.swift
//  YOLOv8-seg-iOS
//
//  Created by Marcel Opitz on 05.06.23.
//

import SwiftUI

class DetectionView: UIView {
    
    let detectionLayer: DetectionLayer
    
    override init(frame: CGRect) {
        detectionLayer = DetectionLayer()
        
        super.init(frame: frame)
        
        layer.insertSublayer(detectionLayer, at: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        detectionLayer.frame = frame
    }
    
}

struct DetectionViewRepresentable: UIViewRepresentable {

    @Binding var predictions: [Prediction]
    let classNames: [String]
    let showBoxes: Bool
    let showLabels: Bool
    
    func makeUIView(context: Context) -> UIView {
        DetectionView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? DetectionView)?.detectionLayer.sublayers?.removeAll()

        guard !predictions.isEmpty else {
            return
        }
        
        for prediction in predictions {
            
            let x1: CGFloat = CGFloat(prediction.xyxy.x1)
            let y1: CGFloat = CGFloat(prediction.xyxy.y1)
            let x2: CGFloat = CGFloat(prediction.xyxy.x2)
            let y2: CGFloat = CGFloat(prediction.xyxy.y2)
            
            let rect = CGRect(
                x: x1,
                y: y2,
                width: x2 - x1,
                height: y1 - y2
            )
            .applying(
                CGAffineTransform(
                    scaleX: uiView.bounds.width / prediction.inputImgSize.width,
                    y: uiView.bounds.height / prediction.inputImgSize.height
                )
            )
            .applying(
                CGAffineTransform(
                    1,
                    0,
                    0,
                    -1,
                    0,
                    uiView.bounds.height
                )
            )

            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            
            (uiView as? DetectionView)?.detectionLayer.addDetection(
                objectBounds: rect,
                className: showLabels ? classNames[prediction.classIndex] : nil,
                confidence: prediction.score,
                showBox: showBoxes)
            
            CATransaction.commit()
        }
        
    }
}
