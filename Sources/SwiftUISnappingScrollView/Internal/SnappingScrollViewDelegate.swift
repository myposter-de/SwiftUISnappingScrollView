/**
*  SwiftUISnappingScrollView
*  Copyright (c) Ciaran O'Brien 2022
*  MIT license, see LICENSE file for details
*/

import SwiftUI

internal class SnappingScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {
    var frames = [CGRect]()
    
    private var naturalInset: UIEdgeInsets? = nil
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let initialOffset = scrollView.contentOffset
        scrollView.setContentOffset(.zero, animated: false)
        
        naturalInset = scrollView.contentInset
        scrollView.setContentOffset(initialOffset, animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if naturalInset == nil {
            scrollViewDidChangeAdjustedContentInset(scrollView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard targetContentOffset.pointee.y > 0 else { return }

        let visibleHeight = scrollView.bounds.height

        let targetOffsetY = targetContentOffset.pointee.y + (visibleHeight / 2.0)

        guard let closestView = frames.min(by: { abs($0.midY - targetOffsetY) < abs($1.midY - targetOffsetY) }) else {
            return
        }

        let newTargetOffsetY = closestView.midY - (visibleHeight / 2.0)

        guard targetContentOffset.pointee.y + visibleHeight < scrollView.contentSize.height else {
            return
        }

        targetContentOffset.pointee.y = newTargetOffsetY
    }
}
