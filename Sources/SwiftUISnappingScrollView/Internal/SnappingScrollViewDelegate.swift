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
        if targetContentOffset.pointee.y > 0 {
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
        } else {
            let visibleWidth = scrollView.bounds.width

            let targetOffsetX = targetContentOffset.pointee.x + (visibleWidth / 2.0)

            guard let closestView = frames.min(by: { abs($0.midX - targetOffsetX) < abs($1.midX - targetOffsetX) }) else {
                return
            }

            let newTargetOffsetX = closestView.midX - (visibleWidth / 2.0)

            guard targetContentOffset.pointee.x + visibleWidth < scrollView.contentSize.width else {
                return
            }

            targetContentOffset.pointee.x = newTargetOffsetX
        }
    }
}
