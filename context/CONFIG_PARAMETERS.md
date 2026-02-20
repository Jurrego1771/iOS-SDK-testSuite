# MediastreamPlayerConfig — Parámetros de configuración

Listado de todos los **parámetros** que puedes pasar a la configuración del reproductor (`MediastreamPlayerConfig`). Se usan en `mdstrm.setup(config)` antes de reproducir.

---

## Índice

1. [Identificación y cuenta](#identificación-y-cuenta)
2. [Tipo de contenido y recurso](#tipo-de-contenido-y-recurso)
3. [Reproducción](#reproducción)
4. [Interfaz de usuario (UI)](#interfaz-de-usuario-ui)
5. [Anuncios (Google IMA)](#anuncios-google-ima)
6. [DRM (FairPlay)](#drm-fairplay)
7. [DVR (live)](#dvr-live)
8. [Analytics y tracking](#analytics-y-tracking)
9. [Now Playing / Control Center / notificaciones](#now-playing--control-center--notificaciones)
10. [Picture in Picture y Cast](#picture-in-picture-y-cast)
11. [Episodios (siguiente/anterior)](#episodios-siguienteanterior)
12. [Otros](#otros)
13. [Enums y tipos auxiliares](#enums-y-tipos-auxiliares)
14. [Métodos de configuración (no propiedades)](#métodos-de-configuración-no-propiedades)

---

## Identificación y cuenta

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`accountID`** | `String?` | `nil` | ID de la cuenta Mediastream. |
| **`id`** | `String?` | `nil` | ID del contenido (vídeo, episodio o live). Obligatorio para contenido de plataforma. |
| **`playerId`** | `String?` | `nil` | ID del reproductor. Se envía en la query del JSON (`player=...`). |
| **`customerID`** | `String?` | `nil` | ID de cliente. Se incluye en las peticiones de media (`c=...`). |
| **`distributorId`** | `String?` | `nil` | ID del distribuidor. |
| **`accessToken`** | `String?` | `nil` | Token de acceso para contenido restringido. Se envía en la URL de media. |
| **`appName`** | `String?` | `nil` | Nombre de la aplicación. |
| **`appVersion`** | `String?` | `nil` | Versión de la aplicación. |

---

## Tipo de contenido y recurso

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`type`** | `VideoTypes` | `.VOD` | Tipo de contenido: `.VOD`, `.LIVE`, `.EPISODE`. Define la ruta de la API (`video`, `live-stream`, `episode`). |
| **`environment`** | `Environments` | `.PRODUCTION` | Entorno: `.PRODUCTION` (`https://mdstrm.com`) o `.DEV` (`https://develop.mdstrm.com`). |
| **`src`** | `NSURL?` | `nil` | URL directa del recurso (archivo local o remoto). Si se asigna, se reproduce este recurso sin llamar a la API por `id`. |
| **`videoFormat`** | `AudioVideoFormat` | `.HLS` | Formato preferido: `.HLS`, `.M4A`, `.MP3`. |
| **`maxProfile`** | `String?` | `nil` | Perfil máximo (calidad). Se envía en la query de media (`max_profile=...`). |
| **`referer`** | `String?` | `nil` | Valor del header `referrer` en peticiones HTTP. |
| **`protocoL`** | `String` | `"https"` | Protocolo (p. ej. `https`). |

---

## Reproducción

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`autoplay`** | `Bool` | `true` | Si debe iniciar la reproducción automáticamente al estar listo. |
| **`startAt`** | `Int` | `0` | Segundos desde los que empezar la reproducción. |
| **`volume`** | `Int` | `-1` (sin fijar) | Volumen inicial 0–100. `-1` indica no sobrescribir. |

---

## Interfaz de usuario (UI)

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`customUI`** | `Bool` | `false` | Usar la UI personalizada del SDK (controles, botones siguiente/anterior, etc.). |
| **`showControls`** | `Bool` | `true` | Mostrar controles del reproductor. |
| **`showTitle`** | `FlagStatus` | `.ENABLE` | Mostrar título: `.ENABLE`, `.DISABLE`, `.NONE`. |
| **`showDismissButton`** | `Bool` | `false` | Mostrar botón de cerrar. |
| **`showBackgroundOnTitleAndControls`** | `Bool` | `true` | Fondo en la barra de título y controles. |
| **`defaultOrientation`** | `UIInterfaceOrientation?` | `nil` | Orientación por defecto. |
| **`enablePlayerZoom`** | `Bool` | `false` | Habilitar zoom en el reproductor. |

---

## Anuncios (Google IMA)

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`adURL`** | `String?` | `nil` | URL del tag de anuncios (VAST/VMAP). Si se asigna, el SDK intenta cargar anuncios. |
| **`adTagParametersForDAI`** | `[AdRequestParam: String]` | `[:]` | Parámetros para solicitudes de anuncios DAI (clave según `AdRequestParam`). |
| **`googleImaPPID`** | `String?` | `nil` | PPID para Google IMA. |
| **`googleImaLanguage`** | `String?` | `nil` | Idioma para la UI de IMA. |

Para añadir atributos custom a la URL de anuncios (no DAI): **`addAdCustomAttribute(_ key: String, value: String)`**.

---

## DRM (FairPlay)

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`drmUrl`** | `String?` | `nil` | URL del servicio DRM. |
| **`appCertificateUrl`** | `String?` | `nil` | URL del certificado de aplicación para FairPlay. |

Headers DRM: **`addDrmHeader(_ key: String, value: String)`** (varios). Solo lectura de lo ya añadido: **`drmHeaders`** → `[(String, String)]`.

---

## DVR (live)

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`dvr`** | `Bool` | `false` | Habilitar DVR en live. |
| **`windowDvr`** | `Int` | `0` | Ventana DVR (segundos u offset). Se envía como `dvrOffset` en la query. |
| **`dvrStart`** | `String?` | `nil` | Inicio de ventana DVR. |
| **`dvrEnd`** | `String?` | `nil` | Fin de ventana DVR. |

---

## Analytics y tracking

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`trackEnable`** | `Bool` | `true` | Enviar métricas al collector de Mediastream. |
| **`analyticsCustom`** | `String?` | `nil` | Parámetro custom para analytics. |

Youbora: **`addYouboraExtraParams(_ value: String)`** (varios). Lectura: **`getYouboraExtraParams() -> [String]`**.

---

## Now Playing / Control Center / notificaciones

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`updatesNowPlayingInfoCenter`** | `Bool` | `false` | Actualizar Control Center / Now Playing con título, tiempo, etc. |
| **`notificationSongName`** | `String` | `""` | Nombre de la canción/pista en Now Playing. |
| **`notificationDescription`** | `String` | `""` | Descripción en Now Playing. |
| **`notificationAlbumName`** | `String` | `""` | Nombre del álbum en Now Playing. |
| **`notificationImageUrl`** | `String` | URL por defecto | URL de la imagen en Now Playing (carátula). |

---

## Picture in Picture y Cast

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`canStartPictureInPictureAutomaticallyFromInline`** | `Bool` | `true` | Permitir iniciar PiP automáticamente desde inline (también usado por IMA). |
| **`showCastButton`** | `Bool` | `false` | Mostrar botón de Cast en la UI. |
| **`useCustomCastButton`** | `UIButton?` | `nil` | Botón custom para Cast en lugar del por defecto. |

---

## Episodios (siguiente/anterior)

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`loadNextAutomatically`** | `Bool` | `false` | Cargar prev/next desde el JSON y habilitar botones y autoplay al siguiente episodio. |

Ver [NEXT_PREVIOUS_EPISODE.md](NEXT_PREVIOUS_EPISODE.md).

---

## Otros

| Parámetro | Tipo | Valor por defecto | Descripción |
|----------|------|-------------------|-------------|
| **`debug`** | `Bool` | `false` | Modo debug (más logs). |
| **`needReload`** | `Bool` | `false` | Marca interna para forzar recarga al cambiar de episodio. |
| **`showReplayView`** | `Bool` | `false` | Mostrar vista de “repetir” al terminar (si no hay siguiente episodio). |
| **`tryToGetMetadataFromLiveWhenAudio`** | `Bool` | `true` | Intentar obtener metadatos del stream cuando es audio en vivo. |

---

## Enums y tipos auxiliares

### VideoTypes

```swift
public enum VideoTypes: String {
    case LIVE = "live-stream"
    case VOD = "video"
    case EPISODE = "episode"
}
```

### Environments

```swift
public enum Environments: String {
    case PRODUCTION = "https://mdstrm.com"
    case DEV = "https://develop.mdstrm.com"
}
```

### AudioVideoFormat

```swift
public enum AudioVideoFormat: String {
    case HLS = "hls"
    case M4A = "mp4"
    case MP3 = "mp3"
}
```

### FlagStatus (showTitle)

```swift
public enum FlagStatus {
    case ENABLE
    case DISABLE
    case NONE
}
```

### AdRequestParam (parámetros DAI)

Enum con muchos casos (ej. `gdpr`, `gdprConsent`, `custParams`, etc.) para las claves de `adTagParametersForDAI`. Ver definición completa en `MediastreamPlayerConfig.swift` (aprox. líneas 13–42).

---

## Métodos de configuración (no propiedades)

| Método | Descripción |
|--------|-------------|
| **`addAdCustomAttribute(_ key: String, value: String)`** | Añade un par clave-valor a la URL de anuncios (query `custom.key=value`). |
| **`addDrmHeader(_ key: String, value: String)`** | Añade un header para peticiones DRM. |
| **`addYouboraExtraParams(_ value: String)`** | Añade un parámetro extra para Youbora. |
| **`hasAds() -> Bool`** | Indica si hay URL de anuncios configurada (`adURL != nil`). |
| **`getAdQueryString(for baseURL: String) -> String`** | Genera el query string para la URL de anuncios. |
| **`getYouboraExtraParams() -> [String]`** | Devuelve los parámetros extra de Youbora. |
| **`getMediaQueryString() -> String`** | Genera el query string para la URL de media (sdk, dnt, c, access_token, max_profile, dvrOffset, etc.). |

---

## Ejemplo de configuración mínima (VOD)

```swift
let config = MediastreamPlayerConfig()
config.accountID = "tu-account-id"
config.id = "id-del-video"
config.type = .VOD
config.environment = .PRODUCTION
mdstrm.setup(config)
mdstrm.play()
```

## Ejemplo con más opciones (episodios + UI + Now Playing)

```swift
let config = MediastreamPlayerConfig()
config.accountID = "tu-account-id"
config.id = "id-del-episodio"
config.type = .EPISODE
config.environment = .PRODUCTION
config.videoFormat = .MP3
config.loadNextAutomatically = true
config.customUI = true
config.updatesNowPlayingInfoCenter = true
config.showReplayView = true
config.accessToken = "token-si-es-contenido-cerrado"
config.playerId = "mi-player-id"
mdstrm.setup(config)
mdstrm.play()
```

---

*Fuente: `MediastreamPlatformSDKiOS/Classes/MediastreamPlayerConfig.swift`. Para la API del reproductor, ver [API.md](API.md).*
