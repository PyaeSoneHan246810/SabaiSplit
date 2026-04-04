//
//  StatisticsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import SwiftData

struct StatisticsTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var allBillSplits: [BillSplit]
    @Query private var allPersonList: [Person]
    @Query(filter: #Predicate<Person> { $0.hasPaid }) private var paidPersonList: [Person]
    @Query(filter: #Predicate<Person> { !$0.hasPaid }) private var unpaidPersonList: [Person]
    private var unpaidPersonListSorted: [Person] {
        unpaidPersonList.sorted { ($0.billSplit?.date ?? .distantPast) > ($1.billSplit?.date ?? .distantPast) }
    }
    private var allBillSplitsCount: Int {
        allBillSplits.count
    }
    private var completedBillSplitsCount: Int {
        allBillSplits.filter { $0.isAllPaid }.count
    }
    private var activeBillSplitsCount: Int {
        allBillSplits.filter { !$0.isAllPaid }.count
    }
    private var allPeopleCount: Int {
        allPersonList.count
    }
    private var paidPeopleCount: Int {
        paidPersonList.count
    }
    private var unpaidPeopleCount: Int {
        unpaidPersonList.count
    }
    private var collectedPercentage: Double {
        guard allPeopleCount > 0 else { return 0 }
        return Double(paidPeopleCount) / Double(allPeopleCount) * 100
    }
    private var totalAmount: Double {
        allBillSplits.reduce(0) { $0 + $1.totalAmount }
    }
    private var totalCollectedAmount: Double {
        paidPersonList.reduce(0) { $0 + $1.amount }
    }
    private var totalPendingAmount: Double {
        unpaidPersonList.reduce(0) { $0 + $1.amount }
    }
    @State private var selectedUnpaidPerson: Person? = nil
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                HeadlinedSectionView(headline: "Overview") {
                    overviewView
                }
                HeadlinedSectionView(headline: "Unpaid people") {
                    unpaidPersonListView
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .navigationTitle(Text("Statistics"))
        .sheet(item: $selectedUnpaidPerson) { unpaidPerson in
            UnpaidPersonDetailsView(unpaidPerson: unpaidPerson)
                .wrapsWithNavigationStack()
                .interactiveDismissDisabled(true)
        }
    }
}

private extension StatisticsTabView {
    var overviewView: some View {
        VStack(spacing: 10.0) {
            HStack(spacing: 10.0) {
                StatisticCardView(
                    title: "\(allBillSplitsCount)",
                    label: "Total bill splits",
                    titleColor: Color.mint
                )
                StatisticCardView(
                    title: "\(completedBillSplitsCount)",
                    label: "Completed",
                    titleColor: Color.green
                )
                StatisticCardView(
                    title: "\(activeBillSplitsCount)",
                    label: "In progress",
                    titleColor: Color.orange
                )
            }
            HStack(spacing: 10.0) {
                StatisticCardView(
                    title: "\(unpaidPeopleCount)",
                    label: "Unpaid people",
                    titleColor: Color.pink
                )
                StatisticCardView(
                    title: String(format: "฿%.2f", totalAmount),
                    label: "Total bill amount",
                    titleColor: Color.primary
                )
            }
            collectionProgressView
            totalUnpaidAmountView
        }
    }
    var totalUnpaidAmountView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2.0) {
                Text("Total unpaid amount")
                    .font(.headline)
                Text("Across \(activeBillSplitsCount) active bills")
                    .font(.footnote)
            }
            Spacer()
            BahtTextView(amount: totalPendingAmount)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? Color.primary : Color.pink)
        }
        .padding(10.0)
        .background(Color.pink.opacity(colorScheme == .dark ? 0.4 : 0.1), in: RoundedRectangle(cornerRadius: 12.0))
    }
    var collectionProgressView: some View {
        VStack {
            HStack {
                Text("Collection progress")
                    .font(.headline)
                Spacer()
                Text("\(collectedPercentage, specifier: "%.1f")% collected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(
                value: Double(paidPeopleCount),
                total: Double(allPeopleCount)
            )
            .progressViewStyle(.linear)
            HStack(spacing: 10.0) {
                HStack(spacing: 4.0) {
                    Circle()
                        .frame(width: 8.0, height: 8.0)
                        .foregroundStyle(.mint)
                    HStack(spacing: 2.0) {
                        Text("Collected:")
                        BahtTextView(amount: totalCollectedAmount)
                    }
                }
                HStack(spacing: 4.0) {
                    Circle()
                        .frame(width: 8.0, height: 8.0)
                        .foregroundStyle(Color(uiColor: .systemGray4))
                    HStack(spacing: 2.0) {
                        Text("Pending: ")
                        BahtTextView(amount: totalPendingAmount)
                    }
                }
                Spacer()
            }
            .font(.footnote)
        }
        .padding(10.0)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12.0))
    }
    @ViewBuilder
    var unpaidPersonListView: some View {
        if unpaidPersonListSorted.isEmpty {
            ContentUnavailableView {
                Label("No Unpaid People", systemImage: "person.3.fill")
            } description: {
                Text("There are no unpaid people yet.")
            }
        } else {
            VStack(spacing: 10.0) {
                ForEach(unpaidPersonListSorted) { unpaidPerson in
                    UnpaidPersonItemView(person: unpaidPerson)
                        .onTapGesture {
                            selectedUnpaidPerson = unpaidPerson
                        }
                }
            }
        }
    }
}

#Preview {
    StatisticsTabView()
        .wrapsWithNavigationStack()
        .tint(.mint)
}
