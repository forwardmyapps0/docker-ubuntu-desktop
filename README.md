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
* **NoVNC Port:** `6080`
* **Minecraft Port:** `25565`
* **SSH Port:** `22`
* **WEB Port:** `8080`

## License
MIT License (c) 2023 [Takahashi Akari](https://github.com/takahashi-akari)
