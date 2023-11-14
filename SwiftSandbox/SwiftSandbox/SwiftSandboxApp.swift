//
//  SwiftSandboxApp.swift
//  SwiftSandbox
//
//  Created by Bethany Smith on 14/11/2023.
//

import SwiftUI

@main
struct SwiftSandboxApp: App {
    var body: some Scene {
        WindowGroup {
            DependencyInjectionView(dataService: UrlDataService(url: nil))
        }
    }
}
