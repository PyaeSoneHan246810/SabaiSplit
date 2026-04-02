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
    
    func generateQRCodeImage(from string: String, size: CGFloat, bottomText: String? = nil) -> UIImage? {
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
        let qrImage = UIImage(cgImage: cgImage)
        guard let text = bottomText else {
            return qrImage
        }
        return addTextBelowImage(qrImage, text: text, imageSize: size)
    }
    
    private func addTextBelowImage(_ image: UIImage, text: String, imageSize: CGFloat) -> UIImage? {
        let textHeight: CGFloat = 60
        let totalHeight = imageSize + textHeight
        let totalSize = CGSize(width: imageSize, height: totalHeight)
        UIGraphicsBeginImageContextWithOptions(totalSize, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: totalSize))
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        let textRect = CGRect(x: 0, y: imageSize, width: imageSize, height: textHeight)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.draw(in: textRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
