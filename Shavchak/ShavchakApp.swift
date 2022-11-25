//
//  ShavchakApp.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//

import SwiftUI

@main
struct ShavchakApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
