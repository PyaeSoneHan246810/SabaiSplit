//
//  SettingsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import CloudKit

struct SettingsTabView: View {
    @Environment(ICloudStatusProvider.self) private var icloudStatusProvider: ICloudStatusProvider
    @AppStorage(AppStorageKeys.colorMode) private var selectedColorMode: ColorMode = .system
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    @State private var isPromptPayNumberEditSheetPresented: Bool = false
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Sabai Split"
    }
    private let appDescription: String = "Split bills instantly, generate a PromptPay QR code for each share, track who's paid, and organize your bill splits."
    private let appDeveloper: String = "Pyae Sone Han"
    private let appDesigner: String = "Pyae Sone Han"
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
    private var appCompatibility: String {
        Bundle.main.infoDictionary?["MinimumOSVersion"] as? String ?? "-"
    }
    var body: some View {
        Form {
            aboutSectionView
            iCloudStatusSectionView
            customizationSectionView
            appSettingsSectionView
            applicationSectionView
        }
        .listSectionSpacing(16.0)
        .navigationTitle(Text("Settings"))
        .sheet(isPresented: $isPromptPayNumberEditSheetPresented) {
            EditPromptPayPhoneNumberView(
                isViewPresented: $isPromptPayNumberEditSheetPresented,
                promptPayPhoneNumber: $promptPayPhoneNumber
            )
            .wrapsWithNavigationStack()
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
        }
    }
}

private extension SettingsTabView {
    func sectionHeaderView(title: String, image: String) -> some View {
        LabeledContent {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 28.0, height: 28.0)
                .foregroundStyle(.mint)
        } label: {
            Text(title)
                .font(.headline)
        }
    }
    var aboutSectionView: some View {
        Section {
            HStack(spacing: 8.0) {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(appName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(appDescription)
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(.appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92.0, height: 92.0)
            }
        }
    }
    var customizationSectionView: some View {
        Section {
            sectionHeaderView(title: "Customization", image: "paintbrush")
            Picker("Color Mode", systemImage: "iphone", selection: $selectedColorMode) {
                ForEach(ColorMode.allCases) { colorMode in
                    Text(colorMode.labelText)
                        .tag(colorMode)
                }
            }
        }
    }
    var appSettingsSectionView: some View {
        Section {
            sectionHeaderView(title: "App Settings", image: "gearshape")
            VStack(spacing: 4.0) {
                LabeledContent("PromptPay Number", value: promptPayPhoneNumber ?? "-")
                HStack {
                    Spacer()
                    Button("Edit") {
                        isPromptPayNumberEditSheetPresented = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
    var iCloudStatusSectionView: some View {
        Section {
            switch icloudStatusProvider.accountStatus {
            case .couldNotDetermine:
                iCloudStatusView(
                    title: "iCloud Status Unknown",
                    image: "icloud.slash",
                    desc: "Unable to determine your iCloud status. Please check your internet connection and try again.",
                    color: .orange
                )
            case .available:
                iCloudStatusView(
                    title: "iCloud is On",
                    image: "icloud",
                    desc: "Your data will sync and backup automatically across devices.",
                    color: .green
                )
            case .restricted:
                iCloudStatusView(
                    title: "iCloud is Restricted",
                    image: "icloud.slash",
                    desc: "iCloud access is restricted, possibly due to parental controls or a device management policy.",
                    color: .orange
                )
            case .noAccount:
                iCloudStatusView(
                    title: "Not Signed In to iCloud",
                    image: "person.icloud",
                    desc: "Sign in to your Apple Account in Settings to enable sync and backup.",
                    color: .pink
                )
            case .temporarilyUnavailable:
                iCloudStatusView(
                    title: "iCloud Unavailable",
                    image: "icloud.slash",
                    desc: "iCloud is temporarily unavailable. Your data will sync automatically once it is restored.",
                    color: .yellow
                )
            case .none, .some(_):
                iCloudStatusView(
                    title: "iCloud Status Unknown",
                    image: "icloud.slash",
                    desc: "An unexpected iCloud status was encountered. Please check your iCloud settings.",
                    color: .gray
                )
            }
        }
    }
    func iCloudStatusView(title: String, image: String, desc: String, color: Color) -> some View {
        VStack {
            LabeledContent {
                Image(systemName: image)
            } label: {
                Text(title)
                    .font(.headline)
            }
            Text(desc)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowBackground(color.opacity(0.1))
    }
    var applicationSectionView: some View {
        Section {
            sectionHeaderView(title: "Application", image: "app.grid")
            LabeledContent("Name", value: appName)
            LabeledContent("Developer", value: appDeveloper)
            LabeledContent("Designer", value: appDesigner)
            LabeledContent("Version", value: appVersion)
            LabeledContent("Compatibility", value: appCompatibility)
        }
    }
}

#Preview {
    @Previewable @State var iCloudStatusProvider: ICloudStatusProvider = .init()
    SettingsTabView()
        .wrapsWithNavigationStack()
        .tint(.mint)
        .environment(iCloudStatusProvider)
}
