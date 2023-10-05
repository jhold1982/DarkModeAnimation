//
//  RectKey.swift
//  DarkModeAnimation
//
//  Created by Justin Hold on 10/4/23.
//

import Foundation
import SwiftUI

struct RectKey: PreferenceKey {
	static var defaultValue: CGRect = .zero
	
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}
