//
//  ImageSaver.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

class ImageSaver: NSObject {
    var onComplete: ((Error?) -> Void)?

    func writeToPhotoAlbum(uiImage: UIImage, onComplete: ((Error?) -> Void)? = nil) {
        self.onComplete = onComplete
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        onComplete?(error)
    }
}
