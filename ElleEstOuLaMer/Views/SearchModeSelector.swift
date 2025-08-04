//
//  SearchModeSelector.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 02/08/2025.
//

import SwiftUI

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

extension SearchMode {
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
}

struct SearchModeSelector: View {
    private struct Constants {
        static let sliderWidth: CGFloat = 30
        static let sliderHeight: CGFloat = 100
        static let dragScale: CGFloat = 1.2
        static let sliderMinOffset: CGFloat = -35
        static let sliderMaxOffset: CGFloat = 35
        static let coastalSymbol: String = "beach.umbrella.fill"
        static let freshwaterSymbol: String = "leaf.fill"
        static let symbolsSpacing: CGFloat = 15
        static let cursorColor: Color = .white
        static let sliderCornerRadius: CGFloat = 15
        static let sliderShadowRadius: CGFloat = 15
        static let cursorPadding: CGFloat = 3
    }
    
    @Binding var selectedMode: SearchMode
    
    let generator = UISelectionFeedbackGenerator()

    var body: some View {
        HStack {
            symbolsStack
            slider
        }
        .scaleEffect(dragState.isDragging ? Constants.dragScale : 1)
        .animation(.default.speed(2), value: dragState.isDragging)
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
                selectedMode = selectedMode.next
            }
    }
    
    private var cursor: some View {
        Circle()
            .fill(Constants.cursorColor)
            .padding(Constants.cursorPadding)
            .offset(y: selectedMode.cursorOffset + dragState.offset)
            .animation(.smooth, value: selectedMode)
            .gesture(dragCursorGesture)
    }
    
    @ViewBuilder
    private var symbolsStack: some View {
        let highlightedMode = SearchMode.closest(to: selectedMode.cursorOffset + dragState.offset)
        VStack(alignment: .trailing, spacing: Constants.symbolsSpacing) {
            Image(systemName: Constants.coastalSymbol)
                .highlightedSymbol(isHighlighted: highlightedMode == .coastal)
            Image(systemName: Constants.freshwaterSymbol)
                .highlightedSymbol(isHighlighted: highlightedMode == .freshwater)
            HStack(spacing: .zero) {
                Image(systemName: Constants.coastalSymbol)
                Image(systemName: Constants.freshwaterSymbol)
            }
            .highlightedSymbol(isHighlighted: highlightedMode == .all)
        }
        .font(.callout)
        .animation(.default.speed(2), value: highlightedMode)
        .onChange(of: highlightedMode) {
            generator.selectionChanged()
        }
    }
    
    @GestureState private var dragState: DragState = .idle
    
    private var dragCursorGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                let clampedOffset = clampedCursorOffset(for: value.translation.height)
                state = .dragging(offset: clampedOffset - selectedMode.cursorOffset)
            }
            .onEnded { value in
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
    SearchModeSelector(selectedMode: $searchMode)
}
