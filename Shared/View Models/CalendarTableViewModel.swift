//
//  CalendarTableViewModel.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 8/1/21.
//

import Foundation

class CalendarTableViewModel: ObservableObject {
    @Published var events: [CalendarEventItem]

    init(events: [CalendarEventItem]) {
        self.events = events
    }
}
