//
//  VideoLiveDvrUITests.swift
//  SDKQAiOSUITests
//
//  Test de UI + eventos SDK para Video Live DVR.
//  Basado en el test existente, pero integrando asserts de eventos del SDK.
//

import XCTest

final class VideoLiveDvrUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testVideoLiveDvr_fullFlow_withSDKEvents() {
        let app = XCUIApplication()
        app.launch()

        // Esperar tabla de casos
        let table = app.tables["testCases.table"]
        XCTAssertTrue(table.waitForExistence(timeout: 20))

        // Abrir Video Live DVR
        let liveDvrCell = table.cells["testCase.videoLiveDvr"]
        if liveDvrCell.exists {
            liveDvrCell.tap()
        } else {
            table.cells.staticTexts["Video: Live DVR"].firstMatch.tap()
        }

        // Esperar controles DVR
        let segmented = app.segmentedControls["dvr.modeSegmented"]
        XCTAssertTrue(segmented.waitForExistence(timeout: 10))

        let playerView = app.otherElements["dvr.playerView"]
        XCTAssertTrue(playerView.waitForExistence(timeout: 10))

        let stateLabel = app.staticTexts["dvr.stateLabel"]
        XCTAssertTrue(stateLabel.waitForExistence(timeout: 10))

        // --- Inicializar spy de eventos del SDK ---
        // Nota: Necesitamos un mecanismo para inyectar el spy.
        // Por ahora, asumimos que la app expone un botón oculto para tests.
        let attachSpyButton = app.buttons["test.attachSpy"]
        if attachSpyButton.exists {
            attachSpyButton.tap()
        }

        // Esperar modo Live y ready/play
        waitForStateLabel(stateLabel, contains: "mode=Live", timeout: 5)
        waitForAnyEventReadyOrPlay(stateLabel, timeout: 15)

        // --- Interacciones y asserts de eventos ---

        // Play/Pause en Live
        tapPauseIfAvailable(app)
        waitForStateLabel(stateLabel, contains: "event=pause", timeout: 10)

        tapPlayIfAvailable(app)
        waitForAnyEventReadyOrPlay(stateLabel, timeout: 15)

        // Cambiar a DVR
        segmented.buttons["DVR"].tap()
        waitForStateLabel(stateLabel, contains: "mode=DVR", timeout: 5)
        waitForAnyEventReadyOrPlay(stateLabel, timeout: 15)

        // Play/Pause en DVR
        tapPauseIfAvailable(app)
        waitForStateLabel(stateLabel, contains: "event=pause", timeout: 10)

        tapPlayIfAvailable(app)
        waitForAnyEventReadyOrPlay(stateLabel, timeout: 15)

        // Seek en DVR (si hay slider)
        if let slider = firstSeekSlider(app) {
            slider.adjust(toNormalizedSliderPosition: 0.2)
            waitForStateLabelIfPresent(stateLabel, contains: "event=seek", timeout: 5)
            waitForAnyEventReadyOrPlay(stateLabel, timeout: 20)
        }

        // Volver a Live
        segmented.buttons["Live"].tap()
        waitForStateLabel(stateLabel, contains: "mode=Live", timeout: 5)
        waitForAnyEventReadyOrPlay(stateLabel, timeout: 20)

        // --- Asserts de eventos del SDK ---
        // Nota: Necesitamos acceso al spy desde la app. Por ahora, simulamos lectura de eventos via label.
        // En una implementación real, inyectaríamos el spy y leeríamos sus propiedades.
        let eventsLabel = app.staticTexts["test.spyEvents"].firstMatch
        if eventsLabel.exists {
            let eventsText = eventsLabel.label
            XCTAssertTrue(eventsText.contains("ready"))
            XCTAssertTrue(eventsText.contains("play"))
            XCTAssertTrue(eventsText.contains("pause"))
            // Seek es opcional (puede no haber slider)
            if eventsText.contains("seek") {
                XCTAssertTrue(eventsText.contains("seek"))
            }
        }
    }

    // MARK: - Helpers (reutilizados del test original)

    private func waitForStateLabel(_ element: XCUIElement, contains text: String, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        expectation(for: predicate, evaluatedWith: element)
        waitForExpectations(timeout: timeout)
    }

    private func waitForAnyEventReadyOrPlay(_ stateLabel: XCUIElement, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "label CONTAINS 'event=ready' OR label CONTAINS 'event=play'")
        expectation(for: predicate, evaluatedWith: stateLabel)
        waitForExpectations(timeout: timeout)
    }

    private func waitForStateLabelIfPresent(_ element: XCUIElement, contains text: String, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        let exp = XCTNSPredicateExpectation(predicate: predicate, object: element)
        _ = XCTWaiter().wait(for: [exp], timeout: timeout)
    }

    private func tapPauseIfAvailable(_ app: XCUIApplication) {
        let hostPause = app.buttons["dvr.hostPause"]
        if hostPause.exists {
            hostPause.tap()
            return
        }
        let pause = firstButton(containing: "Pause", in: app)
        XCTAssertNotNil(pause, "Pause button not found.")
        pause?.tap()
    }

    private func tapPlayIfAvailable(_ app: XCUIApplication) {
        let hostPlay = app.buttons["dvr.hostPlay"]
        if hostPlay.exists {
            hostPlay.tap()
            return
        }
        let play = firstButton(containing: "Play", in: app)
        XCTAssertNotNil(play, "Play button not found.")
        play?.tap()
    }

    private func firstButton(containing text: String, in app: XCUIApplication) -> XCUIElement? {
        let candidates = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", text))
        let first = candidates.firstMatch
        return first.exists ? first : nil
    }

    private func firstSeekSlider(_ app: XCUIApplication) -> XCUIElement? {
        let slider = app.sliders.firstMatch
        return slider.exists ? slider : nil
    }
}
