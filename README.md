# Homepage-lite

A lightweight, Go-powered homepage dashboard for managing and monitoring your homelab services and bookmarks. Built with modern web technologies and real-time updates.

[![Homepage-lite Screenshot](Screenshots/2025-11-07-113340_hyprshot.png)](GALLERY.md)

See the [Gallery](GALLERY.md) for more screenshots.

## Features

- **Service Monitoring**
  - Real-time status checks
  - Automatic refresh every 30 seconds
  - Visual status indicators (UP/DOWN)
  - Support for both Iconify icons and custom PNG icons

- **Bookmark Management**
  - Organized by groups
  - Quick access to frequently used links
  - Custom abbreviations support
  - Flexible layout (sidebar or bottom)

- **System Metrics**
  - CPU load monitoring
  - Memory usage tracking
  - Disk usage tracking
  - Real-time updates via Server-Sent Events

- **Modern UI**
  - Responsive flexbox layout with mobile optimization
  - Multiple themes (Default, Catppuccin Latte, Tokyo Night, Nord, Dracula, Gruvbox)
  - Custom background images per theme
  - Real-time updates via JavaScript
  - Iconify integration for icons
  - Auto-reload on configuration changes via Server-Sent Events
  - Search functionality with keyboard navigation
  - Layout selector (sidebar/bottom) with mobile-friendly footer

- **Lightweight Design**
  - Single 9MB binary in production mode
  - Low memory footprint of ~25MB RAM

## Installation

Pre-built binaries for Linux (x86/ARM64), Windows, and macOS are available for download from the [GitHub releases page](https://github.com/jkerdreux-imt/homepage-lite/releases).

1. Clone the repository:
   ```bash
   git clone ssh://git@git.home/jkx/homepage-lite.git
   cd homepage-lite
   ```

2. Build and run:
   ```bash
   make build
   ./homepage-lite
   ```

3. Install:
   ```bash
   make install
   sudo vim /opt/homepage-lite/config.yaml  # Edit configuration as needed
   sudo systemctl start homepage-lite
   sudo systemctl enable homepage-lite
   ```

## Docker

Homepage-lite is available as a Docker image on GitHub Container Registry.

1. Ensure you have a `config.yaml` file (see Configuration section below).

2. Create a `docker-compose.yml` file in the same directory:

   ```yaml
   services:
     homepage-lite:
       image: ghcr.io/jkerdreux-imt/homepage-lite:latest
       ports:
         - "8888:8888"
       volumes:
         - /path/to/your/config/folder/:/app/config/
       restart: unless-stopped
   ```

3. Run the container:

   ```bash
   docker-compose up -d
   ```

The application will be available at `http://localhost:8888`.

## Configuration

Configuration is managed through `config.yaml`. Example structure:

```yaml
services:
  - group: Home
    items:
      - name: Home Assistant
        url: https://homeassistant.local:8123
        description: Home automation
        icon: home-assistant.png

      - name: Dockge
        url: http://192.168.1.10:5001/
        description: Dockge
        icon: mdi-docker

bookmarks:
  - group: Developer
    items:
      - name: GitHub
        url: https://github.com
        abbr: GH

settings:
  theme: default
  title: My Homelab
  port: 8888

# Configuration changes are detected automatically and trigger a page reload.
```

## Themes

Homepage-lite supports multiple built-in themes with custom background images:

- **Default**: Dark theme with metro
- **Catppuccin Latte**: Light theme with soft colors
- **Tokyo Night**: Dark blue theme with town lights
- **Nord**: Cool nordic theme with winter forest
- **Dracula**: Purple cosmic theme
- **Gruvbox**: Warm retro theme

Themes can be changed via the footer selector and are persisted in localStorage.

## Development

- Built with Go 1.25.1+
- Uses vanilla JavaScript for dynamic updates
- Iconify for icon rendering
- Template-based HTML rendering
- Flexbox-based responsive layout with mobile-first approach
- CSS custom properties for theming
- Server-Sent Events for real-time updates

## License

See [LICENSE](LICENSE) for full details.
