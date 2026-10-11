# Original audio and Large Text (Week 5)

All three audio files were synthesized locally for this project using Python's
standard library. No samples, downloaded music, or external audio tools were used.
Regenerate them with `python tools/generate_audio.py` from the project root.

| File | Description | Format |
| --- | --- | --- |
| `space_loop.wav` | 16-second minor synth drone and sparse arpeggio | Mono, 22050 Hz, 16-bit PCM |
| `menu_click.wav` | 0.12-second two-harmonic chirp | Mono, 22050 Hz, 16-bit PCM |
| `collision.wav` | 0.42-second descending tone and filtered noise burst | Mono, 22050 Hz, 16-bit PCM |

Music uses periodic pad oscillators and wrapped note tails to maintain continuity
at the loop boundary. WAV import preserves PCM samples without normalization or
trimming. AudioManager sets the music stream's forward loop from sample 0 to
352800; effects do not loop. The music bus is -10 dB, SFX -3 dB, and Master -3 dB,
with additional per-player attenuation. Both child buses send to Master.

AudioManager is an Autoload with one music player and separate click/collision
players. Music starts in either level, continues through restarts and results,
and stops on returning to the menu. Effects survive scene changes. Quit waits
for its short click before closing. The existing death guard permits one impact
sound per death, including hazard-tile deaths.

Settings is a separate Autoload. Large Text defaults off, scales Label and Button
font sizes by 25%, and saves to `user://settings.cfg`. Authored font sizes are
cached before scaling, so repeated toggles restore the original sizes exactly.
The preference applies to the menu, HUD, and results, including mission completion.
The layouts target the existing 960 x 640 logical viewport and its canvas scaling.

## Manual testing in Godot

1. Open `project.godot` and wait for imports. In the Audio bottom panel, confirm
   Master, Music, and SFX exist; Music and SFX should send to Master.
2. Press F5. Toggle Large Text with the mouse, then with keyboard focus and Space.
   Check that text grows without clipping. Toggle it off and on again.
3. Activate START GAME. Hear the short click finish and quiet music begin. Check
   the enlarged objective, score, timer, and controls. Play for at least 17 seconds
   to listen for a clean music loop boundary.
4. Hit a meteor. Hear one collision burst. Inspect the enlarged Game Over heading,
   final score/time, and buttons. Click RESTART, then repeat using Enter; music
   should not double and Large Text should remain enabled.
5. Click MAIN MENU. Its click and any remaining impact tail should finish; music
   stops. Start again and complete both levels to inspect the victory layout.
6. Return to the menu, choose QUIT GAME, and hear the click before it closes.
   Press F5 again and confirm Large Text is still enabled.
7. In the editor Audio panel, mute Music, save the bus layout, and run again:
   effects should still sound. Restore Music, mute SFX, save, and run again:
   music should still sound. Restore both buses and save when finished.
8. Resize the game window and check all screens for clipping and readability.

Automated checks (replace `godot` with the executable path if necessary):

```
godot --headless --path . --editor --quit
godot --headless --path . --script tests/audio_accessibility_checks.gd
godot --headless --path . --script tests/ui_checks.gd
godot --headless --path . --script tests/gameplay_checks.gd
```

Headless checks validate imports, routing, loop playback, UI geometry, navigation,
and preference serialization. They do not replace listening or a visual playtest.
