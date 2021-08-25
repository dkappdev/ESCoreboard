//
//  EurovisionScoreboardTests.swift
//  EurovisionScoreboardTests
//
//  Created by Daniil Kostitsin on 25.08.2021.
//

import XCTest
@testable import EurovisionScoreboard

class EurovisionScoreboardTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModernCountryListShouldNotContainDuplicates() throws {
        let sortedModernCountryList = Country.modernCountryList.sorted { $0.name < $1.name }
        
        let sortedModernCountryListWithRemovedDuplicates = Array(Set(sortedModernCountryList)).sorted { $0.name < $1.name }
        
        XCTAssert(sortedModernCountryList == sortedModernCountryListWithRemovedDuplicates)
    }
    
    func testFullCountryListShouldNotContainDuplicates() throws {
        let sortedFullCountryList = Country.fullCountryList.sorted { $0.name < $1.name }
        
        let sortedFullCountryListWithRemovedDuplicates = Array(Set(sortedFullCountryList)).sorted { $0.name < $1.name }
        
        XCTAssert(sortedFullCountryList == sortedFullCountryListWithRemovedDuplicates)
    }

}
