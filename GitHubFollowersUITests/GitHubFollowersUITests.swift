//
//  GitHubFollowersUITests.swift
//  GitHubFollowersUITests
//
//  Created by Altan on 16.01.2024.
//

import XCTest

final class GitHubFollowersUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
    }
    
    func testGetFollowersButton() throws {
        let app = XCUIApplication()
        app.launch()
                
        let textField = app.textFields["Enter a username"]
        let firstCell = app.collectionViews.cells.firstMatch
        
        textField.tap()
        textField.typeText("Dhh")
        textField.typeText("\n")
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testDeleteFavoriteRow() throws {
        let app = XCUIApplication()
        app.launch()
        
        let favoritesTab = XCUIApplication().tabBars["Tab Bar"].buttons["Favorites"]
        let firstRow = app.tables.cells.firstMatch
        let deleteButton = firstRow.buttons["Delete"]
        
        favoritesTab.tap()
        firstRow.swipeLeft()
        deleteButton.tap()
                
        XCTAssertFalse(firstRow.exists)
    }
    
    func testFavoritedRow() throws {
        let app = XCUIApplication()
        app.launch()
        
        let favoritesTab = XCUIApplication().tabBars["Tab Bar"].buttons["Favorites"]
        let firstRow = app.tables.cells.firstMatch
        let firstCell = app.collectionViews.cells.firstMatch
        
        favoritesTab.tap()
        firstRow.tap()
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 6))
    }
    
    func testGithubProfileButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let textField = app.textFields["Enter a username"]
        let firstCell = app.collectionViews.cells.firstMatch
        let githubProfileButton = app.scrollViews.otherElements.buttons["GitHub Profile"]
        let doneButton = app.buttons["Bitti"]
        
        textField.tap()
        textField.typeText("Dhh")
        textField.typeText("\n")
        firstCell.tap()
        githubProfileButton.tap()
        
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
    }
    
    func testGithubFollowersButton() throws {
        let app = XCUIApplication()
        app.launch()
                
        let textField = app.textFields["Enter a username"]
        let firstCell = app.collectionViews.cells.firstMatch
        let githubFollowersButton = app.scrollViews.otherElements.buttons["GitHub Followers"]
        
        textField.tap()
        textField.typeText("Dhh")
        textField.typeText("\n")
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        firstCell.tap()
        githubFollowersButton.tap()
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testAddFavoriteButton() {
        let app = XCUIApplication()
        app.launch()
                
        let textField = app.textFields["Enter a username"]
        let firstCell = app.collectionViews.cells.firstMatch
        let addButton = app.navigationBars["Dhh"].buttons["Add"]
        let alertButton = app.buttons["Hooray!"]
        
        textField.tap()
        textField.typeText("Dhh")
        textField.typeText("\n")
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 6))
        
        addButton.tap()
        
        XCTAssertTrue(alertButton.exists)
    }
}
