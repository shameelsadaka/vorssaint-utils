# Away Mode

An opt-in utility for leaving a Mac running without leaving its keyboard,
trackpad or mouse available for accidental input. Every connected display gets
a native behind-window blur with a 50% black tint by default. Display brightness is never changed, so the feature
also works with monitors that do not expose hardware brightness controls.

## Experience

Enable **Away Mode** in Features, then open **Settings → Quick Tools → Away
Mode**. Start it from the separate **Start Away Mode** box in the menu bar dropdown’s
**Keep Awake** section, Dynamic Island
action tile, Settings, or Command Bar. The shared shortcut recorder supports a
custom global shortcut; its suggested combination is Control–Option–Command–A
and registration is off until enabled. Menu and Island visibility use their
existing customization preferences.

Every connected display shows the approved twelve-frame white planet
animation centered over the dimmed, blurred desktop. The planet is registered to the same center in every
frame while the rings rotate and wobble. Its viewport is fixed at 201 × 138.19 macOS points on every display,
matching the reviewed prototype on the 1512-point MacBook display, and advances every 240 ms (2.88 seconds per loop).
Reduce Motion holds the first frame. Reduce Transparency uses an opaque black
backdrop. Animation phases stay synchronized across displays; black sprite
backgrounds become transparent so the logo has no rectangular backing.
The old Island shell is absent. Compact agent cards below the logo reuse the
Island’s card surface, provider marks, status pulse, and elapsed-time formatter.
They follow its enabled integrations (Claude, Codex, OpenCode and Copilot),
with one card per working provider. Only real completion events show a finished
card and its recorded duration; disappearing or stale activity is not treated
as success. Completions observed during this Away session remain until a new
turn replaces them or Away Mode ends. Historical usage alone creates no cards.
The AI activity toggle hides these cards without changing tracking preferences. A subtle 12-point unlock
hint sits 24 points above the bottom edge on every display: “Ready to return?
Press [enter] or [esc].” Both keys appear as rounded keycaps that scale around
their fixed center when pressed. Reduce Motion uses a color change without
movement. The hint hides during authentication or when the overlay is disabled.
The menu bar, Island launch action and shortcut remain available before activation.

Press **Enter/Return or Escape once**, then release the key. Numeric-keypad Enter
also works. macOS asks for **Touch ID or the Mac password**. Successful
authentication restores control; cancellation reinstates the guard. A held key
from before activation does not trigger authentication through autorepeat.

All Away Mode preferences, including visibility and shortcuts, are included in settings backup:

- Screen overlay: enabled by default. Turning it off hides the backdrop and logo
  on all displays while input remains guarded; the same unlock gesture applies.
- Overlay opacity: 50% by default, adjustable from 0% to 100%.
- Blur intensity: 100% by default, adjustable from 0% (off) to 100%. This blends
  the native blur material; macOS controls its radius. Reduce Transparency uses
  a solid black backdrop when the overlay is enabled.
- Keep Mac and displays awake: enabled by default for the duration of this mode.
  The temporary power assertion is released on exit; existing Keep Awake
  preferences are not modified. This does not override deliberate sleep or
  closed-lid sleep.

## Integration

Away Mode has its own feature-catalog entry, permission description, settings
anchor, search entry and Command Bar action. It is not installed by default.
All fifteen existing app languages have feature strings.

The implementation extends the existing Cleaning Mode lifecycle with a separate
Away state, sharing its Accessibility gate and suspension of conflicting input
utilities. Cleaning Mode keeps its existing five-Escape exit and clickable
Unlock button. Away Mode also suppresses mouse movement, clicks, dragging,
scrolling, modifier events, media keys and gestures delivered to its event tap.
Its single Enter/Escape gesture requests authentication, not direct deactivation.

Backdrop panels cover each display and are rebuilt after display changes. A
watchdog ends the mode if Accessibility, feature availability or the input tap
is lost. Session changes, sleep and application teardown release owned resources
and restore control. Pending authentication callbacks are ignored after teardown.

## Boundaries

This is an input guard, **not a macOS security lock**. Applications continue
running. During macOS authentication the event tap is suspended so the system
password UI can receive input, and the overlay windows are lowered beneath it.
System UI and privileged software can appear above app windows. OS-reserved
power controls, Force Quit, process termination and remote control are outside
this guard. Do not use it to secure an unattended Mac from another person.

Black pixels do not turn off an LCD's backlight. This solves visual blackout
without depending on DDC or brightness APIs; it does not promise the power
savings of switching displays off.

The animation uses the approved OpenAI-generated sprite sheet derived from the
Vorssaint logo. `Tools/prepare-away-logo.swift` reproduces the prototype frame
registration and packages twelve native PNG frames from `Resources/Brand/AwayLogo-sheet.jpg`.
This artwork follows the upstream brand restrictions. This is a source contribution in an
unofficial fork, not an official Vorssaint release. Redistributed application
builds must follow the upstream branding policy in `TRADEMARKS.md`.

## Verification

Automated coverage includes Escape, Return and keypad Enter, repeat rejection,
reset and unmatched releases, release-before-authentication, disabled or
stale agent filtering, stable ordering, feature registration, localization and
settings-backup inclusion. Run:

```sh
./build.sh --test-suite=away-mode --test-suite=features --test-suite=settings --test-suite=pointer-input --test-suite=agents --test-suite=notch --test-suite=keyboard --test-suite=command-bar
./build.sh
./build/Vorssaint --selftest
```

Local verification (2026-10-12, macOS 26.6.1): release build and app selftest
passed. The eight suites above ran 95,959 checks: 95,958 passed, including all
36 Away Mode checks. The sole failure was the existing
`NotchCompactTests.swift:285` history-rail realization assertion. An unchanged
checkout of upstream commit `fe24c17` passed that suite once and failed the same
assertion on a second run. That intermittent baseline failure is left unchanged.

Appearance settings verification (2026-10-12): Developer build and selftest passed;
targeted Away Mode and settings suites passed all 548 checks. Hidden native view
renders verified 0%, 50% and 100% tint opacity, the white logo, and clearing both
logo and backdrop when the overlay is disabled. Live blur appearance and input
interactions remain manual checks.

Agent-card verification (2026-10-12): the Away Mode, agent and settings suites
passed all 1,326 checks, including concurrent providers, completion delivery
independent of alerts, stale snapshots, new turns and disabled integrations.
A hidden native render of production Island card components with fixture data
was visually checked for active Claude and completed Codex cards. Live agent
work and authentication are still user-driven checks.

A real interaction test is still required before calling this release-ready:

- Grant Accessibility, start from the menu bar, Dynamic Island, configured shortcut, Settings and Command Bar, and verify keyboard,
  mouse, drag, scrolling, media keys and trackpad gestures cannot reach other apps.
- Check single Enter and Escape presses followed by Touch ID success, password fallback, an
  incorrect password and cancellation. Verify five-Escape Cleaning Mode still
  works and its Unlock button remains clickable.
- Check multiple monitors, negative display coordinates, full-screen Spaces,
  disconnect/reconnect, screen resolution changes and the menu bar/notch region.
- Confirm the twelve frames loop at the approved size, the planet stays centered,
  all connected displays show the logo, and Reduce Motion holds a static frame.
- Verify permission loss, disabled taps, sleep/wake, session switching and app
  termination restore control, cursor visibility and the prior power state.

No automated test activates the real input guard or authenticates on the user's
behalf. Build/selftest results do not establish those hardware interactions.
