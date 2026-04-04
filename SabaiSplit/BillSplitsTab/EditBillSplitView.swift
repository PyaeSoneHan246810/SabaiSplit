//
//  EditBillSplitView.swift
//  SabaiSplit
//
//  Created by Dylan on 4/4/26.
//

import SwiftUI
import SwiftData

struct EditBillSplitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var draftPersonList: [DraftPerson] = []
    @State private var deletedPersistentIDs: [PersistentIdentifier] = []
    let billSplit: BillSplit
    private var disableConfirmButton: Bool {
        false
    }
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                HeadlinedSectionView(headline: "Title") {
                    TextField("Dinner at Restaurant", text: $title)
                        .backgroundCardStyle(height: 60.0)
                }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text("Date")
                        .font(.headline)
                }
                HeadlinedSectionView(headline: "People") {
                    VStack(alignment: .leading, spacing: 8.0) {
                        ForEach($draftPersonList) { $draft in
                            VStack {
                                HStack {
                                    TextField("Name", text: $draft.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    Button {
                                        if let persistentID = draft.persistentID {
                                            deletedPersistentIDs.append(persistentID)
                                        }
                                        draftPersonList.removeAll { $0.id == draft.id }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .imageScale(.large)
                                    }
                                    .tint(.red)
                                }
                                Divider()
                                TextField("Amount", value: $draft.amount, format: .currency(code: "THB"))
                                    .keyboardType(.decimalPad)
                                    
                            }
                            .backgroundCardStyle()
                        }
                        Button("Add Person", systemImage: "plus") {
                            let newDraftPerson = DraftPerson(
                                name: "New Person",
                                amount: 0.0
                            )
                            draftPersonList.append(newDraftPerson)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Edit Bill Split")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    saveEdits()
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .disabled(disableConfirmButton)
            }
        }
        .onAppear {
            initStates()
        }
    }
}

private extension EditBillSplitView {
    struct DraftPerson: Identifiable {
        let id: UUID
        let persistentID: PersistentIdentifier?
        var name: String
        var amount: Double

        init(persistentID: PersistentIdentifier, name: String, amount: Double) {
            self.id = UUID()
            self.persistentID = persistentID
            self.name = name
            self.amount = amount
        }

        init(name: String, amount: Double) {
            self.id = UUID()
            self.persistentID = nil
            self.name = name
            self.amount = amount
        }
    }

    func initStates() {
        title = billSplit.title
        date = billSplit.date
        draftPersonList = billSplit.personList.map {
            DraftPerson(
                persistentID: $0.persistentModelID,
                name: $0.name,
                amount: $0.amount
            )
        }
    }

    func saveEdits() {
        billSplit.title = title
        billSplit.date = date
        for persistentID in deletedPersistentIDs {
            if let person = billSplit.personList.first(where: { $0.persistentModelID == persistentID }) {
                modelContext.delete(person)
            }
        }
        for draft in draftPersonList {
            if let persistentID = draft.persistentID,
               let person = billSplit.personList.first(where: { $0.persistentModelID == persistentID }) {
                person.name = draft.name
                person.amount = draft.amount
            } else if draft.persistentID == nil {
                let newPerson = Person(
                    name: draft.name,
                    amount: draft.amount,
                    billSplit: billSplit
                )
                modelContext.insert(newPerson)
            }
        }
    }
}


#Preview {
    EditBillSplitView(
        billSplit: BillSplit.sample
    )
    .tint(.mint)
}
