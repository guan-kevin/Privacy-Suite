//
//  LazyView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/20/21.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
