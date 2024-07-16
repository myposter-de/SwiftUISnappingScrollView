/**
*  SwiftUISnappingScrollView
*  Copyright (c) Ciaran O'Brien 2022
*  MIT license, see LICENSE file for details
*/

import SwiftUI
import SwiftUIIntrospect

public struct SnappingScrollView<Content>: View
where Content : View
{
    public var body: some View {
        ScrollView(axis.set, showsIndicators: showsIndicators) {
            Group {
                switch axis {
                case .horizontal:
                    HStack(content: content)
                case .vertical:
                    VStack(content: content)
                }
            }
            .environment(\.scrollViewFrame, frame)
            .backgroundPreferenceValue(AnchorsKey.self) { anchors in
                GeometryReader { geometry in
                    let frames = anchors.map { geometry[$0] }
                    
                    Color.clear
                        .onAppear { delegate.frames = frames }
                        .onUpdate(of: frames) { delegate.frames = $0 }
                }
                .hidden()
            }
            .transformPreference(AnchorsKey.self) { $0 = AnchorsKey.defaultValue }
//            .background(UIScrollViewBridge(decelerationRate: decelerationRate.rate, delegate: delegate))
        }
        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { scrollView in
            scrollView.decelerationRate = decelerationRate.rate
            scrollView.delegate = delegate
            
            //Prevent SwiftUI from reverting deceleration rate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollView.decelerationRate = decelerationRate.rate
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        DispatchQueue.main.async {
                            if frame == nil {
                                frame = geometry.frame(in: .global)
                            }
                        }
                    }
                    .onUpdate(of: geometry.frame(in: .global)) { frame = $0 }
            }
            .ignoresSafeArea()
            .hidden()
        )
    }
    
    @StateObject private var delegate = SnappingScrollViewDelegate()
    @State private var frame: CGRect? = nil
    
    private var axis: Axis
    private var content: () -> Content
    private var decelerationRate: ScrollDecelerationRate
    private var showsIndicators: Bool
}


public extension SnappingScrollView {
    
    /// Creates a new instance that's scrollable in the direction of the given
    /// axis and can show indicators while scrolling.
    ///
    /// - Parameters:
    ///   - axis: The scroll view's scrollable axis. The default axis is the
    ///     vertical axis.
    ///   - decelerationRate: A floating-point value that determines the rate
    ///     of deceleration after the user ends dragging. The default value for this
    ///     parameter is `.normal`.
    ///   - showsIndicators: A Boolean value that indicates whether the scroll
    ///     view displays the scrollable component of the content offset, in a way
    ///     suitable for the platform. The default value for this parameter is
    ///     `true`.
    ///   - content: The view builder that creates the scrollable view.
    init(_ axis: Axis = .vertical,
         decelerationRate: ScrollDecelerationRate = .normal,
         showsIndicators: Bool = true,
         @ViewBuilder content: @escaping () -> Content)
    {
        self.axis = axis
        self.content = content
        self.decelerationRate = decelerationRate
        self.showsIndicators = showsIndicators
    }
}
