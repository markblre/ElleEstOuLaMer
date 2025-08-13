//
//  SearchModeSelector.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 02/08/2025.
//

import SwiftUI
import TipKit

enum DragState {
    case idle
    case dragging(offset: CGFloat)
    
    var isDragging: Bool {
        switch self {
        case .idle: return false
        case .dragging: return true
        }
    }
    
    var offset: CGFloat {
        switch self {
        case .idle: return 0
        case .dragging(offset: let offset): return offset
        }
    }
}

private extension SearchMode {
    var cursorOffset: CGFloat {
        switch self {
        case .coastal: return -35
        case .freshwater: return 0
        case .all: return 35
        }
    }
    
    static func closest(to offset: CGFloat) -> SearchMode {
        return allCases.min(by: {
            abs($0.cursorOffset - offset) < abs($1.cursorOffset - offset)
        })!
    }
    
    var symbolNames: [String] {
        switch self {
        case .coastal: return ["beach.umbrella.fill"]
        case .freshwater: return ["leaf.fill"]
        case .all: return ["beach.umbrella.fill", "leaf.fill"]
        }
    }
}

struct SearchModeSelector: View {
    private struct Constants {
        static let sliderWidth: CGFloat = 30
        static let sliderHeight: CGFloat = 100
        static let dragScale: CGFloat = 1.2
        static let sliderMinOffset: CGFloat = -35
        static let sliderMaxOffset: CGFloat = 35
        static let symbolsSpacing: CGFloat = 15
        static let cursorColor: Color = .white
        static let sliderCornerRadius: CGFloat = 15
        static let sliderShadowRadius: CGFloat = 15
        static let cursorPadding: CGFloat = 3
    }

    @Binding var onboardingTips: TipGroup
    
    @Binding var selectedMode: SearchMode
    
    @State var scaleFactor: CGFloat = 1
    
    let generator = UISelectionFeedbackGenerator()

    var body: some View {
        HStack {
            symbolsStack
            slider
        }
        .scaleEffect(scaleFactor, anchor: .trailing)
        .onChange(of: dragState.isDragging) { _, isDragging in
            withAnimation() {
                scaleFactor = isDragging ? Constants.dragScale : 1
            }
        }
        .popoverTip(onboardingTips.currentTip as? SearchModeSelectorTapTip)
        .popoverTip(onboardingTips.currentTip as? SearchModeSelectorDragTip)
    }
    
    private var slider: some View {
        RoundedRectangle(cornerRadius: Constants.sliderCornerRadius)
            .fill(.tertiary)
            .frame(width: Constants.sliderWidth, height: Constants.sliderHeight)
            .shadow(color: .black, radius: Constants.sliderShadowRadius)
            .overlay {
                cursor
            }
            .onTapGesture {
                withAnimation(.smooth) {
                    SearchModeSelectorTapTip().invalidate(reason: .actionPerformed)
                    selectedMode = selectedMode.next
                }
            }
    }
    
    private var cursor: some View {
        Circle()
            .fill(Constants.cursorColor)
            .padding(Constants.cursorPadding)
            .offset(y: selectedMode.cursorOffset + dragState.offset)
            .gesture(dragCursorGesture)
    }
    
    @ViewBuilder
    private var symbolsStack: some View {
        let highlightedMode = SearchMode.closest(to: selectedMode.cursorOffset + dragState.offset)
        VStack(alignment: .trailing, spacing: Constants.symbolsSpacing) {
            searchModeSymbolView(for: .coastal, showTitle: dragState.isDragging, isHighlighted: highlightedMode == .coastal)
            searchModeSymbolView(for: .freshwater, showTitle: dragState.isDragging, isHighlighted: highlightedMode == .freshwater)
            searchModeSymbolView(for: .all, showTitle: dragState.isDragging, isHighlighted: highlightedMode == .all)
        }
        .font(.callout)
        .onChange(of: highlightedMode) {
            generator.selectionChanged()
        }
    }
    
    func searchModeSymbolView(for searchMode: SearchMode, showTitle: Bool, isHighlighted: Bool) -> some View {
        HStack(spacing: .zero) {
            if showTitle {
                Text(LocalizedStringKey(searchMode.rawValue))
                    .font(.headline)
                    .padding(.trailing, 5)
            }
            ForEach(searchMode.symbolNames, id: \.self) { symbol in
                Image(systemName: symbol)
            }
        }
        .highlightedSymbol(isHighlighted: isHighlighted)
    }
    
    @GestureState private var dragState: DragState = .idle
    
    private var dragCursorGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                let clampedOffset = clampedCursorOffset(for: value.translation.height)
                state = .dragging(offset: clampedOffset - selectedMode.cursorOffset)
            }
            .onEnded { value in
                SearchModeSelectorDragTip().invalidate(reason: .actionPerformed)
                let clampedOffset = clampedCursorOffset(for: value.translation.height)
                selectedMode = SearchMode.closest(to: clampedOffset)
            }
    }
    
    private func clampedCursorOffset(for translation: CGFloat) -> CGFloat {
        let absoluteOffset = selectedMode.cursorOffset + translation
        return min(max(absoluteOffset, Constants.sliderMinOffset), Constants.sliderMaxOffset)
    }
}

#Preview {
    @Previewable @State var searchMode: SearchMode = .coastal
    @Previewable @State
    var onboardingTips = TipGroup(.ordered) {
        SearchModeSelectorDragTip()
        SearchModeSelectorTapTip()
        CustomLocationTip()
    }
    
    SearchModeSelector(onboardingTips: $onboardingTips,
                       selectedMode: $searchMode)
}
