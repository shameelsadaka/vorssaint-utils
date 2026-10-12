# Away Mode

An opt-in utility for leaving a Mac running without leaving its keyboard,
trackpad or mouse available for accidental input. Every connected display gets
an opaque black overlay. Display brightness is never changed, so the feature
also works with monitors that do not expose hardware brightness controls.

## Experience

Enable **Away Mode** in Features, then open **Settings → Quick Tools → Away
Mode**. Start it from the existing menu bar utility button, Dynamic Island
action tile, Settings, or Command Bar. The shared shortcut recorder supports a
custom global shortcut; its suggested combination is Control–Option–Command–A
and registration is off until enabled. Menu and Island visibility use their
existing customization preferences.

The selected Dynamic Island display shows one small Island surface with activity cards for the AI agents
already enabled in Dynamic Island. It uses the existing local session reader;
it does not introduce a cloud service, account, independent reader or background
poller for agent logs. Up to three live sessions appear, ordered consistently.
Agent names, working/finished status and elapsed time are shown. Project paths, prompts,
transcripts and model responses are not displayed. Stale sessions disappear.
A completion event appears briefly before the display returns to its idle state.

When there is no agent activity, a small original orbit illustration animates
at no more than five frames per second. Reduce Motion disables animation. The orbit occupies the same Island surface;
secondary screens remain entirely black. No overlay headings, idle captions,
unlock hints or progress dots are shown. No character, personality, chat or Bonk media is included.

Press **Escape three times**, with less than two seconds between presses, then
release the key. macOS asks for **Touch ID or the Mac password**. Successful
authentication restores control; cancellation reinstates the guard. Holding
Escape does not count as multiple presses. Another key resets an incomplete
sequence.

All Away Mode preferences, including visibility and shortcuts, are included in settings backup:

- Show AI-agent activity: enabled by default; turn it off for the orbit alone.
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
Its three-Escape gesture requests authentication, not direct deactivation.

Opaque panels cover each display and are rebuilt after display changes. A
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

The orbit is original code-drawn artwork. This is a source contribution in an
unofficial fork, not an official Vorssaint release. Redistributed application
builds must follow the upstream branding policy in `TRADEMARKS.md`.

## Verification

Automated coverage includes deliberate Escape sequences, repeat rejection,
interrupted and expired gestures, release-before-authentication, disabled or
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

A real interaction test is still required before calling this release-ready:

- Grant Accessibility, start from the menu bar, Dynamic Island, configured shortcut, Settings and Command Bar, and verify keyboard,
  mouse, drag, scrolling, media keys and trackpad gestures cannot reach other apps.
- Check three Escapes followed by Touch ID success, password fallback, an
  incorrect password and cancellation. Verify five-Escape Cleaning Mode still
  works and its Unlock button remains clickable.
- Check multiple monitors, negative display coordinates, full-screen Spaces,
  disconnect/reconnect, screen resolution changes and the menu bar/notch region.
- Confirm running agents update, completion returns to idle, disabled agents do
  not appear, Reduce Motion is respected and no project or prompt text leaks.
- Verify permission loss, disabled taps, sleep/wake, session switching and app
  termination restore control, cursor visibility and the prior power state.

No automated test activates the real input guard or authenticates on the user's
behalf. Build/selftest results do not establish those hardware interactions.
