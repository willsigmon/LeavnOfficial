import Foundation

/// Test script to verify Bible search functionality
@MainActor
func testSearchFunctionality() async {
    print("🔍 Testing Bible Search Functionality")
    print("=====================================\n")
    
    // Initialize DIContainer
    print("1️⃣ Initializing services...")
    await DIContainer.shared.initialize()
    
    // Wait for initialization
    await DIContainer.shared.waitForInitialization()
    
    guard let searchService = DIContainer.shared.searchService else {
        print("❌ Search service not available")
        return
    }
    
    // Test queries
    let testQueries = [
        "love",           // Single word
        "God so loved",   // Phrase
        "faith hope",     // Multiple words
        "Jesus wept",     // Exact phrase
        "shepherd",       // Common term
        "holy spirit",    // Two word phrase
        "in the beginning", // Common opening
        "amen"           // Common ending
    ]
    
    print("2️⃣ Running search tests...\n")
    
    for query in testQueries {
        print("🔎 Searching for: '\(query)'")
        
        do {
            let options = SearchOptions(
                filter: .all,
                limit: 5,  // Limit to 5 results per query for testing
                translation: "NIV"
            )
            
            let results = try await searchService.search(query: query, options: options)
            
            if results.isEmpty {
                print("   ⚠️  No results found")
            } else {
                print("   ✅ Found \(results.count) results:")
                for (index, result) in results.prefix(3).enumerated() {
                    print("      \(index + 1). \(result.bookName) \(result.chapter):\(result.verse)")
                    print("         \"\(result.text.prefix(100))...\"")
                }
                if results.count > 3 {
                    print("      ... and \(results.count - 3) more results")
                }
            }
            
        } catch {
            print("   ❌ Search failed: \(error.localizedDescription)")
        }
        
        print("")
    }
    
    // Test search filters
    print("3️⃣ Testing search filters...\n")
    
    let filterTests: [(String, SearchFilter)] = [
        ("kingdom", .oldTestament),
        ("kingdom", .newTestament),
        ("blessing", .all)
    ]
    
    for (query, filter) in filterTests {
        print("🔎 Searching '\(query)' in \(filter.rawValue)")
        
        do {
            let options = SearchOptions(filter: filter, limit: 3)
            let results = try await searchService.search(query: query, options: options)
            
            if results.isEmpty {
                print("   ⚠️  No results found")
            } else {
                print("   ✅ Found \(results.count) results in \(filter.rawValue)")
                if let firstResult = results.first {
                    print("      First result: \(firstResult.bookName) \(firstResult.chapter):\(firstResult.verse)")
                }
            }
            
        } catch {
            print("   ❌ Search failed: \(error.localizedDescription)")
        }
        
        print("")
    }
    
    // Test recent searches
    print("4️⃣ Testing recent searches...\n")
    
    let recentSearches = await searchService.getRecentSearches()
    if recentSearches.isEmpty {
        print("   ℹ️  No recent searches")
    } else {
        print("   📝 Recent searches:")
        for (index, search) in recentSearches.prefix(5).enumerated() {
            print("      \(index + 1). \(search)")
        }
    }
    
    print("\n✅ Search functionality test complete!")
}

// Run the test
Task {
    await testSearchFunctionality()
}