//
//  Persistence.swift
//  Takip
//
//  Created by Baran on 16.03.2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let now = Date()
        let samples: [(Decimal, String, String?, Date)] = [
            (45.0, "Food", "Öğle yemeği", now),
            (12.5, "Transport", "Otobüs bileti", Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now),
            (150.0, "Shopping", "Market", Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now),
            (80.0, "Entertainment", "Sinema", Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now),
            (20.0, "Other", nil, Calendar.current.date(byAdding: .day, value: -4, to: now) ?? now),
        ]
        
        for s in samples {
            let e = Expense(context: viewContext)
            e.id = UUID()
            e.amount = NSDecimalNumber(decimal: s.0)
            e.category = s.1
            e.note = s.2
            e.createdAt = s.3
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Takip")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
