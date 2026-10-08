
# Meteor Dodge

## Description

Meteor Dodge is a 2D arcade survival game developed using Godot.

The player controls a spaceship and must avoid falling meteors for as long as possible.

## Genre

2D Arcade / Survival

## Planned Features

- Left and right player movement
- Randomly spawning meteors
- Collision detection
- Health or lives system
- Survival timer
- High score system
- Game-over and restart screen

## Development Status

Week 1 - Initial Godot project setup and Hello World scene.

## Tools

- Godot Engine 4
- GDScript
- Git and GitHub

## Screenshot

<img width="1917" height="1078" alt="image" src="https://github.com/user-attachments/assets/9986f3ba-da80-4b1f-be3a-db0636afbce0" />

## Week 2 - Gameplay Mechanics

The player can now move left and right using the keyboard to dodge falling meteors.

### Controls

A / Left Arrow - Move Left  
D / Right Arrow - Move Right  
Enter - Restart after Game Over

### Implemented Features

Player movement using CharacterBody2D  
Random meteor spawning  
Meteor and player collision detection  
Game-over system  
Movement squash-and-tilt effect for game feel

## Week 3 - Level Design

Meteor Dodge now has two playable, grid-based survival arenas. The project starts
at Level 1 and retains the Week 2 horizontal movement, meteor collision signal,
and movement squash-and-tilt effects.

### Levels and difficulty

- **Level 1 - Meteor Training:** Survive for 20 seconds in a blue training arena.
  Meteors spawn every 1.5 seconds and fall at 260 pixels per second.
- **Level 2 - Meteor Storm:** Survive for 30 seconds in a purple storm arena.
  Meteors spawn every 0.8 seconds and fall at 310 pixels per second. Striped X
  hazard tiles at the left and right edges are lethal, narrowing the safe lane.
  The wide central lane has no obstacles requiring vertical movement.

Both levels start in the center of the highlighted movement row. The objective
and remaining seconds appear above the arena. Avoid falling meteors; colored
floor tiles indicate traversable space, not protection from meteors.
Meteors cover the full horizontal movement lane, including the edges, so parking
beside a boundary does not bypass the dodge mechanic.

### Gameplay screenshots

These screenshots document the Week 3 levels running in Godot.

**Level 1 - Meteor Training:** The blue TileMap arena shows a falling meteor,
the player at the marked start, 18 seconds remaining, and the locked exit.

![Level 1 gameplay showing the tiled training arena, falling meteor, countdown, and locked exit](1.png)

**Level 2 - Meteor Storm:** The purple TileMap arena shows the striped edge
hazards and the game-over screen with instructions to restart the current level.

![Level 2 game-over screen showing the storm arena, striped edge hazards, and Enter-to-restart instructions](2.png)

### TileMap system and hazards

Each arena contains 420 painted 32 x 32 cells saved in its own TileMapLayer scene
under assets/. Both use the shared arena_tileset.tres and the original pixel-art
atlas arena_tiles.tres (an ImageTexture containing locally generated pixels).
The atlas includes blue/purple floor tiles, outlined boundary blocks, striped X
hazard tiles, and highlighted movement-row tiles.

Boundary tiles have TileSet physics collision polygons. Hazard tiles have a
boolean hazard custom-data field; shared level logic checks the ship center and
collision-box edges against these cells. Hazard tiles remain dangerous when an
exit opens. Meteors retain their Area2D collision signal and offscreen cleanup.
Their brighter tint makes them easier to distinguish from the floor.

The reproducible local artwork/map generator is tools/build_arenas.gd. Run it
with Godot's --headless --path . --script tools/build_arenas.gd options only when
you want to regenerate the arenas; it overwrites their saved tile layouts.
No plugins or downloaded art are required.

### Controls, goals, and transitions

- **A / Left Arrow:** Move left.
- **D / Right Arrow:** Move right.
- **Enter after game over:** Restart the current level.
- **Enter after victory:** Restart from Level 1.

Survive until the countdown reaches zero. Meteor spawning stops, remaining
meteors clear, and the labeled exit turns green. Move right and touch it to
continue. The exit is on the ship's movement row (y = 528) in both arenas.
Level 1's exit loads Level 2; Level 2's exit displays mission completion.
Touching a locked exit does nothing. If already touching it when it unlocks,
completion occurs immediately. Timers and player movement stop on game over;
scene changes are deferred and guarded against repeated transitions.

The fixed 960 x 640 playfield scales with the window while preserving its aspect
ratio, keeping the exit reachable and UI aligned.

### Inclusive-design reflection

I designed the levels with clear visual indicators, distinguishable hazards, and fair difficulty progression to support accessibility and inclusiveness while avoiding harmful cultural stereotypes.

### Running and checking

Open project.godot in Godot 4.7 (the project's configured version; verified with
4.7.2) and press F6 on level_1.tscn or F5 to run the project. main.tscn is the
shared base scene; run either level scene rather than the base by itself.

1. Dodge for 20 seconds, then move right into the open exit.
2. In Level 2, dodge for 30 seconds and avoid the striped edge tiles.
3. Touch the final exit and press Enter on the victory screen.
4. In either level, deliberately collide with a meteor; press Enter to confirm
   that the same level restarts. In Level 2 also try the striped edge hazard.
5. Open assets/arena_1.tscn and assets/arena_2.tscn to inspect the painted tiles.

Automated checks: run Godot with --headless --path . --editor --quit for import
validation, --headless --path . --quit-after 120 for a project-load check, and
--headless --path . --script tests/gameplay_checks.gd for gameplay checks.
The gameplay checks shorten countdowns to exercise their timeout signals and
use actual physics overlap and horizontal movement to check collisions/exits.
A full-duration human playthrough is still useful for judging difficulty.

For the additional structural and full-duration countdown audit, run Godot with
--headless --path . --script tests/level_audit.gd. This checks actual TileMap wall
collisions independently of the player clamp, both maps' tile resources, safe
exit routes, edge spawn coverage, the right hazard, and unlocking while already
touching the goal. It measures the original 20/30-second countdowns with meteor
spawning disabled; this is automated verification, not interactive playtesting.

All scene, script, and tileset sources belong in Git. The existing .gitignore
excludes Godot's generated .godot cache and export/build directories.
