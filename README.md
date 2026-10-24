# Meteor Dodge

A cumulative development record for Weeks 1-8. Each weekly section records the
project at that stage; later weeks describe subsequent changes. For the Week 5
run instructions and controls, see [Week 5](#week-5---ui-audio-and-accessibility).
Follow [README instructions](README_INSTRUCTIONS.md) when adding documentation.

## Week 1 - Project Setup

### Description

Meteor Dodge is a 2D arcade survival game developed using Godot.

The player controls a spaceship and must avoid falling meteors for as long as possible.

### Genre

2D Arcade / Survival

### Planned Features

- Left and right player movement
- Randomly spawning meteors
- Collision detection
- Health or lives system
- Survival timer
- High score system
- Game-over and restart screen

### Development Status

Week 1 - Initial Godot project setup and Hello World scene.

### Tools

- Godot Engine 4
- GDScript
- Git and GitHub

### Screenshot

<img width="1917" height="1078" alt="image" src="https://github.com/user-attachments/assets/9986f3ba-da80-4b1f-be3a-db0636afbce0" />

## Week 2 - Gameplay Mechanics

The player can now move left and right using the keyboard to dodge falling meteors.

### Controls

A / Left Arrow - Move Left\
D / Right Arrow - Move Right\
Enter - Restart after Game Over

### Implemented Features

Player movement using CharacterBody2D\
Random meteor spawning\
Meteor and player collision detection\
Game-over system\
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

## Week 5 - UI, Audio, and Accessibility

Meteor Dodge is a small 2D space arcade survival game made with Godot 4 and
GDScript for CS-5105N. Move a ship horizontally, dodge falling meteors, and reach
the exit after surviving each of two levels. One hit ends the current attempt.

### Run the game

1. Open `project.godot` in Godot **4.7.2**, the version used for validation. The
   project declares Godot 4.7 and uses GL Compatibility and TileMapLayer scenes;
   older Godot 4 releases have not been validated.
2. Wait for the editor to import the image and WAV assets.
3. Press **F5**. The project opens `ui/main_menu.tscn`.
4. Select **START GAME** to load `level_1.tscn`.

For direct level testing, open `level_1.tscn` or `level_2.tscn` and press F6.
`main.tscn` is their shared base and expects an Arena supplied by a level scene;
do not run that base scene alone. No plugins or downloaded dependencies are needed.
PNG and WAV files use Git LFS; after cloning, run `git lfs pull` if assets are
missing or appear as text pointers.

### Controls

| Input | Action |
| --- | --- |
| A / Left Arrow | Move left |
| D / Right Arrow | Move right |
| Mouse click | Activate a menu button or toggle |
| Tab / Shift+Tab / menu arrow keys | Move UI focus |
| Enter / Space | Activate the focused UI control |
| Enter after death | Restart the current level while Restart has its default focus |
| Enter after victory | Restart from Level 1 while Restart has its default focus |

Keyboard activation respects focus: selecting MAIN MENU and pressing Enter returns
to the menu rather than restarting.

### Gameplay

| Level | Survival objective | Meteor interval | Falling speed |
| --- | --- | --- | --- |
| 1 - Meteor Training | 20 seconds | 1.5 seconds | 260 pixels/second |
| 2 - Meteor Storm | 30 seconds | 0.8 seconds | 310 pixels/second |

The ship moves at 380 pixels/second with directional tilt, idle/movement
squash-and-stretch animations, and a cyan movement trail. Meteors spawn across
the horizontal lane, emit a collision signal on contact, and clean themselves up
below the screen. Level 2 also has lethal striped tiles at the lane edges.
There is no health/lives system or persistent high-score system.

When the objective countdown ends, spawning stops, remaining meteors clear, and
the exit turns green. Move right into it to advance to Level 2 or finish the
mission. Edge hazards remain dangerous after the exit opens. Boundary collision
remains active even though the former floor and wall artwork is transparent to
show the space background.

### Main Menu, HUD, and results

The Main Menu includes the title, subtitle, movement instructions, START GAME,
QUIT GAME, and the Large Text toggle. Quit waits briefly for its click sound to
finish before closing the application.

The reusable `ui/hud.tscn` uses a **CanvasLayer** above gameplay. It displays:

- The level objective and countdown until the exit opens.
- Survival time accumulated using frame delta, displayed to one decimal place.
- Score: **10 points per completed second** of the current level attempt.

Survival time and score continue while moving to an open exit, then stop on death,
mission completion, or a level transition. They reset when a level loads or
restarts; they are not cumulative across both levels.

A hit stops player movement and both gameplay timers, clears meteors, and shows
GAME OVER with final score/time, RESTART, and MAIN MENU. Restart reloads the
current level. Mission completion uses the same results panel; Restart begins
again at Level 1. Results remain hidden during active play.

The UI shares a dark navy theme with cyan/purple accents, containers, and consistent
spacing. Layouts target the configured 960 x 640 viewport with `canvas_items`
window scaling. Interactive resize/readability checks remain part of manual testing.

### Audio

`default_bus_layout.tres` is explicitly configured in `project.godot`:

| Bus | Output | Saved gain |
| --- | --- | --- |
| Master | Device output | -3 dB |
| Music | Master | -10 dB |
| SFX | Master | -3 dB |

Music and effects can be muted or adjusted independently in Godot's Audio panel.
There are no in-game volume sliders. Additional per-player attenuation keeps the
music below the collision effect.

`AudioManager` is an Autoload with one music player and separate click/collision
players. The original 16-second synth loop starts in gameplay, continues through
restarts/results, and stops at the Main Menu. Runtime forward-loop settings cover
the full WAV. Button chirps and the one-shot death sound use SFX and survive scene
changes; repeated hit callbacks cannot replay the same death sound.

All three mono, 22050 Hz, 16-bit PCM WAV files were generated locally with Python's
standard library, without downloaded samples or music. Assets and generation
instructions are documented in [the audio guide](assets/audio/README.md).
`tools/generate_audio.py` reproduces them; regeneration is not needed to play.

### Accessibility

**Large Text** defaults off and increases menu, HUD, and results text sizes by
25% (rounded to whole pixels). The Settings Autoload applies the change immediately,
retains it across transitions/restarts, and saves it in `user://settings.cfg` for
later launches. Toggling off restores the authored sizes without compounding.
Keyboard focus is visible, and all menu actions are available without a mouse.

### Week 5 requirement status

| Requirement | Status |
| --- | --- |
| Updating CanvasLayer HUD | Implemented: score, survival time, objective countdown |
| Main Menu, Start/Quit, Restart/Menu navigation | Implemented |
| Background music and SFX on separate buses | Implemented with original local audio |
| Functional accessibility feature | Implemented: persistent Large Text |
| Five-minute peer playtest | **PENDING: no real session or duration supplied** |
| Documented and implemented feedback-based change | **PENDING: observation and requested improvement remain placeholders** |
| Student commit and push to personal GitHub repository | **PENDING: student must review and perform this manually** |

Complete [WEEK5_PLAYTEST.md](WEEK5_PLAYTEST.md) with genuine observations before
claiming the peer-playtest requirements. Automated audit fixes are not peer feedback.

### Verification

The final audit uses the installed Godot 4.7.2 executable. Commands below assume
`godot` is on PATH; otherwise substitute its full path (PowerShell: `& "path/to/godot.exe"`).

```sh
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/gameplay_checks.gd
godot --headless --path . --script tests/ui_checks.gd
godot --headless --path . --script tests/ui_checks.gd -- --quit-check
godot --headless --path . --script tests/audio_accessibility_checks.gd
godot --headless --path . --script tests/level_audit.gd
```

The gameplay checks exercise movement, automatic spawning/falling, physical
collisions, cleanup, progression, and restart. UI checks exercise mouse navigation,
CanvasLayer, score/time updates and death freezing; the separate Quit check exits
through the real button with a failure watchdog. Audio/accessibility checks cover
WAV imports, routing, loop playback, repeated-hit protection, effect continuity,
saved settings reloads, and enlarged UI bounds/overlap at 960 x 640. The level audit
also measures the real 20/30-second objective durations with meteors disabled.

**Final audit (2026-10-11, Godot 4.7.2):** editor/import and project startup passed;
22 gameplay checks, 14 UI checks, 132 audio/accessibility assertions, and 23 level
audit checks passed with zero failures. The separate Quit-button process exited
successfully. All literal local resource/documentation references resolve, all
three WAV headers are valid, and `git diff --check` passed. No ignored caches or
temporary files are tracked. Initial test shutdown warnings were resolved by
stopping audio and allowing its release cycle before exit. Sandboxed reruns
reported a Windows certificate-store access error; tests still exited 0 and the
unsandboxed editor/import validation was clean.

Only automated headless validation and source/resource inspection are performed
by this audit. No interactive visual/audio playtest or five-minute peer session
is claimed. Headless audio checks cannot judge how the mix sounds to a listener.

### Manual testing and submission

1. Press F5. Navigate with mouse and keyboard; toggle Large Text both ways.
2. Start, move in both directions, and confirm score/time advance and meteors fall.
3. Listen for a music loop after 16 seconds. Hit a meteor: one impact sound,
   stopped movement/spawning, frozen stats, and readable results should follow.
4. Test Restart by click and Enter, then MAIN MENU by click and keyboard. Confirm
   resets, focus behavior, click sounds, and a single music track.
5. Complete both level objectives/exits, including Level 2 hazard checks. Inspect
   victory results and restart to Level 1.
6. Quit through the menu, relaunch, and confirm Large Text is remembered. Resize
   the window and inspect all screens in both text modes.
7. Verify Music/SFX independently in the Audio panel by muting and saving one bus
   at a time before running; restore both buses afterward.
8. Conduct the five-minute peer playtest, record real feedback, implement a targeted
   improvement, and retest/document it in WEEK5_PLAYTEST.md.
9. Review changes and assets, then personally commit and push. Verify the GitHub
   branch and LFS assets afterward; a fresh remote clone is not tested by this audit.

The repository ignores `.godot/`, export/build directories, Python bytecode,
temporary files, and diagnostic logs. Keep source assets, `.import` settings,
`.gd.uid` files, tests, and generators. Screenshots are documentation assets.
`node_2d.tscn` is a retained legacy scene and is not part of the launch path.
No source assets were deleted as part of this audit.

### Week 5 screenshots

**Main Menu**

![Week 5 main menu](screenshots/mainmenu.png)

**HUD**

![Week 5 gameplay HUD](screenshots/hud.png)

**Game Over**

![Week 5 game-over screen](screenshots/gameover.png)

These existing captures document the UI, not a new peer playtest.

### Screenshots and prior work

Existing captures (not evidence of a new peer playtest):

- [Main Menu](screenshots/mainmenu.png), [HUD](screenshots/hud.png),
  [Game Over](screenshots/gameover.png).
- Earlier level captures: [Level 1](screenshots/1.png), [Level 2](screenshots/2.png).
- Earlier art captures: [movement particles](screenshots/particles.png),
  [space background](screenshots/background.png).

The two levels each contain 420 saved 32-pixel tiles. `tools/build_arenas.gd`
reproduces the tile artwork/maps and overwrites their resources when run; it is
not needed for normal play. Player animations and particles remain in
`player.tscn`; the supplied space image is in `assets/backgrounds/`.

#### Outstanding Week 4 asset provenance record

These pre-existing documentation gaps remain unverified and are not part of the
Week 5 peer feedback. Runtime image scaling does not establish manual image editing.

- AI tool/model: **[TODO: enter the actual tool/model used]**.
- Exact generation prompt: **[TODO: paste the actual prompt]**.
- Manual image-editing tool: **[TODO: enter the tool, if used]**.
- Manual edits/export steps: **[TODO: describe actual edits; if none, state that]**.

## Week 6 — AI & Enemies

### Hunter Drone and finite state machine

Level 2 now adds one reusable `HunterDrone` (`enemies/hunter_drone.tscn` and
`enemies/hunter_drone.gd`). Its native-drawn magenta wings and circular sensor
distinguish it from the player and orange meteors. The sensor is cyan during
patrol, amber during pursuit, red with a range ring during attack, and grey when
disabled. No external artwork or plugin is required.

| State | Actual behavior | Transitions |
| --- | --- | --- |
| PATROL | Follow predefined upper/middle arena waypoints at 60 pixels/second, advancing on arrival. Side approaches offer detection opportunities without descending directly onto the initial spawn. | A player-group body detected within 250 pixels enters CHASE. |
| CHASE | Follow a NavigationAgent2D path at 120 pixels/second; refresh the player's current target every 0.2 seconds. | Enter ATTACK within 35 pixels and the attack area; return to PATROL beyond 290 pixels or if the player disappears. |
| ATTACK | Stop moving, show a red ring, and wait a 0.45-second windup before emitting the existing hit signal if the player is still within 35 pixels. | Return to CHASE beyond 45 pixels; return to PATROL beyond 290 pixels or if the player disappears. |

The larger release distances prevent rapid state switching at the detection and
attack boundaries. An attack has a one-second cooldown and reports only one hit
per drone instance, matching the one-hit elimination rules. The windup gives the
horizontally moving player a chance to evade. Speeds, radii, windup, cooldown,
and patrol positions are exported for review and balancing in the Inspector.

### Detection, collisions, and navigation

The drone is a CharacterBody2D on collision layer 2, with a layer-1 mask for the
existing walls/player. Its DetectionArea and AttackArea have no collision layer
and monitor layer 1; only bodies in the existing `player` group qualify. Meteors
and the exit continue detecting layer 1, so the drone cannot activate either.
The player retains its original layer/mask and horizontal movement.

`level_2.tscn` contains a saved NavigationRegion2D/NavigationPolygon with usable
vertices and polygon indices. It covers drone-center coordinates x=48..912,
y=176..528, leaving clearance inside the existing border tiles (interior
x=32..928, y=160..544). Inspection found no internal physical blockers: striped
tiles use `hazard` metadata rather than collision polygons. Their player-hit
behavior is preserved; they do not block this flying drone's paths. Consequently
valid paths across this open region are usually straight. No new walls or map
edits were needed. If physical obstacles are added later, update/rebake the
navigation polygon to exclude them and verify routes around them.

Movement waits for NavigationServer synchronization and uses the agent's next
path position. Missing maps and empty/finished paths stop movement safely;
partial paths stop at their reachable endpoint. Targets and drone position are
bounded to the arena. There is no direct-movement fallback that bypasses an
unavailable navigation path.

### Level 2 integration and lifecycle

Only Level 2 assigns the exported drone PackedScene. A scene-owned one-shot
timer spawns it after three seconds at `(240, 260)`, away from `(480, 528)`.
Repeated spawn calls cannot create duplicates. The drone's `hit_player` signal
connects once to `main.gd`'s authoritative `_on_player_hit()`, preserving the
existing sound, results, score freeze, and restart behavior.

`_stop_hazards()` cancels a pending drone spawn and stops any existing drone's
physics and attacks. It runs on death, exit unlock, and restart/menu transitions;
the drone stays disabled through completion. Reloading frees the previous drone
and timer. Level 1 retains its original scenes, objective, and meteor gameplay.
Level 2 retains its 30-second objective, meteors, hazards, and exit progression.

### Automated verification

Run from the project directory with Godot 4.7.2 (`godot` below means the executable
on PATH, or use PowerShell `& "full/path/to/godot.exe"`):

```sh
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/enemy_ai_checks.gd
godot --headless --path . --script tests/gameplay_checks.gd
godot --headless --path . --script tests/ui_checks.gd
godot --headless --path . --script tests/ui_checks.gd -- --quit-check
godot --headless --path . --script tests/audio_accessibility_checks.gd
godot --headless --path . --script tests/level_audit.gd
```

The AI suite isolates random meteors and uses real physics frames and Area2D
overlaps to check delayed spawning, patrol movement/waypoints, detection,
chasing a moving target, attack windup and game over, state release conditions,
valid navigation paths, missing/empty navigation data, shutdown, restart,
single signal connections, unchanged Level 1 timing, and reaching Level 2's exit.
It accelerates the survival timer for its completion check; the existing level
audit separately checks actual 20/30-second countdowns. Automated checks do not
establish interactive difficulty or visual/audio quality.

Validation on 2026-10-24 with the official Godot 4.7.2 Windows console build:
editor/import and 120-frame project startup exited 0; all 35 enemy AI checks,
22 gameplay checks, 14 UI checks, 132 audio/accessibility assertions, and 23
level-audit checks passed with zero failures. The separate Quit-button check
also exited 0. Existing test files were preserved. `git diff --check` passed.
Godot was downloaded to a temporary tools folder outside the repository because
no installed executable was found on PATH or in the searched local locations.

During automated debugging, an inferred WeakRef test variable required an
explicit type. Navigation tests were also corrected to account for Godot's
default-map fallback and deferred NavigationServer synchronization; an inactive
map guard now stops movement. The final AI rerun passed after those corrections.
That audit did not include an interactive playtest, student modification, or
Week 6 screenshots. The subsequent screenshot capture is documented below.

### Final Week 6 implementation review (2026-10-25)

Codex reviewed the drone script/scene, shared level lifecycle, navigation region,
player/meteor collision configuration, tests, screenshot embeds, and AI attribution.
No reproducible gameplay defect, syntax/type error, broken node reference, or
duplicate game-over connection was found. No gameplay code changes were needed
during this review. The four pre-existing test scripts were preserved.

The enemy AI suite was expanded from 35 to 47 checks. Added scenarios verify
that an overlapping non-player CharacterBody2D is ignored, meteor/exit masks
exclude the drone, a real meteor-player collision disables an existing drone,
horizontal movement input escapes the attack windup, the attack hysteresis band
does not cause an out-of-range hit, re-entering ATTACK resets the windup, and a
freed player safely returns the drone to PATROL. The non-player fixture uses the
same body type as the player and tests actual Area2D overlap before checking
group filtering.

All commands listed above were rerun with Godot 4.7.2: editor/import, 120-frame
startup, the expanded 47-check AI suite, 22 gameplay checks, 14 UI checks, the
separate Quit-button process, 132 audio/accessibility assertions, and 23 level
audit checks all exited 0. The level audit included real 20/30-second countdowns.
The final runs reported no script/runtime errors. `git diff --check` passed and
all embedded local README image paths resolved. Godot generated import metadata
for the three new screenshots.

NavigationAgent2D is actively used for patrol and pursuit, with valid saved
navigation polygons and real path queries/movement checked by the AI suite.
The open arena has no internal physical obstacles requiring detours. Layer 2
keeps the drone out of the meteor/exit detection masks; player movement and
hazard metadata remain unchanged. Shutdown and restart checks confirm disabled
motion/attacks, cancelled spawning, scene cleanup, and a single hit connection
on the fresh drone.

Completion and evasion are established under controlled automated scenarios.
The AI suite isolates random meteor pressure and accelerates its completion
timer; the real-duration level audit also disables meteors. Neither establishes
human difficulty with both hazards active. Interactive playtesting of full
Level 2, readability, sound, and attack feedback remains pending. In particular,
review the central patrol detection gap described below. ATTACK deliberately
holds still in the 35..45-pixel release band without hitting; beyond 45 pixels
the drone resumes pursuit. Confirm this behavior feels fair during play.

### Week 6 screenshots

These 960 x 640 screenshots were captured by Codex directly from Godot 4.7.2's
rendered Level 2 viewport on 2026-10-25. A temporary automated capture script
disabled meteor spawning to isolate the drone and positioned the player beneath
its patrol after the first capture. The drone spawned through its normal timer
and entered CHASE and ATTACK through its actual detection/FSM logic. No gameplay
scripts or scene resources were changed for the captures. These images document
the states' appearance; they do not establish a student playtest or game balance.

**PATROL:** The drone's cyan sensor is visible in the upper arena, away from the
player's starting position, shortly after its three-second spawn delay.

![Week 6 Level 2 Hunter Drone patrolling with a cyan sensor above the player's starting position](screenshots/week6_patrol.png)

**CHASE:** After the player is positioned within detection range, the sensor
turns amber and the drone navigates toward the player.

![Week 6 Level 2 Hunter Drone chasing the detected player with an amber sensor](screenshots/week6_chase.png)

**ATTACK:** The drone reaches attack range and displays its red sensor and ring
during the windup, before reporting a hit.

![Week 6 Level 2 Hunter Drone in attack range with a red sensor and attack ring beside the player](screenshots/week6_attack.png)

### AI assistance and developer review

Codex drafted the GDScript FSM, native drone appearance, navigation region,
shared lifecycle integration, automated checks, and this documentation in
response to the Week 6 implementation brief. This is AI-assisted implementation,
not evidence that the student personally wrote, modified, or playtested it.

The developer must personally review and understand the state enum, transition
conditions, detection masks/group filtering, path following, and game-over
signal connection. Open the scenes/scripts in Godot and inspect the navigation
region against the actual walls. Play Level 2 with only A/D or arrows, checking
that approaching either side of the patrol can trigger pursuit and that the
windup permits an escape. Review the upper patrol's limited detection coverage:
the central starting position can remain outside detection while stationary;
meteors continue providing pressure there. Decide whether that balance suits
the assignment and record any actual tuning rather than claiming it happened.

Personal work still pending:

- **Manual review/modifications:** [TODO: record what you actually inspected or
  changed, why, and the relevant script/Inspector values; explicitly state if
  no modifications were made.]
- **Debugging record:** [TODO: record real issues, reproduction steps, fixes, and
  retest results; state if no additional issues were found.]
- **Interactive playtest:** [TODO: record date, duration, controls, pursuit/escape
  observations, fairness with meteors/hazards, and any tuning/retest results.]
- **Lifecycle review:** [TODO: verify death, survival expiry, exit completion,
  Restart, and Main Menu; confirm stopped drones and one fresh drone per retry.]
- **Visual/accessibility check:** [TODO: inspect drone/state cues at 960x640,
  both text sizes, and resized windows.]

For direct testing open `level_2.tscn` and press F6; wait three seconds for the
drone. Use **Debug > Visible Navigation** and **Visible Collision Shapes** to
inspect paths/areas. Test real 30-second survival and move right to the green
exit. Repeat after death and restart. Review changes before making your own
submission commit/push; this implementation performs neither action.

## Week 7 - Planned

Work and documentation are pending.

## Week 8 - Planned

Work and documentation are pending.
