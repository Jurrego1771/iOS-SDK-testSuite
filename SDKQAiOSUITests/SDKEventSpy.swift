//
//  SDKEventSpy.swift
//  SDKQAiOSUITests
//
//  Helper para capturar eventos del SDK y valores clave en tests UI.
//

import Foundation

/// Spy que acumula eventos del SDK y valores útiles para asserts en tests.
class SDKEventSpy {
    private(set) var events: [String] = []
    private(set) var lastCurrentTime: Double = 0
    private(set) var lastDuration: Double = 0
    private(set) var lastSeekFrom: Double?
    private(set) var lastError: String?

    /// Adjunta listeners a un EventManager del SDK.
    /// Nota: Necesita acceso al EventManager; en la app de QA puede exponerse vía un helper o botón oculto.
    func attach(to events: EventManager) {
        events.listenTo(eventName: "ready") { [weak self] _ in
            self?.events.append("ready")
        }
        events.listenTo(eventName: "play") { [weak self] _ in
            self?.events.append("play")
        }
        events.listenTo(eventName: "pause") { [weak self] _ in
            self?.events.append("pause")
        }
        events.listenTo(eventName: "seek") { [weak self] info in
            self?.events.append("seek")
            if let dict = info as? [String: Any],
               let from = dict["from"] as? Double {
                self?.lastSeekFrom = from
            }
        }
        events.listenTo(eventName: "currentTimeUpdate") { [weak self] info in
            if let t = info as? Double {
                self?.lastCurrentTime = t
            }
        }
        events.listenTo(eventName: "durationUpdated") { [weak self] info in
            if let d = info as? Double {
                self?.lastDuration = d
            }
        }
        events.listenTo(eventName: "buffering") { [weak self] _ in
            self?.events.append("buffering")
        }
        events.listenTo(eventName: "error") { [weak self] info in
            self?.events.append("error")
            self?.lastError = info as? String
        }
        events.listenTo(eventName: "failedToPlayToEndTime") { [weak self] _ in
            self?.events.append("failedToPlayToEndTime")
        }
    }

    /// Verifica si los eventos dados ocurrieron en orden (no necesariamente consecutivos).
    func contains(_ expectedEvents: [String]) -> Bool {
        var index = 0
        for event in events {
            if event == expectedEvents[index] {
                index += 1
                if index == expectedEvents.count { return true }
            }
        }
        return false
    }

    /// Reinicia el estado del spy (útil entre tests).
    func reset() {
        events.removeAll()
        lastCurrentTime = 0
        lastDuration = 0
        lastSeekFrom = nil
        lastError = nil
    }
}
