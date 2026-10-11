# Big Button Launcher

A simple, full-screen home screen for Windows with a few very large, high-contrast buttons. It is designed for people who are partially sighted or who find computers confusing, and who only need to open a handful of websites and programs.

Each button opens a website, a program (such as Word or Zoom), or a shortcut. It can also include a **SHUT DOWN** button with a big YES/NO question first. When a program is closed, the person lands straight back on the launcher.

- Works on Windows 10 and Windows 11
- Nothing to install: it is a single PowerShell script plus a tiny starter file
- Large buttons, with colours and font fully adjustable
- Optional SHUT DOWN (or Restart) button with a large confirmation box
- Big **CLOSE** button, so a helper can get to the rest of the computer
- Can be set to open automatically when the computer starts

## What's in the download

| File | What it does |
|---|---|
| `Home.ps1` | The launcher itself. This is the file you edit to change buttons and colours. |
| `Start Home.vbs` | Starts the launcher quietly (without a black console window). Use this to run it. |

Keep both files together in the same folder. Any folder will do.

## Quick start

1. Download the two files and put them in a folder, for example `C:\ProgramData\Home` or `C:\Home`.
2. Double-click **`Start Home.vbs`** to try it.
3. To make it open automatically when the user logs in:
   1. Press **Win + R**, type `shell:startup` and press Enter.
   2. Right-click inside the folder that opens and choose **New > Shortcut**.
   3. Browse to `Start Home.vbs` and finish the wizard.

If Windows shows a warning because the files were downloaded from the internet, right-click each file, choose **Properties**, tick **Unblock** and click OK.

## Changing the buttons

Open `Home.ps1` in Notepad. Near the top is a list like this:

```powershell
$Items = @(
    @{ Label = "EMAIL"; Target = "https://mail.google.com" },
    @{ Label = "NEWS";  Target = "https://www.bbc.co.uk/news" },
    #@{ Label = "WORD"; Target = "winword.exe" },
    #@{ Label = "ZOOM"; Target = "$env:APPDATA\Zoom\bin\Zoom.exe" }
    @{ Label = "SHUT DOWN"; Target = "shutdown.exe"; Args = "/s /t 0"; Confirm = "Turn the computer off?" }
)
```

Each line is one button. `Label` is the text shown on the button, and `Target` can be:

- a **web address**, such as `https://mail.google.com`
- a **program name**, such as `winword.exe` (Word)
- the **full path** to a program, such as `C:\Program Files\Something\app.exe`
- a **shortcut file** (`.lnk`)

Rules to keep the list working:

- Put a **comma at the end of every line except the last one** that is switched on.
- A line starting with `#` is switched off. Remove the `#` to turn it back on, and keep the commas correct.
- Keep labels short, since long text will not fit on large buttons.

Up to four buttons are shown in a 2x2 grid. Five or more use three columns with a smaller font.

**Finding a program's path:** right-click the program in the Start menu, choose **Open file location**, then right-click the shortcut there, choose **Properties** and copy the **Target**. You can also use the shortcut file from that folder directly as the `Target`.

The Zoom path above is an example. Zoom's location can vary between installations, so adjust it if the Zoom button shows an error.

### Optional extras for a button

| Field | What it does |
|---|---|
| `Args` | Extra options passed to the program. |
| `Confirm` | A question shown in a big YES/NO box before anything happens. Choosing NO, or pressing Escape, cancels. |

### Shut down and restart buttons

```powershell
@{ Label = "SHUT DOWN"; Target = "shutdown.exe"; Args = "/s /t 0"; Confirm = "Turn the computer off?" }
@{ Label = "RESTART";   Target = "shutdown.exe"; Args = "/r /t 0"; Confirm = "Restart the computer?" }
```

Windows still checks for unsaved work in open programs, so a document is not thrown away without being asked about first.

## Changing the look

The settings at the top of `Home.ps1` control the appearance:

| Setting | What it changes |
|---|---|
| `$BackgroundColourText` | The screen behind the buttons |
| `$ButtonColourText` | The buttons themselves |
| `$FontColourText` | The writing on the buttons |
| `$CloseButtonColourText` | The CLOSE button (also the YES button in confirmation boxes) |
| `$CloseFontColourText` | The writing on the CLOSE button |
| `$HoverColourText` | The colour of a button while the mouse is over it (pick one that stands out from the button colour) |
| `$PressedColourText` | The colour of a button at the moment it is clicked |
| `$CloseHoverColourText` | The colour of the CLOSE button (and the YES button) while the mouse is over it |
| `$FontName` | The font, for example `Segoe UI`, `Arial` or `Verdana` |
| `$FontScale` | Text size: `1.0` is the default, `1.3` is 30% bigger |
| `$CoverTaskbar` | `$true` fills the whole screen; `$false` leaves the taskbar and Start button visible |

Colours can be a name (`Black`, `White`, `Navy`) or a hex code (`#FFD600`). If a colour is mistyped, a safe default is used.

Some combinations that work well for low vision:

| Background | Button | Font |
|---|---|---|
| Black | `#FFD600` (yellow) | Black |
| Black | White | Black |
| `#001F5C` (dark blue) | `#FFD600` | `#001F5C` |
| White | Black | White |

Different people find different combinations easiest to read, so it is worth trying a few with the person who will use it.

After saving your changes, close the launcher and open it again to see them.

## Closing the launcher

- Click the big **CLOSE** button along the bottom of the screen.
- Helpers can also press **Ctrl + Shift + Q**.

Closing the launcher only closes the launcher. It does not shut down the computer. To bring it back, double-click `Start Home.vbs`, or log out and in again if it is set to start automatically.

## Screens and displays

- With **mirrored (duplicate) screens**, Windows treats both displays as one, so the launcher appears on both.
- The launcher measures the screen when it starts. If a monitor is plugged in or the resolution changes afterwards, close the launcher and start it again.
- With **extended** screens, the launcher appears on the main display only.

## Troubleshooting

**Nothing appears when I start it after editing the list.**
Check the commas. Every active line in the list needs a comma at the end except the last one, and every `@{` needs a matching `}`.

**A button shows "Sorry, ... could not be opened."**
The `Target` is wrong. Check the spelling, or use the full path or a shortcut file instead.

**Nothing happens when I double-click `Home.ps1`.**
That is normal. Windows opens `.ps1` files in Notepad by default. Run `Start Home.vbs` instead.

**Windows or antivirus warns about the files.**
Downloaded scripts are often flagged as a precaution. Both files are plain text, so you can open and read them before running them. See the Unblock step in Quick start.

**A website or program opens behind the launcher.**
Please open an issue and say which program or browser you are using.

## How it works

`Start Home.vbs` starts PowerShell with a hidden window and tells it to run `Home.ps1`, bypassing the default script restriction for that one script only. No computer-wide settings are changed. `Home.ps1` draws a borderless form using Windows Forms and opens each target with PowerShell's `Start-Process` command.

## Licence

Released under the [MIT Licence](LICENSE). You are free to use, copy, modify and share it, and it comes with no warranty.
