# MediastreamPlatformSDKiOS — API Pública

Documentación de los **eventos**, **métodos** y **propiedades públicas** expuestos por el SDK para integrar el reproductor en tu aplicación iOS.

---

## Índice

1. [Eventos](#eventos)
2. [EventManager (suscribirse y disparar eventos)](#eventmanager-suscribirse-y-disparar-eventos)
3. [Métodos públicos](#métodos-públicos)
4. [Propiedades públicas](#propiedades-públicas)

---

## Eventos

El SDK dispara estos eventos a través de `mdstrm.events`. Tu app puede suscribirse con `events.listenTo(eventName:action:)`.

### Reproducción

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `ready` | — | El reproductor está listo para reproducir. |
| `play` | `String?` (opcional: `"seek"`, `"buffering"`) | Reproducción iniciada o reanudada. |
| `pause` | — | Reproducción pausada. |
| `finish` | — | El contenido llegó al final. |
| `seek` | `["from": lastPosition]` | El usuario realizó un seek. |
| `buffering` | `Date` (inicio del buffering) | El reproductor está en buffering. |
| `durationUpdated` | `String` (duración formateada) | Se conoce la duración del contenido. |
| `currentTimeUpdate` | `String` (tiempo actual formateado) | Actualización del tiempo actual. |

### Errores y fuentes

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `error` | `String` (mensaje) | Error de reproducción o de la API. |
| `failedToPlayToEndTime` | `String` (descripción) | Error al intentar reproducir hasta el final. |
| `newsourceadded` | — | Nueva fuente de contenido remoto cargada. |
| `localsourceadded` | — | Fuente local (archivo) añadida. |

### Fullscreen

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `onFullscreen` | — | El reproductor entró en fullscreen. |
| `offFullscreen` | — | El reproductor salió de fullscreen. |

### Conectividad

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `conectionStablished` | — | Conexión de red establecida. |
| `conectionLost` | — | Se perdió la conexión. |

### Anuncios (IMA / VAST-VMAP)

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `onAdsLoaderInitialize` | datos del loader | Inicialización del cargador de anuncios. |
| `onAdLoadingError` | `String` (mensaje) | Error al cargar anuncios. |
| `onAdEvent` | tipo de evento IMA | Cualquier evento de anuncio. |
| `onAdLoaded` | — | Anuncio cargado. |
| `onAdPlay` | datos | Anuncio reproduciéndose. |
| `onAdPause` | — | Anuncio pausado. |
| `onAdResume` | — | Anuncio reanudado. |
| `onAdEnded` | — | Anuncio terminado. |
| `onAdSkipped` | — | Anuncio saltado. |
| `onAdError` | `String` (mensaje) | Error en el anuncio. |
| `onDAIAdEvent` | tipo de evento | Evento de anuncio DAI (Dynamic Ad Insertion). |

### Audio en vivo

| Evento | Información | Descripción |
|--------|-------------|-------------|
| `onLiveAudioCurrentSongChanged` | `[String: Any]` o vacío | En streams de audio en vivo, cambió la canción/pista actual. |

---

## EventManager (suscribirse y disparar eventos)

Instancia accesible como `mdstrm.events` (tipo `EventManager`).

### Suscribirse a eventos

```swift
// Sin información
mdstrm.events.listenTo(eventName: "ready", action: {
    print("Reproductor listo")
})

// Con información
mdstrm.events.listenTo(eventName: "error", action: { (information: Any?) in
    if let message = information as? String {
        print("Error: \(message)")
    }
})
```

### Disparar eventos (uso avanzado)

```swift
mdstrm.events.trigger(eventName: "nombreEvento", information: valorOpcional)
```

### Quitar listeners

```swift
// Quitar listeners de un evento
mdstrm.events.removeListeners(eventNameToRemoveOrNil: "play")

// Quitar todos los listeners
mdstrm.events.removeListeners(eventNameToRemoveOrNil: nil)
```

> **Nota:** `releasePlayer()` ya elimina todos los listeners internamente.

---

## Métodos públicos

### Configuración y ciclo de vida

| Método | Descripción |
|--------|-------------|
| `setup(_ config: MediastreamPlayerConfig)` | Configura el reproductor y carga el contenido según la config (cuenta, id, tipo, etc.). Llamar antes de `play()`. |
| `releasePlayer()` | Libera reproductor, anuncios, observers y vistas. **Debe llamarse** al salir de la pantalla (ej. `viewWillDisappear`). |
| `reloadPlayer(_ config: MediastreamPlayerConfig)` | Recarga con otra configuración (ej. otro vídeo o episodio). |
| `reloadAssets()` | Recarga los assets del contenido actual. |
| `preparePlayer(player: AVPlayer)` | Punto de extensión cuando el reproductor está listo (uso avanzado / integración con `AssetPlaybackManager`). |

---

### Control de reproducción

| Método | Descripción |
|--------|-------------|
| `play()` | Inicia o reanuda la reproducción. |
| `pause()` | Pausa la reproducción. |
| `stop()` | Detiene la reproducción (equivale a pausar). |
| `tooglePlay()` | Alterna entre play y pause. |
| `seekTo(_ time: Double)` | Salta a la posición indicada (tiempo en segundos). |
| `fordward(_ time: Double)` | Avanza `time` segundos. |
| `backward(_ time: Double)` | Retrocede `time` segundos. |
| `changeSpeed(_ speed: Float)` | Cambia la velocidad de reproducción (ej. 1.0, 1.5, 2.0). |

---

### Episodios / lista

| Método | Descripción |
|--------|-------------|
| `playNext()` | Reproduce el siguiente episodio (requiere `loadNextAutomatically` y que el backend devuelva `next` en el JSON). |
| `playPrev()` | Reproduce el episodio anterior (requiere `prev` en el JSON). |

---

### Fullscreen, PiP y Cast

| Método | Descripción |
|--------|-------------|
| `enterFullscreen(fullscreen: Bool)` | Entra (`true`) o sale (`false`) de fullscreen. |
| `startPiP()` | Inicia Picture in Picture. |
| `stopPiP()` | Detiene Picture in Picture. |
| `showCastButton(show: Bool)` | Muestra u oculta el botón de Cast. |
| `showDaiClickerView(show: Bool)` | Muestra u oculta la vista de clic en anuncios DAI. |

---

### Anuncios

| Método | Descripción |
|--------|-------------|
| `resumeAd()` | Reanuda un anuncio pausado. |
| `getAdManager() -> IMAAdsManager?` | Devuelve el gestor de anuncios IMA (uso avanzado). |
| `areAdsPlaying() -> Bool` | Indica si se está reproduciendo un anuncio. |

---

### Estado y comprobaciones

| Método | Descripción |
|--------|-------------|
| `checkIsPlaying() -> Bool` | Indica si el reproductor está reproduciendo. |
| `checkIsBuffering() -> Bool` | Indica si está en estado de buffering. |
| `isLocalFile() -> Bool` | Indica si la fuente es un archivo local (vs. streaming). |

---

### Tiempo y duración

| Método | Descripción |
|--------|-------------|
| `getCurrentPosition() -> Int` | Posición actual en segundos. |
| `getCurrentTime() -> Int64` | Tiempo actual (formato interno). |
| `getDuration() -> Int` | Duración total del contenido en segundos. |
| `getLiveDuration() -> Int?` | Duración en vivo (DVR), si aplica. |
| `getTimeString(from time: CMTime) -> String` | Convierte un `CMTime` a string formateado (ej. "01:23"). |
| `getPreviousCurrentTime() -> Int64` | Tiempo anterior (para seek/analytics). |
| `setPreviousCurrentTime(time: Int64)` | Establece el tiempo anterior. |

---

### Metadatos del contenido

| Método | Descripción |
|--------|-------------|
| `getCurrentMediaConfig() -> MediastreamPlayerConfig` | Devuelve la configuración actual del contenido. |
| `getMediaTitle() -> String` | Título del contenido actual. |
| `getMediaPoster() -> String` | URL del póster/caratula. |

---

### Métricas y calidad

| Método | Descripción |
|--------|-------------|
| `getResolution() -> String` | Resolución actual del vídeo (ej. "1920x1080"). |
| `getScreenResolution() -> String` | Resolución de la pantalla. |
| `getHeight() -> Int` | Altura del vídeo en píxeles. |
| `getBitrate() -> Int` | Bitrate actual. |
| `getBandwidth() -> Double` | Ancho de banda estimado. |
| `getInitBufferingTime() -> Int64` | Tiempo de buffering inicial. |
| `setInitBufferingTime(time: Date)` | Establece el inicio del buffering (métricas). |
| `getWaitingCount() -> Int` | Número de veces que ha entrado en estado de espera/buffering. |
| `clearWaitingCount()` | Resetea el contador de esperas. |

---

### Identificadores y sesión

| Método | Descripción |
|--------|-------------|
| `getHostname() -> String` | Host del stream. |
| `getUniqueId() -> String` | ID único del dispositivo (vendor). |
| `getSessionID() -> String` | ID de sesión. |
| `getPBId() -> String` | ID de reproductor (PB). |
| `getSId() -> String` | SId (sesión). |
| `getUId() -> String` | UId (usuario). |
| `getVersion() -> String` | Versión del SDK. |

---

### Utilidades y otros

| Método | Descripción |
|--------|-------------|
| `removeObservers()` | Quita observers del reproductor (normalmente lo hace `releasePlayer()`). |
| `playBackgroundAudio()` | Configura la sesión de audio para reproducción en segundo plano. |
| `handleAppStateChange()` | Para reaccionar a cambios de estado de la app (background/foreground). |

---

## Propiedades públicas

### Control directo (lectura/escritura)

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `currentTime` | `Double` | Tiempo actual en segundos. **Setter:** al asignar se realiza un seek. |
| `volume` | `Int` | Volumen 0–100. Getter y setter. |

### Eventos y reproductor base

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `events` | `EventManager` | Gestor de eventos: `listenTo`, `trigger`, `removeListeners`. |
| `player` | `AVPlayer?` | Instancia del reproductor AVFoundation. |
| `playerViewController` | `AVPlayerViewController?` | Controlador del reproductor. |
| `playerLayer` | `AVPlayerLayer?` | Capa de vídeo. |
| `pipController` | `AVPictureInPictureController?` | Controlador de Picture in Picture. |

### UI y tiempo formateado

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `currentStringDuration` | `String?` | Duración formateada (ej. "01:23:45"). |
| `currentStringValue` | `String?` | Tiempo actual formateado. |
| `timeSliderMaximumValue` | `Float?` | Valor máximo del slider de tiempo. |
| `timeSliderMinimunValue` | `Float?` | Valor mínimo del slider de tiempo. |
| `currentTimeValue` | `Float?` | Valor actual del slider. |
| `dismissButton` | `UIButton?` | Botón de cerrar (si se usa). |
| `customUIView` | `MediastreamCustomUIView?` | Vista de UI personalizada. |

### Metadatos y Cast

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `castUrl` | `String` | URL para Cast. |
| `mediaTitle` | `String` | Título del medio. |
| `initPreparePlayerTimestamp` | `Date?` | Timestamp de inicio de preparación del reproductor. |

### Estado del reproductor

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `isPlayerReady` | `Bool` | Indica si el reproductor está listo. |
| `isPlayingAds` | `Bool` | Indica si se está reproduciendo un anuncio. |

---

## Uso típico

```swift
// 1. Crear instancia y config
let mdstrm = MediastreamPlatformSDK()
let config = MediastreamPlayerConfig()
config.accountID = "tu-account-id"
config.id = "id-del-contenido"
config.type = .VOD
config.environment = .PRODUCTION
config.customUI = true

// 2. Suscribirse a eventos
mdstrm.events.listenTo(eventName: "ready", action: { print("Listo") })
mdstrm.events.listenTo(eventName: "error", action: { info in print("Error: \(info ?? "")") })

// 3. Añadir vista y reproducir
mdstrm.view.frame = containerView.bounds
containerView.addSubview(mdstrm.view)
mdstrm.setup(config)
mdstrm.play()

// 4. Al salir de pantalla
mdstrm.releasePlayer()
```

---

*Documentación generada a partir del código de MediastreamPlatformSDKiOS. Versión del SDK: ver `getVersion()` o el podspec.*
