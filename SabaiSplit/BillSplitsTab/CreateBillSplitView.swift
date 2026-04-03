//
//  CreateBillSplitView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI
import SwiftData

struct CreateBillSplitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title: String = ""
    @State private var totalAmount: Double = 0.0
    @State private var totalAmountText: String = ""
    @State private var numberOfPeople: Int = 2
    @State private var selectedTipOption: TipOption = .noTip
    @State private var tipPercentage: Double = 0.0
    @State private var tipPercentageText: String = ""
    @State private var amountPerPerson: Double = 0.0
    @State private var date: Date = Date()
    @State private var personList: [Person] = []
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var disableConfirmButton: Bool {
        trimmedTitle.isEmpty || totalAmount == 0.0 || (selectedTipOption == .other && tipPercentageText.isEmpty)
    }
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                HeadlinedSectionView(headline: "Title") {
                    TextField("Dinner at Restaurant", text: $title)
                        .backgroundCardStyle(height: 60.0)
                }
                HeadlinedSectionView(headline: "Total Amount") {
                    TotalAmountTextFieldView(
                        totalAmount: $totalAmount,
                        totalAmountText: $totalAmountText
                    )
                }
                HeadlinedSectionView(headline: "Split Between") {
                    NumberOfPeopleStepperView(
                        numberOfPeople: $numberOfPeople
                    )
                }
                HeadlinedSectionView(headline: "Tip Percentage") {
                    TipPercentageSelectionView(
                        selectedTipOption: $selectedTipOption,
                        tipPercentage: $tipPercentage,
                        tipPercentageText: $tipPercentageText
                    )
                }
                HeadlinedSectionView(headline: "People") {
                    editPersonListView
                }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                        .font(.headline)
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("New Bill Split"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    saveBillSplit()
                }
                .disabled(disableConfirmButton)
            }
        }
        .onAppear {
            initPersonList()
        }
        .onChange(of: numberOfPeople) { _, newValue in
            adjustPersonList(numberOfPeople: newValue)
            calculateAmountPerPerson()
        }
        .onChange(of: totalAmount) {
            calculateAmountPerPerson()
        }
        .onChange(of: tipPercentage) {
            calculateAmountPerPerson()
        }
    }
}

private extension CreateBillSplitView {
    var editPersonListView: some View {
        VStack(spacing: 8.0) {
            ForEach($personList) { $person in
                HStack(spacing: 8.0) {
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
                    TextField("Name", text: $person.name)
                    HStack {
                        Text(person.amount, format: .number.precision(.fractionLength(2)))
                            .multilineTextAlignment(.trailing)
                        Image(systemName: "bahtsign")
                    }
                }
                .backgroundCardStyle(height: 60.0)
            }
        }
    }
}

private extension CreateBillSplitView {
    func initPersonList() {
        for number in 1...numberOfPeople {
            let newPerson = Person(name: "Person \(number)", amount: 0.0)
            personList.append(newPerson)
        }
    }
    
    func adjustPersonList(numberOfPeople: Int) {
        if numberOfPeople > personList.count {
            for number in (personList.count + 1)...numberOfPeople {
                let newPerson = Person(name: "Person \(number)", amount: 0.0)
                personList.append(newPerson)
            }
        } else if numberOfPeople < personList.count {
            personList.removeLast(personList.count - numberOfPeople)
        }
    }
    func calculateAmountPerPerson() {
        let tipAmount = totalAmount * (tipPercentage / 100.0)
        let totalWithTip = totalAmount + tipAmount
        amountPerPerson = totalWithTip / Double(numberOfPeople)
        personList.forEach { person in
            person.amount = amountPerPerson
        }
    }
    func saveBillSplit() {
        let billSplit = BillSplit(title: trimmedTitle, totalAmount: totalAmount, tipPercentage: tipPercentage, date: date, personList: personList)
        modelContext.insert(billSplit)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    CreateBillSplitView()
        .wrapsWithNavigationStack()
}
