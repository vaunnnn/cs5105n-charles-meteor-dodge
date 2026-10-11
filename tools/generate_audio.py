"""Generate original Meteor Dodge audio using only Python's standard library.

Run from any directory with: python tools/generate_audio.py
No recordings, samples, downloads, or third-party composition are used.
"""
from array import array
from pathlib import Path
import math
import random
import sys
import wave

RATE = 22050
TAU = math.tau
OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
OUT.mkdir(parents=True, exist_ok=True)


def write(name, samples, peak):
    scale = peak / max(abs(v) for v in samples)
    pcm = array("h", (round(v * scale * 32767) for v in samples))
    if sys.byteorder != "little":
        pcm.byteswap()
    with wave.open(str(OUT / name), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(pcm.tobytes())
    print(f"{name}: {len(samples) / RATE:.2f}s, peak {peak:.2f}")


# Four bars at 60 BPM. Quantized oscillator frequencies complete an integer
# number of cycles over the loop. Wrapped note tails preserve the seam.
duration = 16
count = RATE * duration
music = [0.0] * count
for i in range(count):
    t = i / RATE
    pulse = 0.85 + 0.15 * math.cos(TAU * t / 4)
    music[i] = pulse * sum(
        gain * math.sin(TAU * (round(freq * duration) / duration) * t)
        for freq, gain in [(65.406, 0.20), (130.813, 0.10), (155.563, 0.07), (195.998, 0.06)]
    )
notes = [261.626, 311.127, 391.995, 293.665, 261.626, 391.995, 349.228, 311.127]
for beat in range(16):
    freq = notes[beat % len(notes)]
    for j in range(int(1.8 * RATE)):
        t = j / RATE
        envelope = min(t / 0.025, 1) * math.exp(-3.5 * t) * min((1.8 - t) / 0.1, 1)
        tone = math.sin(TAU * freq * t) + 0.15 * math.sin(TAU * 2 * freq * t)
        music[(beat * RATE + j) % count] += 0.10 * envelope * tone
write("space_loop.wav", music, 0.48)

click = []
for i in range(int(0.12 * RATE)):
    t = i / RATE
    envelope = min(t / 0.004, 1) * (1 - t / 0.12) ** 2
    click.append(envelope * (math.sin(TAU * 880 * t) + 0.25 * math.sin(TAU * 1760 * t)))
write("menu_click.wav", click, 0.40)

rng = random.Random(5105)
collision = []
filtered_noise = 0.0
for i in range(int(0.42 * RATE)):
    t = i / RATE
    filtered_noise = 0.65 * filtered_noise + 0.35 * rng.uniform(-1, 1)
    envelope = min(t / 0.003, 1) * (1 - t / 0.42) ** 2
    # Descending oscillator plus a deterministic filtered-noise impact.
    tone = math.sin(TAU * (240 * t - 210 * t * t))
    collision.append(envelope * (0.55 * tone + 0.8 * filtered_noise))
write("collision.wav", collision, 0.65)
