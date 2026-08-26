# CPS TUI

A declarative terminal UI framework built directly on the CPS event loop.
Applications rebuild a widget tree from state, the renderer computes a
flexbox-style layout, and only changed cells are written back to the terminal.

The model is deliberately closer to a VDOM than to a collection of mutable
terminal controls: state lives in the application, widgets describe the current
frame, and events flow back through explicit handlers.

## Features

- Vertical and horizontal flex layouts
- Fixed, percentage, automatic, and weighted sizing
- 4-bit, 8-bit, and 24-bit color
- Cell-buffer diff rendering and synchronized terminal updates
- Keyboard, mouse, resize, paste, focus, and scroll events
- Text input with selection, history, kill ring, masking, and clipboard support
- Declarative event handlers and hit testing
- Reactive signals, computed values, and component-local state
- Higher-level split views, dialogs, trees, notifications, and command palettes
- Focus trapping for modal UI

## Requirements

- Nim 2.0 or newer
- [cps-runtime](https://github.com/gabearro/cps-runtime)
- A terminal with ANSI escape-sequence support

## Install

```sh
nimble install https://github.com/gabearro/cps-tui@#v1.0.1
```

## Counter application

```nim
import cps
import cps/tui

proc main(): CpsVoidFuture {.cps.} =
  var count = 0
  let app = newTuiApp()

  app.altScreen = true
  app.mouseMode = true

  app.onRender = proc(width, height: int): Widget =
    vbox(
      text("Count: " & $count, style().bold()),
      hbox(
        text("[+] Increment").withOnClick(proc(mx, my: int) = count += 1),
        text("[-] Decrement").withOnClick(proc(mx, my: int) = count -= 1)
      ),
      text("Press q to quit")
    )

  app.onInput = proc(event: InputEvent): bool =
    event.kind == iekKey and event.key == kcChar and event.ch == 'q'

  await app.run()

runCps(main())
```

## Widgets

| Widget | Use |
| --- | --- |
| `text` | Styled text |
| `container` | Vertical or horizontal flex layout |
| `border` | Border around a child |
| `inputField` | Editable text |
| `list` | Selectable list |
| `table` | Tabular data |
| `scrollView` | Scrollable viewport |
| `tabs` | Tab selector |
| `progressBar` | Bounded progress |
| `spacer` | Flexible empty space |

Higher-level components include `SplitView`, `ScrollableTextView`,
`Dialog`, `TreeView`, `NotificationArea`, `CommandPalette`, and
`StatusBar`.

## Reactive state

```nim
import cps/tui

let context = newReactiveContext()
let count = newSignal(context, 0)
let doubled = newComputed(context, proc(): int = count.get() * 2)

count.set(5)
doubled.invalidate()
doAssert doubled.get() == 10
```

Signals mark their reactive context as dirty. Computed values are evaluated
lazily and cached until explicitly invalidated.

## Render pipeline

```text
widget tree -> layout -> cell buffer -> diff -> ANSI output
```

Custom widgets can expose child rectangles for normal event routing without
asking the renderer to draw those children twice.

## Module map

| Module | Responsibility |
| --- | --- |
| `style` / `cell` | Colors, attributes, cell buffers, diffing |
| `layout` | Flexbox-inspired sizing and alignment |
| `widget` / `dsl` | Widget descriptions and builders |
| `renderer` | Layout traversal and drawing |
| `events` / `input` | Input parsing, focus, hit maps, routing |
| `textinput` | Editing model |
| `reactive` / `component` | State and component lifecycle |
| `components` | Reusable higher-level widgets |
| `app` | Terminal lifecycle and CPS main loop |

The full IRC client in
[cps-irc-app](https://github.com/gabearro/cps-irc-app) is the largest example
of the framework.

## Development

```sh
nimble install -d -y
nimble test
nimble testMms
```

The library supports ARC, ORC, and AtomicARC. `nimble testMms` runs the
same supported surface under all three memory managers.

Tests cover styles, layout, rendering, components, mouse routing, drag behavior,
focus management, and focus trapping.

## License

MIT
