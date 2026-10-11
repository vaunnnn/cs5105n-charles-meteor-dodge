# Meteor Dodge

Meteor Dodge is a small 2D space arcade survival game made with Godot 4 and
GDScript for CS-5105N. Move a ship horizontally, dodge falling meteors, and reach
the exit after surviving each of two levels. One hit ends the current attempt.

## Run the game

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

## Controls

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

## Gameplay

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

## Main Menu, HUD, and results

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

## Audio

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

## Accessibility

**Large Text** defaults off and increases menu, HUD, and results text sizes by
25% (rounded to whole pixels). The Settings Autoload applies the change immediately,
retains it across transitions/restarts, and saves it in `user://settings.cfg` for
later launches. Toggling off restores the authored sizes without compounding.
Keyboard focus is visible, and all menu actions are available without a mouse.

## Week 5 requirement status

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

## Verification

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

## Manual testing and submission

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

## Screenshots and prior work

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

### Outstanding Week 4 asset provenance record

These pre-existing documentation gaps remain unverified and are not part of the
Week 5 peer feedback. Runtime image scaling does not establish manual image editing.

- AI tool/model: **[TODO: enter the actual tool/model used]**.
- Exact generation prompt: **[TODO: paste the actual prompt]**.
- Manual image-editing tool: **[TODO: enter the tool, if used]**.
- Manual edits/export steps: **[TODO: describe actual edits; if none, state that]**.
