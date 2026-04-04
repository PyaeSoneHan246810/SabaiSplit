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
    @State private var totalAmount: Double = 0.0
    @State private var draftPersonList: [DraftPerson] = []
    @State private var deletedPersistentIDs: [PersistentIdentifier] = []
    @State private var pendingAdjustment: PendingAdjustment? = nil
    @FocusState private var focusedAmountID: UUID?
    @State private var amountSnapshot: [UUID: Double] = [:]
    let billSplit: BillSplit
    private var disableConfirmButton: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var body: some View {
        mainScrollView
        .navigationTitle("Edit Bill Split")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContentView
        }
        .onAppear {
            initStates()
        }
        .onChange(of: focusedAmountID) { oldID, newID in
            onFocusedAmountIDChanged(oldID: oldID, newID: newID)
        }
    }
}

private extension EditBillSplitView {
    var mainScrollView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                editTitleView
                editDateView
                editPeopleListView
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }
    @ToolbarContentBuilder
    var toolbarContentView: some ToolbarContent {
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
    var editTitleView: some View {
        HeadlinedSectionView(headline: "Title") {
            TextField("Dinner at Restaurant", text: $title)
                .backgroundCardStyle(height: 60.0)
        }
    }
    var editDateView: some View {
        DatePicker(selection: $date, displayedComponents: .date) {
            Text("Date")
                .font(.headline)
        }
    }
    var editPeopleListView: some View {
        HeadlinedSectionView(headline: "People") {
            VStack(alignment: .leading, spacing: 8.0) {
                draftPersonListView
                HStack(spacing: 8.0) {
                    addPersonButtonView
                    distributeEquallyButtonView
                }
            }
        }
        .alert(
            pendingAdjustment?.alertTitle ?? "Adjust Bill Split",
            isPresented: Binding(
                get: { pendingAdjustment != nil },
                set: { if !$0 { pendingAdjustment = nil } }
            ),
            actions: {
                if let adjustment = pendingAdjustment {
                    Button(adjustment.optionALabel) { applyAdjustTotalAmount(for: adjustment) }
                    Button(adjustment.optionBLabel) { applyDistributeToOthers(for: adjustment) }
                    Button("Cancel") { cancelAdjustment(for: adjustment) }
                }
            }, message: {
                if let adjustment = pendingAdjustment {
                    Text(adjustmentMessage(for: adjustment))
                }
            }
        )
    }
    var draftPersonListView: some View {
        ForEach($draftPersonList) { $draft in
            VStack {
                HStack {
                    TextField("Name", text: $draft.name)
                        .font(.headline)
                    Spacer()
                    Button {
                        onDeleteTapped(draft: draft)
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .imageScale(.large)
                    }
                    .tint(.red)
                    .disabled(draftPersonList.count <= 2)
                }
                Divider()
                TextField("Amount", value: $draft.amount, format: .currency(code: "THB"))
                    .keyboardType(.decimalPad)
                    .focused($focusedAmountID, equals: draft.id)
            }
            .backgroundCardStyle()
        }
    }
    var addPersonButtonView: some View {
        Button("Add Person", systemImage: "plus") {
            let newDraftPerson = DraftPerson(
                name: "New Person",
                amount: 0.0
            )
            draftPersonList.append(newDraftPerson)
            amountSnapshot[newDraftPerson.id] = 0.0
        }
        .buttonStyle(.bordered)
    }
    var distributeEquallyButtonView: some View {
        Button("Distribute Equally", systemImage: "equal.circle") {
            distributeEqually()
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Types
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

    struct PendingAdjustment: Identifiable {
        let id = UUID()
        enum Kind {
            case amountEdited(draftID: UUID, oldAmount: Double, newAmount: Double)
            case personDeleted(draft: DraftPerson)
        }
        let kind: Kind
        var alertTitle: String {
            switch kind {
            case .amountEdited(_, let old, let new):
                new > old ? "Amount Increased" : "Amount Decreased"
            case .personDeleted:
                "Remove Person"
            }
        }
        var optionALabel: String {
            switch kind {
            case .amountEdited: "Adjust Total Amount"
            case .personDeleted: "Reduce Total Amount"
            }
        }
        var optionBLabel: String {
            switch kind {
            case .amountEdited(_, let old, let new):
                new > old ? "Reduce Others Equally" : "Increase Others Equally"
            case .personDeleted:
                "Distribute to Others"
            }
        }
    }
}

// MARK: - Logic
private extension EditBillSplitView {
    func initStates() {
        title = billSplit.title
        date = billSplit.date
        totalAmount = billSplit.totalAmount
        draftPersonList = billSplit.nonNilPersonList.map {
            DraftPerson(
                persistentID: $0.persistentModelID,
                name: $0.name,
                amount: $0.amount
            )
        }
    }

    func saveEdits() {
        autoAdjustTotal()
        billSplit.title = title
        billSplit.date = date
        billSplit.totalAmount = totalAmount
        for persistentID in deletedPersistentIDs {
            if let person = billSplit.nonNilPersonList.first(where: { $0.persistentModelID == persistentID }) {
                modelContext.delete(person)
            }
        }
        for draft in draftPersonList {
            if let persistentID = draft.persistentID,
               let person = billSplit.nonNilPersonList.first(where: { $0.persistentModelID == persistentID }) {
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

    func onFocusedAmountIDChanged(oldID: UUID?, newID: UUID?) {
        if let newID, let draft = draftPersonList.first(where: { $0.id == newID }) {
            amountSnapshot[newID] = draft.amount
        }
        guard let oldID,
              pendingAdjustment == nil,
              let snapshot = amountSnapshot[oldID],
              let draft = draftPersonList.first(where: { $0.id == oldID }) else { return }
        let delta = draft.amount - snapshot
        guard abs(delta) > 0.001 else { return }
        if draftPersonList.count == 1 {
            autoAdjustTotal()
        } else {
            pendingAdjustment = PendingAdjustment(
                kind: .amountEdited(draftID: oldID, oldAmount: snapshot, newAmount: draft.amount)
            )
        }
    }

    func onDeleteTapped(draft: DraftPerson) {
        guard draftPersonList.count > 2 else { return }
        pendingAdjustment = PendingAdjustment(kind: .personDeleted(draft: draft))
    }

    func removeDraft(_ draft: DraftPerson) {
        if let persistentID = draft.persistentID {
            deletedPersistentIDs.append(persistentID)
        }
        draftPersonList.removeAll { $0.id == draft.id }
    }

    func autoAdjustTotal() {
        let personTotal = draftPersonList.reduce(0.0) { $0 + $1.amount }
        let tipFactor = 1.0 + (billSplit.tipPercentage / 100.0)
        totalAmount = tipFactor > 0 ? personTotal / tipFactor : personTotal
    }

    func distributeEqually() {
        guard !draftPersonList.isEmpty else { return }
        let tipFactor = 1.0 + (billSplit.tipPercentage / 100.0)
        let totalWithTip = totalAmount * tipFactor
        let share = totalWithTip / Double(draftPersonList.count)
        for i in draftPersonList.indices {
            draftPersonList[i].amount = share
        }
    }

    func applyAdjustTotalAmount(for adjustment: PendingAdjustment) {
        if case .personDeleted(let draft) = adjustment.kind {
            removeDraft(draft)
        }
        autoAdjustTotal()
    }

    func applyDistributeToOthers(for adjustment: PendingAdjustment) {
        switch adjustment.kind {
        case .amountEdited(let draftID, let oldAmount, let newAmount):
            let delta = newAmount - oldAmount
            let otherCount = draftPersonList.filter { $0.id != draftID }.count
            guard otherCount > 0 else { return }
            let share = delta / Double(otherCount)
            for i in draftPersonList.indices where draftPersonList[i].id != draftID {
                draftPersonList[i].amount -= share
            }
        case .personDeleted(let draft):
            let amount = draft.amount
            removeDraft(draft)
            guard !draftPersonList.isEmpty else { return }
            let share = amount / Double(draftPersonList.count)
            for i in draftPersonList.indices {
                draftPersonList[i].amount += share
            }
        }
    }

    func cancelAdjustment(for adjustment: PendingAdjustment) {
        if case .amountEdited(let draftID, let oldAmount, _) = adjustment.kind,
           let i = draftPersonList.firstIndex(where: { $0.id == draftID }) {
            draftPersonList[i].amount = oldAmount
            amountSnapshot[draftID] = oldAmount
        }
    }

    func adjustmentMessage(for adjustment: PendingAdjustment) -> String {
        let otherCount = draftPersonList.count - 1
        switch adjustment.kind {
        case .amountEdited(_, _, _):
            return "Adjust the total bill, or distribute the difference among the other \(otherCount) \(otherCount == 1 ? "person" : "people")."
        case .personDeleted(_):
            return "Reduce the total bill, or distribute the share equally among the remaining \(otherCount) \(otherCount == 1 ? "person" : "people")."
        }
    }
}

#Preview {
    EditBillSplitView(
        billSplit: BillSplit.sample
    )
    .tint(.mint)
}
