//
//  EurovisionScoreboardTests.swift
//  EurovisionScoreboardTests
//
//  Created by Daniil Kostitsin on 25.08.2021.
//

import XCTest
@testable import EurovisionScoreboard

class CountryListTests: XCTestCase {

    func testModernCountryListShouldNotContainDuplicates() {
        let sortedModernCountryList = Country.modernCountryList.sorted { $0.name < $1.name }
        
        let sortedModernCountryListWithRemovedDuplicates = Array(Set(sortedModernCountryList)).sorted { $0.name < $1.name }
        
        XCTAssert(sortedModernCountryList == sortedModernCountryListWithRemovedDuplicates)
    }
    
    func testFullCountryListShouldNotContainDuplicates() {
        let sortedFullCountryList = Country.fullCountryList.sorted { $0.name < $1.name }
        
        let sortedFullCountryListWithRemovedDuplicates = Array(Set(sortedFullCountryList)).sorted { $0.name < $1.name }
        
        XCTAssert(sortedFullCountryList == sortedFullCountryListWithRemovedDuplicates)
    }

    func testFullCountryListShouldNotBeEmpty() {
        XCTAssertFalse(Country.fullCountryList.isEmpty)
    }
    
    func testModernCountryListShouldNotBeEmpty() {
        XCTAssertFalse(Country.modernCountryList.isEmpty)
    }
    
}
