//
//  BillSplitDetailsView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI
import SwiftData

struct BillSplitDetailsView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    @State private var personQrItem: PersonQrItem? = nil
    @State private var isEditBillSplitSheetPresented: Bool = false
    @State private var isPromptPayNumberEditSheetPresented: Bool = false
    @State private var errorMessage: String? = nil
    let billSplit: BillSplit
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
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
        .navigationTitle(Text(billSplit.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil") {
                    isEditBillSplitSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isEditBillSplitSheetPresented) {
            EditBillSplitView(billSplit: billSplit)
                .wrapsWithNavigationStack()
                .interactiveDismissDisabled()
        }
        .sheet(item: $personQrItem) { item in
            personQrSheetView(personQrItem: item)
                .wrapsWithNavigationStack()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isPromptPayNumberEditSheetPresented) {
            EditPromptPayPhoneNumberView(
                isViewPresented: $isPromptPayNumberEditSheetPresented,
                promptPayPhoneNumber: $promptPayPhoneNumber
            )
            .wrapsWithNavigationStack()
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
        }
        .alert("Something Went Wrong", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private extension BillSplitDetailsView {
    struct PersonQrItem: Identifiable {
        let person: Person
        let qrCodeImage: UIImage
        let promptPayPhoneNumber: String
        var id: PersistentIdentifier {
            person.id
        }
    }
}

private extension BillSplitDetailsView {
    var summaryCardView: some View {
        VStack(spacing: 8.0) {
            HStack {
                Text("Total Amount with Tip")
                    .multilineTextAlignment(.leading)
                Spacer()
                Text("Paid")
                    .multilineTextAlignment(.trailing)
            }
            .font(.headline)
            HStack {
                BahtTextView(amount: billSplit.totalAmountIncludingTip)
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
                    total: max(Double(billSplit.numberOfPerson), 1.0)
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
            HStack {
                Spacer()
                Text(billSplit.date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .fontWeight(.medium)
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
        ForEach(billSplit.nonNilPersonList) { person in
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
            person.paidDate = person.hasPaid ? Date() : nil
            do {
                try modelContext.save()
            } catch {
                person.hasPaid.toggle()
                person.paidDate = person.hasPaid ? Date() : nil
                errorMessage = "Could not update payment status. Please try again."
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
                    displayQrCodeImage(for: person)
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
                promptPayPhoneNumber: personQrItem.promptPayPhoneNumber,
                amount: personQrItem.person.amount
            )
        }
        .scrollIndicators(.hidden)
        .contentMargins(16.0)
        .navigationTitle(Text(personQrItem.person.name))
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
    func displayQrCodeImage(for person: Person) {
        guard let promptPayPhoneNumber else {
            isPromptPayNumberEditSheetPresented = true
            return
        }
        let image = generateQrCodeImage(
            amount: person.amount,
            promptPayPhoneNumber: promptPayPhoneNumber
        )
        if let image {
            personQrItem = PersonQrItem(
                person: person,
                qrCodeImage: image,
                promptPayPhoneNumber: promptPayPhoneNumber
            )
        }
    }
    func generateQrCodeImage(amount: Double, promptPayPhoneNumber: String) -> UIImage? {
        guard let qrCodeString = PromptPayQRStringGenerator.generateQRString(
            promptPayPhoneNumber: promptPayPhoneNumber,
            amount: amount
        ) else {
            return nil
        }
        let amountText = "฿\(String(format: "%.2f", amount))"
        return qrCodeImageGenerator.generateQRCodeImage(
            from: qrCodeString,
            size: qrCodeImageSize,
            bottomText: amountText
        )
    }
}

#Preview {
    BillSplitDetailsView(
        billSplit: BillSplit.sample
    )
    .wrapsWithNavigationStack()
    .tint(.mint)
}
