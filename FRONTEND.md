# Frontend Documentation

## Current Stack
- HTML: Templates in `/templates/`
- CSS: Custom CSS with flexbox layout and mobile-first responsive design
- Icons: [Iconify](https://iconify.design/) + [Dashboard Icons](https://github.com/walkxcode/dashboard-icons)
- Dynamic Updates: Vanilla JavaScript
- Live Updates: Server-Sent Events (SSE)

## Structure

### Layout Options
Two layout modes available via footer selector:
1. **Sidebar**: Bookmarks in left sidebar, services in main area
2. **Bottom**: Bookmarks at bottom, services in main area

### Sections
- Header with title and search bar
- Main content (services organized by groups)
- Bookmarks (sidebar or bottom depending on layout)
- Footer with metrics, layout selector, theme selector, and version

## Components

### Services Card
```html
<a class='card status-up|down' href='url' data-service-id='hash'>
  <img src='icon' /> <!-- Iconify or custom PNG -->
  <div class='card-content'>
    <h3>Service Name</h3>
    <p>Description</p>
  </div>
</a>
```

### Bookmarks Card
```html
<a class='card bookmark-card' href='url'>
  <h3>ABBR</h3>
  <div class='card-content'>
    <p>Name</p>
    <span class='url'>url</span>
  </div>
</a>
```

### Metrics Display
```html
<div class="metrics metrics-inline">
  <div>
    <span class="iconify metric-icon" data-icon="mdi:cpu-64-bit"></span>
    <div class="metric-info">
      <h3>CPU Load</h3>
      <div class="value" id="cpu-value">XX%</div>
    </div>
  </div>
  <!-- Memory and Disk similar -->
</div>
```

### Search Popup
```html
<div id="search-popup" class="search-popup">
  <div class="search-popup-content">
    <input type="text" id="search-input" placeholder="Type to search...">
    <div id="search-results" class="search-results">
      <!-- Search results populated by JavaScript -->
    </div>
  </div>
</div>
```

## CSS Architecture

### Theme System
- Multiple built-in themes (Default, Catppuccin Latte, Tokyo Night, Nord, Dracula, Gruvbox)
- CSS custom properties for colors:
  - `--card-bg`: Card background color
  - `--card-border`: Card border color
  - `--text-primary`: Primary text color
  - `--text-secondary`: Secondary text color
  - `--accent`: Accent color
  - `--status-up`: Success color
  - `--status-down`: Error color
  - `--theme-background`: Background image URL

### Background Images
Each theme has a custom background image with filters applied via `body::before`:
```css
body::before {
  content: '';
  position: fixed;
  background-image: var(--theme-background);
  filter: blur(2px) saturate(100%) brightness(70%);
  opacity: 0.5;
}
```

### Layout System
```css
.columns {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 1.5rem;
  
  & > div {
    flex: 1 1 240px;
    min-width: 240px;
  }
}
```

### Cards
```css
.card {
  max-width: 400px;
  background: var(--card-bg);
  backdrop-filter: blur(10px);
  border: 1px solid var(--card-border);
  padding: 0.5rem 0.75rem;
  transition: all 0.3s ease;
}
```

### Responsive Behavior
- **Desktop**: Sidebar layout with 300px left sidebar, services use remaining space
- **Mobile**: Footer elements stack vertically to prevent horizontal overflow
- Bottom layout: Services and bookmarks full width, stacked vertically
- Cards limited to 400px width (except in bottom mode for bookmarks)
- Footer uses 95% width container with mobile-optimized stacking

## Interactive Features

### Search
- Modal popup triggered by pressing Enter or any alphanumeric key (when not in input fields)
- Real-time filtering of services and bookmarks by name, description, or abbreviation
- Keyboard navigation (arrows for selection, Enter to open, Escape to close, Tab for navigation)
- Max 6 results displayed for better UX
- Results show icons and are clickable
- Search data loaded from rendered page content

### Theme Switching
- Theme selector in footer
- Persisted in localStorage
- Dynamic CSS loading via `<link id="theme-css">`

### Layout Switching
- Layout selector in footer (Sidebar/Bottom)
- Persisted in localStorage
- Dynamic class toggling on body

### Status Updates
- Real-time via Server-Sent Events (/events endpoint)
- Visual indicator changes (left border color: green for UP, red for DOWN)
- Automatic refresh every 30 seconds in background
- SSE reconnects automatically when page becomes visible
- Updates include service status changes and system metrics

### Server-Sent Events (SSE)
- Persistent connection to /events for real-time updates
- Handles three event types: reload, metrics, service
- Automatic reconnection on connection loss
- Buffered message channel (100 messages) to prevent blocking

## Font Sizing
- Service title (h3): 1.045rem
- Service description (p): 0.88rem
- Footer controls: 0.85rem
- Metrics: 0.75rem (value), 0.65rem (label)
- Bookmark abbreviation (h3): 0.9rem
- Bookmark name: 0.95rem
- Bookmark URL: 0.75rem

## Color Palette Examples

### Default Theme
- Card: rgba(30, 30, 46, 0.3)
- Border: rgba(137, 180, 250, 0.3)
- Text: #cdd6f4
- Accent: #89b4fa

### Tokyo Night
- Card: rgba(26, 27, 38, 0.3)
- Border: rgba(122, 162, 247, 0.3)
- Text: #c0caf5
- Accent: #7aa2f7

## Notes
- All themes use semi-transparent cards with backdrop-filter blur
- Background images are filtered (blur, saturate, brightness) for better readability
- Layout and theme preferences persist across page reloads via localStorage
- Enhanced keyboard support: any alphanumeric key opens search, Enter confirms
- Mobile-optimized footer with vertical stacking to prevent overflow
- Real-time metrics and status updates via JavaScript and SSE
- Service status checking uses HEAD requests with 5-second timeout and TLS verification disabled
- Config file changes trigger automatic page reload via SSE
- Search popup uses backdrop blur and is fully keyboard navigable