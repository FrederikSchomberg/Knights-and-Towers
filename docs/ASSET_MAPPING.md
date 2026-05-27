# Asset-Mapping für Tiny Swords

Dieses Projekt läuft zuerst komplett mit gezeichneten Mockup-Formen. Für die Präsentation könnt ihr dadurch schon Gameplay zeigen, ohne dass alle Sprites sauber eingebunden sind.

## Empfohlener Asset-Ordner

Legt den heruntergeladenen Tiny-Swords-Free-Pack nach dem Entpacken ungefähr so ab:

```text
res://assets/tiny_swords/
```

Wichtig: Die Asset-Dateien selbst dürfen laut Tiny-Swords-Lizenz nicht weiterverkauft, weiterverpackt oder als eigenes Asset-Pack verteilt werden. Für euer Spiel/Uni-Projekt könnt ihr sie nutzen und bearbeiten.

## Welche Assets passen zu welchen Spielobjekten?

| Spielobjekt | Tiny-Swords-Richtung |
|---|---|
| Spieler / King | Human Unit, Warrior, King oder Knight-artige Einheit |
| Standardgegner | Rote/schwarze Human Unit als feindliche Fraktion oder eigenes Goblin-Mockup |
| Ork/Boss | Falls gekauft: Enemy Pack. Sonst farblich abgewandelte Human Units |
| Turm | Defense Tower / Watchtower / Castle Building |
| Burg | Castle Building |
| Map | Grass Terrain Tiles, Dirt/Path Tiles, Rocks, Bushes, Trees |
| UI | Paper Banner, Wood Table, Buttons, Life Bars, Icons |
| Treffer | Dust, Explosion, Fire oder kleine Partikel |

## So ersetzt ihr die Mockups durch Sprites

1. Öffnet zum Beispiel `scenes/Enemy.tscn`.
2. Fügt unter `Enemy` einen `AnimatedSprite2D` oder `Sprite2D` hinzu.
3. Weist das passende Sprite aus `res://assets/tiny_swords/` zu.
4. Im Script `enemy.gd` könnt ihr die `_draw()`-Funktion auskommentieren oder leer lassen.
5. Wiederholt das für `Player.tscn`, `Tower.tscn` und die Map.

## Pixel-Art-Einstellungen

In `project.godot` ist bereits gesetzt:

```text
textures/canvas_textures/default_texture_filter=0
```

Dadurch bleiben Pixel-Art-Sprites scharf und werden nicht weichgezeichnet.
