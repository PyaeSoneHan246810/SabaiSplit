//
//  BillSplitDetailsView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI
import SwiftData

struct BillSplitDetailsView: View {
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Bindable var billSplit: BillSplit
    @State private var personQrItem: PersonQrItem? = nil
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
    struct PersonQrItem: Identifiable {
        let person: Person
        let qrCodeImage: UIImage
        var id: PersistentIdentifier {
            person.id
        }
    }
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                HeadlinedSectionView(headline: "Summary") {
                    summaryCardView
                }
                HeadlinedSectionView(headline: "People") {
                    peopleListView
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(16.0)
        .navigationTitle(billSplit.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $personQrItem) { item in
            personQrSheetView(personQrItem: item)
                .wrapsWithNavigationStack()
                .interactiveDismissDisabled()
        }
    }
}

private extension BillSplitDetailsView {
    var summaryCardView: some View {
        VStack(spacing: 8.0) {
            HStack {
                Text("Total Amount")
                    .multilineTextAlignment(.leading)
                Spacer()
                Text("Paid")
                    .multilineTextAlignment(.trailing)
            }
            .font(.headline)
            HStack {
                BahtTextView(amount: billSplit.totalAmount)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.mint)
                    .multilineTextAlignment(.leading)
                Spacer()
                Text(billSplit.ratio)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.trailing)
            }
            .font(.headline)
            VStack {
                ProgressView(
                    value: Double(billSplit.numberOfPaidPerson),
                    total: Double(billSplit.numberOfPerson)
                )
                .progressViewStyle(.linear)
                HStack {
                    Text(
                        "\(Text("Paid:").foregroundStyle(.green)) ฿\(billSplit.paidAmount, format: .number.precision(.fractionLength(2)))"
                    )
                    .multilineTextAlignment(.leading)
                    Spacer()
                    Text(
                        "\(Text("Remaining:").foregroundStyle(.orange)) ฿\(billSplit.remainingAmount, format: .number.precision(.fractionLength(2)))"
                    )
                    .multilineTextAlignment(.trailing)
                }
                .font(.callout)
            }
        }
        .padding(16.0)
        .background {
            RoundedRectangle(cornerRadius: 12.0)
                .fill(colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5.0)
        }
    }
    var peopleListView: some View {
        ForEach($billSplit.personList) { $person in
            HStack(spacing: 8.0) {
                personPaidToggleView(person)
                personInfoView(person)
                Spacer()
                personAmountView(person)
            }
            .backgroundCardStyle()
        }
    }
    func personPaidToggleView(_ person: Person) -> some View {
        Button {
            person.hasPaid.toggle()
            if person.hasPaid {
                person.paidDate = Date()
            } else {
                person.paidDate = nil
            }
        } label: {
            Image(systemName: person.hasPaid ? "checkmark.circle.fill" : "circle")
        }
    }
    func personInfoView(_ person: Person) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(person.name)
                .font(.headline)
                .strikethrough(person.hasPaid)
            Group {
                if person.hasPaid {
                    Text(person.paidDate.map { "Paid (\($0, format: .dateTime.day().month().year()))" } ?? "Paid")
                        .foregroundStyle(.green)
                } else {
                    Text("Not paid yet")
                }
            }
            .font(.caption)
        }
    }
    func personAmountView(_ person: Person) -> some View {
        VStack(alignment: .trailing, spacing: 0.0) {
            BahtTextView(amount: person.amount)
                .foregroundStyle(person.hasPaid ? Color.secondary : Color.mint)
            if !person.hasPaid {
                Button("QR", systemImage: "qrcode") {
                    let image = generateQrCodeImage(amount: person.amount)
                    if let image {
                        personQrItem = PersonQrItem(person: person, qrCodeImage: image)
                    }
                }
                .font(.footnote)
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
    }
    func personQrSheetView(personQrItem: PersonQrItem) -> some View {
        ScrollView(.vertical) {
            ScanToPayView(
                qrCodeImage: personQrItem.qrCodeImage,
                qrCodeImageSize: qrCodeImageSize,
                promptPayPhoneNumber: promptPayPhoneNumber,
                amount: personQrItem.person.amount
            )
        }
        .scrollIndicators(.hidden)
        .contentMargins(16.0)
        .navigationTitle(personQrItem.person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    self.personQrItem = nil
                }
            }
        }
    }
}

private extension BillSplitDetailsView {
    func generateQrCodeImage(amount: Double) -> UIImage? {
        guard let promptPayPhoneNumber else { return nil }
        guard amount > 0.0 else { return nil }
        guard let qrCodeString = PromptPayQRStringGenerator.generateQRString(
            promptPayPhoneNumber: promptPayPhoneNumber,
            amount: amount
        ) else { return nil }
        let amountText = "฿\(String(format: "%.2f", amount))"
        return qrCodeImageGenerator.generateQRCodeImage(from: qrCodeString, size: qrCodeImageSize, bottomText: amountText)
    }
}

#Preview {
    BillSplitDetailsView(
        billSplit: BillSplit.sample
    )
    .wrapsWithNavigationStack()
    .tint(.mint)
}
