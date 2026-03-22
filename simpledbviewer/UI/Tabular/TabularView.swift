//
//  TabularView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//

import SwiftUI

struct TabularView: View {
    @ObservedObject var viewModel: TabularViewModel
    let evenRowColor: Color
    let oddRowColor: Color
    let onReachEnd: () -> Void
    var minCellWidth: CGFloat = 120

    var body: some View {
        if let error = viewModel.state.error {
            ErrorView(error: error)
        } else {
            ViewThatFits(in: .horizontal) {
                tableLayout
                cardLayout
            }
        }
    }

    private var tableLayout: some View {
        return VStack(spacing: 0) {
            Color.clear
                .frame(minWidth: CGFloat(viewModel.state.columnNames.count) * minCellWidth, maxWidth: .infinity)
                .frame(height: .zero)
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.state.items.enumerated()), id: \.element.id) { index, item in
                        tableRow(item: item, index: index)
                    }
                    reachEndSentinel
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                tableHeader
            }
        }
        
    }

    private var tableHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(viewModel.state.columnNames, id: \.self) { columnName in
                    Text(columnName)
                        .font(.headline)
                        .lineLimit(1)
                        .frame(minWidth: minCellWidth, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.md2)
                        .padding(.vertical, Spacing.md2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(String(format: String(localized: "%@ column"), columnName))
                }
            }
            Divider()
        }
        .background(Color(UIColor.systemBackground))
    }

    @ViewBuilder
    private func tableRow(item: AttributeEntity, index: Int) -> some View {
        HStack(spacing: 0) {
            Text(item.name)
                .lineLimit(1)
                .frame(minWidth: minCellWidth, maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md2)
                .padding(.vertical, Spacing.md)
                .accessibilityLabel(String(format: String(localized: "Item %@"), item.name))
            ForEach(Array(viewModel.state.columnNames.dropFirst()), id: \.self) { columnName in
                let valueString = item.attributes.first(where: { $0.name == columnName })?.value ?? String(localized: "dash")
                Text(valueString)
                    .lineLimit(1)
                    .frame(minWidth: minCellWidth, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md2)
                    .padding(.vertical, Spacing.md)
                    .accessibilityLabel(String(format: String(localized: "format.accessibility_column_value"), columnName, valueString))
            }
        }
        .background(rowColor(for: index))
        .accessibilityIdentifier("tabularDataRow.\(index)")
    }

    private var cardLayout: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: Spacing.md2) {
                ForEach(Array(viewModel.state.items.enumerated()), id: \.element.id) { index, item in
                    cardRow(item: item, index: index)
                }
                reachEndSentinel
            }
            .padding(Spacing.md2)
        }
    }

    @ViewBuilder
    private func cardRow(item: AttributeEntity, index: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            attributePair(name: String(localized: "Item Name"), value: item.name)
            ForEach(Array(item.attributes.enumerated()), id: \.offset) { _, attribute in
                Divider()
                attributePair(name: attribute.name, value: attribute.value)
            }
        }
        .padding(Spacing.md2)
        .background(rowColor(for: index))
        .clipShape(RoundedRectangle(cornerRadius: Spacing.md2))
        .accessibilityIdentifier("tabularDataRow.\(index)")
    }

    @ViewBuilder
    private func attributePair(name: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "format.accessibility_column_value"), name, value))
    }

    private var reachEndSentinel: some View {
        Color.clear
            .frame(height: 1)
            .onAppear { onReachEnd() }
    }

    private func rowColor(for index: Int) -> Color {
        index.isMultiple(of: 2) ? evenRowColor : oddRowColor
    }
}

#Preview {
    let vm = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
    vm.handle(.setItems([
        AttributeEntity(name: "Alpha", attributes: [
            .init(name: "color", value: "red"),
            .init(name: "size", value: "large")
        ]),
        AttributeEntity(name: "Beta", attributes: [
            .init(name: "color", value: "blue"),
            .init(name: "size", value: "small"),
            .init(name: "weight", value: "1kg")
        ]),
        AttributeEntity(name: "Gamma", attributes: [
            .init(name: "color", value: "green")
        ])
    ]))
    return TabularView(
        viewModel: vm,
        evenRowColor: Color(UIColor.systemBackground),
        oddRowColor: Color(UIColor.secondarySystemBackground),
        onReachEnd: { print("reached end") })
}
