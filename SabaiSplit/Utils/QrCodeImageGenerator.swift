//
//  QrCodeImageGenerator.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

class QrCodeImageGenerator {
    
    private let context = CIContext()
    
    private let qrCodeGenerator = CIFilter.qrCodeGenerator()
    
    func generateQRCodeImage(from string: String, size: CGFloat) -> UIImage? {
        qrCodeGenerator.message = Data(string.utf8)
        guard let outputImage = qrCodeGenerator.outputImage else {
            return nil
        }
        let scaleX = size * 3 / outputImage.extent.size.width
        let scaleY = size * 3 / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
