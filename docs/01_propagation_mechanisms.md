# 1. Propagation Mechanisms

## 1.1 Frequency bands and propagation modes

Radio waves travel from transmitter to receiver via three fundamentally
different physical paths, depending on frequency:

| Mechanism   | Path                                            | Valid frequency range | Typical range |
|-------------|--------------------------------------------------|------------------------|----------------|
| Ground wave | Follows the Earth's curvature                    | < 2 MHz (LF-MF)        | Hundreds of km |
| Sky wave    | Bounces between Earth and the ionosphere          | ~10 MHz (HF)           | Thousands of km|
| Space wave  | Line-of-sight, direct + ground-reflected paths    | > 30 MHz (VHF and up)  | Line of sight  |

Since essentially all modern mobile services (cellular, Wi-Fi, etc.)
operate in the **30 MHz - 30 GHz** range, **space-wave propagation is the
only mechanism this project models.**

## 1.2 The three physical phenomena behind space-wave propagation

| Phenomenon  | Cause                                                        |
|-------------|---------------------------------------------------------------|
| Reflection  | Signal hits an object much larger than the wavelength          |
| Diffraction | Signal is obstructed by an object with sharp edges/irregularities |
| Scattering  | Signal passes through a medium with many small objects (foliage, street signs, rough surfaces) |

The received signal is therefore the superposition of a (possibly
absent) direct/line-of-sight ray plus a number of reflected, diffracted,
and scattered replicas -- this superposition is exactly what produces
**multipath fading**, modeled in [03_small_scale_fading.md](03_small_scale_fading.md).

## 1.3 Where this fits in the project

This document is purely conceptual -- there is no dedicated code module
for "reflection/diffraction/scattering" individually, since in practice
their combined effect is what the rest of the pipeline (path-loss +
shadowing + multipath fading) actually characterizes and simulates. Every
other `docs/*.md` file in this project builds on the space-wave
assumption introduced here.
