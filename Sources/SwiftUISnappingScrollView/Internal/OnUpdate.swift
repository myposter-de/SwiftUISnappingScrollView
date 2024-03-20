/**
*  SwiftUISnappingScrollView
*  Copyright (c) Ciaran O'Brien 2022
*  MIT license, see LICENSE file for details
*/

import Combine
import SwiftUI

internal extension View {
    @ViewBuilder @inlinable func onUpdate<V>(of value: V, perform action: @escaping (_ newValue: V) -> Void) -> some View
    where V : Equatable
    {
        onChange(of: value, perform: action)
    }
}
