//
//  VideoLiveDvrViewController.swift
//  SDKQAiOS
//
//  Video Live DVR: mismos IDs y config que Android VideoLiveDvrActivity.
//  Incluye selector "Playback Mode" (Live, DVR, DVR Start, DVR VOD) como en Android.
//

import UIKit
import MediastreamPlatformSDKiOS

class VideoLiveDvrViewController: UIViewController {

    private let baseId = "5fd39e065d68477eaa1ccf5a"
    private let modes = ["Live", "DVR", "DVR Start", "DVR VOD"]

    var sdk: MediastreamPlatformSDK?
    private var currentModeIndex = 0

    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.text = "PLAYBACK MODE"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "dvr.stateLabel"
        return label
    }()

    private func updateStateLabel(mode: String, event: String? = nil) {
        var parts = ["mode=\(mode)"]
        if let e = event {
            parts.append("event=\(e)")
        }
        modeLabel.text = parts.joined(separator: " ")
    }

    private func setupHiddenTestControls() {
        // Botón de Play oculto para tests UI
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.accessibilityIdentifier = "dvr.hostPlay"
        playButton.isHidden = true
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(hostPlayTapped), for: .touchUpInside)
        view.addSubview(playButton)

        // Botón de Pause oculto para tests UI
        let pauseButton = UIButton(type: .system)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.accessibilityIdentifier = "dvr.hostPause"
        pauseButton.isHidden = true
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(hostPauseTapped), for: .touchUpInside)
        view.addSubview(pauseButton)

        // Constraints fuera de pantalla (no afectan layout visible)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -100),
            pauseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
            pauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -100)
        ])
    }

    @objc private func hostPlayTapped() {
        sdk?.play()
    }

    @objc private func hostPauseTapped() {
        sdk?.pause()
    }

    private lazy var modeSegmented: UISegmentedControl = {
        let control = UISegmentedControl(items: modes)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.accessibilityIdentifier = "dvr.modeSegmented"
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = UIColor.systemTeal
        }
        return control
    }()

    private lazy var bottomBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor(white: 0.12, alpha: 1)
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video: Live DVR"
        view.backgroundColor = .black

        let playerConfig = configForMode(0)
        let mdstrm = MediastreamPlatformSDK()
        addChild(mdstrm)
        view.addSubview(mdstrm.view)
        mdstrm.didMove(toParent: self)
        mdstrm.view.translatesAutoresizingMaskIntoConstraints = false
        mdstrm.view.accessibilityIdentifier = "dvr.playerView"
        sdk = mdstrm

        view.addSubview(bottomBar)
        bottomBar.addSubview(modeLabel)
        bottomBar.addSubview(modeSegmented)

        // Botones ocultos para tests UI
        setupHiddenTestControls()

        NSLayoutConstraint.activate([
            mdstrm.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mdstrm.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mdstrm.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mdstrm.view.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 88),

            modeLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            modeLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            modeLabel.trailingAnchor.constraint(lessThanOrEqualTo: bottomBar.trailingAnchor, constant: -16),

            modeSegmented.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8),
            modeSegmented.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            modeSegmented.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            modeSegmented.heightAnchor.constraint(equalToConstant: 32),

            playButton.topAnchor.constraint(equalTo: modeSegmented.bottomAnchor, constant: 8),
            playButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            playButton.widthAnchor.constraint(equalToConstant: 60),

            pauseButton.topAnchor.constraint(equalTo: modeSegmented.bottomAnchor, constant: 8),
            pauseButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
            pauseButton.widthAnchor.constraint(equalToConstant: 60)
        ])

        // Actualizar label con modo inicial
        updateStateLabel(mode: modes[currentModeIndex])

        // Escuchar eventos del SDK para actualizar el label
        setupSDKEventListeners()

        mdstrm.setup(playerConfig)
        SDKEventListeners.attachAll(to: mdstrm)
        mdstrm.play()
    }

    private func setupSDKEventListeners() {
        sdk?.events.listenTo(eventName: "ready") { [weak self] _ in
            self?.updateStateLabel(mode: self?.modes[self?.currentModeIndex ?? 0] ?? "", event: "ready")
        }
        sdk?.events.listenTo(eventName: "play") { [weak self] _ in
            self?.updateStateLabel(mode: self?.modes[self?.currentModeIndex ?? 0] ?? "", event: "play")
        }
        sdk?.events.listenTo(eventName: "pause") { [weak self] _ in
            self?.updateStateLabel(mode: self?.modes[self?.currentModeIndex ?? 0] ?? "", event: "pause")
        }
        sdk?.events.listenTo(eventName: "seek") { [weak self] _ in
            self?.updateStateLabel(mode: self?.modes[self?.currentModeIndex ?? 0] ?? "", event: "seek")
        }
    }

    @objc private func modeChanged() {
        let newIndex = modeSegmented.selectedSegmentIndex
        guard newIndex != currentModeIndex else { return }
        currentModeIndex = newIndex
        let config = configForMode(newIndex)
        sdk?.reloadPlayer(config)
    }

    private func configForMode(_ index: Int) -> MediastreamPlayerConfig {
        let config = MediastreamPlayerConfig()
        config.id = baseId
        config.type = .LIVE
        config.showControls = true
        config.debug = true
        config.customUI = true
        // config.environment = .DEV

        switch index {
        case 0: // Live
            break
        case 1: // DVR (ventana desde plataforma)
            config.dvr = true
        case 2: // DVR Start
            config.dvr = true
            config.dvrStart = dvrStartTime() // -1h30m UTC
            NSLog("[SDK-QA] Video Live DVR - DVR Start: dvrStart = %@", config.dvrStart ?? "")
        case 3: // DVR VOD
            config.dvr = true
            config.dvrStart = dvrVodStartTime() // -30m UTC
            config.dvrEnd = dvrVodEndTime()     // -10m UTC
            NSLog("[SDK-QA] Video Live DVR - DVR VOD: dvrStart = %@, dvrEnd = %@", config.dvrStart ?? "", config.dvrEnd ?? "")
        default:
            break
        }
        return config
    }

    private func dvrStartTime() -> String {
        let date = Calendar.current.date(byAdding: .minute, value: -(60 + 30), to: Date()) ?? Date()
        return formatISO(date)
    }

    private func dvrVodStartTime() -> String {
        let date = Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date()
        return formatISO(date)
    }

    private func dvrVodEndTime() -> String {
        let date = Calendar.current.date(byAdding: .minute, value: -10, to: Date()) ?? Date()
        return formatISO(date)
    }

    private func formatISO(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sdk?.releasePlayer()
    }

    deinit {
        sdk?.releasePlayer()
    }
}
