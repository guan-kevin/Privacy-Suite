//
//  CalendarTableView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//

import SwiftUI

struct CalendarTableView: View {
    let days = [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center),
        GridItem(.flexible(), spacing: 5, alignment: .center)
    ]

    var body: some View {
        VStack {
            HStack {
                ForEach(days, id: \.self) { day in
                    Spacer()

                    Text(day)
                        .padding(.trailing, 10)
                        .padding(.top, 5)
                        .font(.system(size: 20, weight: .light, design: .rounded))
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(1 ..< 32) { day in
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(day)")

                            Spacer()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder())
                }
            }
        }
    }
}
