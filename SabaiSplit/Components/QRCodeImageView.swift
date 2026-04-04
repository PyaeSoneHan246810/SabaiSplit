//
//  QRCodeImageView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QRCodeImageView: View {
    var uiImage: UIImage?
    let size: CGFloat
    @State private var saveResult: SaveResult? = nil

    private enum SaveResult {
        case success
        case failure(String)
    }

    var body: some View {
        VStack(spacing: 8.0) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12.0))
            } else {
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: size, height: size)
                    .overlay {
                        VStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24.0, height: 24.0)
                                .foregroundStyle(.pink)
                            Text("Failed to generate QR Code")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
            Button("Save QR Code") {
                guard let uiImage else { return }
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(uiImage: uiImage) { error in
                    if let error {
                        saveResult = .failure(error.localizedDescription)
                    } else {
                        saveResult = .success
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(uiImage == nil)
            if let saveResult {
                switch saveResult {
                case .success:
                    Label("Saved to Photos", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                case .failure(let message):
                    Label(message, systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
        }
    }
}

#Preview {
    QRCodeImageView(uiImage: nil, size: 250.0)
}
