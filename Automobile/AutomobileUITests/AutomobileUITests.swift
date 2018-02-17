//
//  AutomobileUITests.swift
//  AutomobileUITests
//
//  Created by Ahmad Ansari on 18/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import XCTest

class AutomobileUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        performUITest()
    }
    
    func performUITest() {
        
        let app = XCUIApplication()
        
        let tablesQuery = app.tables
        tablesQuery.element.swipeUp()
        tablesQuery.element.swipeUp()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Load More"]/*[[".cells.staticTexts[\"Load More\"]",".staticTexts[\"Load More\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.element.swipeUp()
        tablesQuery.element.swipeUp()
        tablesQuery.element.swipeUp()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Alfa Romeo"]/*[[".cells.staticTexts[\"Alfa Romeo\"]",".staticTexts[\"Alfa Romeo\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let manufacturersButton = app.navigationBars["Models"].buttons["Manufacturers"]
        manufacturersButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["BMW"]/*[[".cells.staticTexts[\"BMW\"]",".staticTexts[\"BMW\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["X1"]/*[[".cells.staticTexts[\"X1\"]",".staticTexts[\"X1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts["BMW"].buttons["Dismiss"].tap()
        manufacturersButton.tap()
        tablesQuery.element.swipeDown()
        tablesQuery.element.swipeDown()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Land Rover"]/*[[".cells.staticTexts[\"Land Rover\"]",".staticTexts[\"Land Rover\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Range Rover"]/*[[".cells.staticTexts[\"Range Rover\"]",".staticTexts[\"Range Rover\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts["Land Rover"].buttons["Dismiss"].tap()
        manufacturersButton.tap()
        tablesQuery.element.swipeUp()
        app.navigationBars["Manufacturers"].buttons["Refresh"].tap()
        tablesQuery.element.swipeDown()
        tablesQuery.element.swipeUp()

    }
   
}

