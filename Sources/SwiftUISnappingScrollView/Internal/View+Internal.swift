/**
*  SwiftUISnappingScrollView
*  Copyright (c) Ciaran O'Brien 2022
*  MIT license, see LICENSE file for details
*/

import SwiftUI

internal extension View {
    @ViewBuilder @inlinable func ignoresSafeArea() -> some View {
        ignoresSafeArea(.all, edges: .all)
    }
}
