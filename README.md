# docker-ubuntu-desktop
Ubuntu Desktop mit Web-Zugriff via VNC/noVNC.

## Standard-Zugangsdaten
* **Passwort:** `qwer1234`

## Usage
Starte den Container und mappe den Port 6080:

```bash
docker run -it --platform=linux/amd64 -p 6080:6080 docker-ubuntu-desktop
```

## Access
Öffne nach dem Start folgende URL in deinem Browser:

`http://localhost:6080/vnc.html`

*Hinweis: Da ein selbstsigniertes Zertifikat generiert wird, musst du im Browser eventuell eine Sicherheitswarnung bestätigen.*

## Docker Build
Um das Image mit dem fest integrierten Passwort zu bauen:

```bash
docker build . -t docker-ubuntu-desktop
```

## Details zur Konfiguration
* **Display:** `:0`
* **VNC Port intern:** `5900`
* **Web Port:** `6080`
* **Passwort:** Das Passwort wurde während des Build-Prozesses in das Image geschrieben (`qwer1234`).

## License
MIT License (c) 2023 [Takahashi Akari](https://github.com/takahashi-akari)
