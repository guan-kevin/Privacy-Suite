//
//  CalendarEventListingView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 8/7/21.
//

import SwiftUI

struct CalendarEventListingView: View {
    var events: [CalendarEventItem] = []

    var body: some View {
        List {
            ForEach(events) { event in
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.getTitle())
                                .font(.headline)
                            Text("Start: \(event.getStart(), formatter: itemFormatter)")
                                .font(.caption)
                            Text("End: \(event.getEnd(), formatter: itemFormatter)")
                                .font(.caption)
                        }

                        Spacer()
                    }
                    Divider()
                }
            }
        }
        .frame(height: 100)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
