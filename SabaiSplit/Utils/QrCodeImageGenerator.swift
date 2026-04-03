//
//  QrCodeImageGenerator.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

class QrCodeImageGenerator {

    /// Shared CIContext for rendering CIImages to CGImages.
    /// Reused across calls to avoid the overhead of creating a new context each time.
    private let context = CIContext()

    /// CIFilter that produces a QR code CIImage from raw message data.
    private let qrCodeGenerator = CIFilter.qrCodeGenerator()

    /// Generates a QR code image from the given string.
    /// - Parameters:
    ///   - string: The string to encode in the QR code.
    ///   - size: The width and height of the QR code in points.
    ///   - bottomText: Optional label rendered below the QR code. Pass `nil` to omit.
    /// - Returns: A `UIImage` containing the QR code, or `nil` if generation fails.
    func generateQRCodeImage(from string: String, size: CGFloat, bottomText: String? = nil) -> UIImage? {
        qrCodeGenerator.message = Data(string.utf8)
        guard let outputImage = qrCodeGenerator.outputImage else {
            return nil
        }
        // Scale up to 3× the target size before rasterising to preserve sharpness
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

    /// Composites a text label below a QR code image into a single `UIImage`.
    /// - Parameters:
    ///   - image: The QR code image to draw at the top.
    ///   - text: The label string to render below the QR code.
    ///   - imageSize: The width and height of the QR code in points. The canvas width matches this value.
    /// - Returns: A combined `UIImage` with the QR code above and the text below, or `nil` if rendering fails.
    private func addTextBelowImage(_ image: UIImage, text: String, imageSize: CGFloat) -> UIImage? {
        let textHeight: CGFloat = 60
        let totalHeight = imageSize + textHeight
        let totalSize = CGSize(width: imageSize, height: totalHeight)
        // Opaque context with screen scale; white fill ensures text is always visible when saved or shared
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
