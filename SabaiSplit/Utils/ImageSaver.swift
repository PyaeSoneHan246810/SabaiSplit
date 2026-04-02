//
//  ImageSaver.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

class ImageSaver: NSObject {
    func writeToPhotoAlbum(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
