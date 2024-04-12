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
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // Prevent large navigation title from interfering with target offset
        if (targetContentOffset.pointee.y <= -naturalInset!.top && scrollView.alwaysBounceVertical) {
            return
        }
        
        var targetOffset = targetContentOffset.pointee
        
        // Define the horizontal and vertical insets of the scrollView
        let minX = -scrollView.contentInset.left
        let maxX = scrollView.contentSize.width + scrollView.contentInset.right - scrollView.frame.width
        let minY = -scrollView.contentInset.top
        let maxY = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.height
        
        // Calculate the centerY within the scrollView's visible frame
        let centerY = scrollView.bounds.midY
        
        // Calculate the height of each page
        let pageHeight = scrollView.frame.size.height
        
        // Calculate the minY and maxY based on the centerY
        let minPageY = centerY - pageHeight / 2 - scrollView.contentInset.top
        let maxPageY = centerY + pageHeight / 2 - scrollView.contentInset.top
        
        // Update the localFrames to take into account centerY alignment
        let localFrames = frames.map { $0.offsetBy(dx: minX, dy: minPageY) }
        
        // Calculate the targetOffset.y based on the centerY alignment
        targetOffset.y = localFrames
            .reduce([PointRange(start: minPageY, end: maxPageY)]) { values, frame in
                values
                    .flatMap {
                        $0.excluding(PointRange(start: max(frame.minY, minPageY), end: min(frame.maxY, maxPageY)))
                    }
                    .reduce([]) {
                        $0.contains($1) ? $0 : $0 + [$1]
                    }
            }
            .sorted { $0.distance(to: targetOffset.y) < $1.distance(to: targetOffset.y) }
            .first?
            .resolving(targetOffset.y) ?? minPageY
        
        // Check if there is a change in the vertical direction and if the target offset is within bounds
        let shouldSnap = (scrollView.contentOffset.y > targetOffset.y && velocity.y > 0)
            || (scrollView.contentOffset.y < targetOffset.y && velocity.y < 0)
        
        // Snap to targetOffset if necessary
        if shouldSnap {
            targetContentOffset.pointee = targetOffset
        } else {
            // Fixes immediate jump to target offset
            targetContentOffset.pointee = scrollView.contentOffset
            scrollView.setContentOffset(targetOffset, animated: true)
        }
    }
}


private struct PointRange: Hashable {
    let start: CGFloat
    let end: CGFloat
    
    private func contains(_ point: CGFloat) -> Bool {
        (start...end).contains(point)
    }
    
    func distance(to point: CGFloat) -> CGFloat {
        if contains(point) {
            return 0
        } else {
            return min(abs(start - point), abs(end - point))
        }
    }
    
    func excluding(_ other: PointRange) -> [PointRange] {
        if other.start < start {
            if other.end <= end {
                if other.end <= start {
                    return [self]
                } else {
                    return [PointRange(start: other.end, end: end)]
                }
            } else {
                return []
            }
        } else {
            if other.end <= end {
                return [PointRange(start: start, end: other.start),
                        PointRange(start: other.end, end: end)]
            } else {
                if other.start > end {
                    return [self]
                } else {
                    return [PointRange(start: start, end: other.start)]
                }
            }
        }
    }
    
    func resolving(_ point: CGFloat) -> CGFloat {
        if contains(point) {
            return point
        } else {
            return abs(start - point) < abs(end - point) ? start : end
        }
    }
}
