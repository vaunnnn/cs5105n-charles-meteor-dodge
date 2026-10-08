
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

![Level 1 gameplay showing the tiled training arena, falling meteor, countdown, and locked exit](screenshots/1.png)

**Level 2 - Meteor Storm:** The purple TileMap arena shows the striped edge
hazards and the game-over screen with instructions to restart the current level.

![Level 2 game-over screen showing the storm arena, striped edge hazards, and Enter-to-restart instructions](screenshots/2.png)

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

## Week 4 - Art, Animation & Particles

### Requirement status

| Requirement | Final review result |
| --- | --- |
| Two AnimationPlayer animations | Implemented: looping `idle` and `move` scale tracks. |
| Movement-state animation selection | Implemented using horizontal input; blocked movement still selects `move`. |
| Action-triggered particle effect | Implemented: movement emits a cyan CPU particle trail; visual readability still needs manual confirmation. |
| AI-generated image integrated | Supplied PNG exists and is referenced by the shared main scene in both levels. |
| AI image edited | Unverified: no source-image editing history has been provided. |
| AI tool, exact prompt, and editing documentation | Incomplete: fill in the placeholders below with actual details. |
| Playable game ready for submission | Automated gameplay checks pass; visual playthrough, AI documentation, and inclusion of currently untracked assets remain outstanding. |

### Player animations

`player.tscn` contains an AnimationPlayer with two looping scale animations:

- **idle:** A 1.6-second breathing pulse around the original `(0.35, 0.35)` scale,
  ranging from `(0.343, 0.343)` to `(0.357, 0.357)`.
- **move:** A 0.4-second squash/stretch loop, reaching `(0.378, 0.322)`.

`player.gd` starts idle on scene entry and selects move while horizontal input
is held, returning to idle when the input axis is zero. It only calls `play()`
when the animation changes, so loops are not restarted each physics frame.
AnimationPlayer alone controls Sprite2D scale; the script retains directional
rotation. Holding movement against a wall still selects move, although the
particle trail stops when the ship no longer changes position.
Game over and victory disable player physics but do not stop AnimationPlayer;
the last selected animation continues. This review preserves that behavior.

### Movement particles

The player's `MovementTrail` is a CPUParticles2D node with 20 particles and a
0.4-second lifetime. A native 16 x 16 radial GradientTexture2D, additive
CanvasItemMaterial, and fading cyan color ramp provide a soft glowing trail
without downloaded particle textures or a glow post-processing requirement.
The project continues to use GL Compatibility.

The emitter switches to the trailing side, 20 pixels horizontally from the
player center and 6 pixels below it. World coordinates (`local_coords = false`)
leave old particles behind. Actual horizontal displacement enables emission;
idle, blocked movement, and disabled player physics stop new particles.
Existing particles fade out naturally. Collision shapes are not animated.

### AI-generated background and editing record

The supplied AI-generated image is stored at
`res://assets/backgrounds/space_background.png`.
Both levels inherit `Background/Space` from `main.tscn`: a full-viewport
TextureRect on CanvasLayer -1, behind the arena, player, meteors, and HUD.
Mouse filtering is Ignore, and the background has no collision objects.

The image uses Ignore Size and Keep Aspect Covered. Godot scales and centrally
crops the portrait image to fill the 960 x 640 viewport without distorting it.
Full-viewport anchors follow the viewport size. `canvas_items` remains enabled;
`project.godot` has no explicit stretch-aspect override. This is a rendering
adjustment, not evidence of manually editing the source PNG.

The Week 3 floor, highlighted movement-row, and outer boundary tiles are now
transparent to reveal the space image across the play area. Their cells remain
in both maps, and the invisible boundary tiles retain their collision shapes.
Striped hazard tiles remain visible with their existing hazard data.
The arena generator preserves this presentation.
The Week 3 screenshots above document the earlier grid appearance.

Complete this record before submission; these details have not been supplied:

- **AI tool and model:** [TODO: enter the actual tool/model used.]
- **Exact generation prompt:** [TODO: paste the exact prompt used.]
- **Manual image-editing tool:** [TODO: enter the actual editor used.]
- **Manual edits to the generated image:** [TODO: describe the actual edits and
  export steps; if none were made, state that and complete the required edit.]

The background asset exists and is integrated. The requirement for an edited
AI image is **not yet verified**; runtime scaling/cropping alone is not claimed
to satisfy that requirement.

### Week 4 screenshots

**Movement particles:** A glowing cyan trail follows the tilted player during
movement. This screenshot shows the earlier arena grid, before the floor and
outer border visuals were hidden.

![Week 4 movement effect showing a cyan particle trail behind the tilted player in Level 1](screenshots/particles.png)

**Space background:** The integrated AI-generated space image fills the play
area with the floor and outer grid hidden. The player, meteor, objective,
countdown, and exit remain visible.

![Week 4 Level 1 showing the space background with the grid hidden and gameplay elements visible](screenshots/background.png)

These supplied screenshots document appearance at two stages of Week 4;
they do not replace checking animation loops and gameplay in motion.

### Verification and submission checklist

Static review confirms that player node paths match the scene, both animations
target only Sprite2D scale, the script controls rotation separately, and the
background references the actual PNG. `main.gd` expects an Arena supplied by
the level scenes; use F5 or run a level scene, not `main.tscn` alone.

Run the editor/import, startup, gameplay, and level-audit commands documented
under Week 3. Headless checks exercise resources and gameplay but do not prove
visual quality or replace an interactive playthrough.

Final review with Godot 4.7.2 after hiding both floor and outer grids: editor/import and
project-startup checks passed, all 20 gameplay checks passed, and the full
level audit completed with zero failures (including the real 20/30-second
countdowns). All literal scene/script resource paths resolve, and
`git diff --check` passed. No interactive visual playtest was performed during
this review. No requested headless check was blocked or unavailable.

The review found no missing literal resource references, broken gameplay node
paths, conflicting animation/script scale writes, or GDScript parse errors in
the validated project. Meteor spawning, controls, collisions, level transitions,
and restart behavior passed the existing automated checks. Only README content
was intentionally changed during this final review; no gameplay changes were needed.

Before submitting:

1. Run F5 and inspect idle breathing, sustained movement squash/stretch, and
   left/right tilt. Release movement and confirm idle resumes.
2. Check that cyan particles trail behind in both directions, remain behind
   when reversing, and fade after stopping or game over.
3. Confirm the space image is visible through the former floor grid, with
   readable meteors, ship, HUD, and Level 2 hazard markers. Confirm that the
   invisible outer boundaries still stop movement. Resize the
   window and inspect the crop and coverage.
4. Play both levels, test meteor/hazard collisions, exits, and Enter-to-restart.
5. Fill in the AI provenance and editing placeholders above, and capture
   current Week 4 screenshots after visual testing.
6. Include the PNG, its `.import` settings, scenes, scripts, tile resources,
   screenshots, and README in the eventual GitHub submission. Exclude `.godot/`.
   At review time, `assets/backgrounds/` and `screenshots/` are untracked, and
   the old root-level screenshots are marked deleted. Include the moved images
   so the README links resolve on GitHub. PNG files use Git LFS via
   `.gitattributes`; Git LFS is installed locally, but a fresh GitHub clone and
   LFS asset download have not been tested by this review.

Week 4 is not claimed complete until the AI editing/documentation gaps and
manual visual checks are resolved. No commit or push is performed by this review.
