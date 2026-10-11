# Big-button home screen. Works on Windows 10 and 11, no installation needed.
# EDIT THE LIST BELOW to change the buttons. Target can be a web address,
# a program name (e.g. winword.exe), a full path to an .exe, or a shortcut (.lnk).

$Items = @(
    @{ Label = "email"; Target = "https://mail.google.com" },
    @{ Label = "precriptions";  Target = "https://systmonline.tpp-uk.com/" },
    @{ Label = "ocado";  Target = "https://sso.ocado.com/ocado/login" },
    #@{ Label = "word";  Target = "winword.exe" },
    #@{ Label = "zoom";  Target = "$env:APPDATA\Zoom\bin\Zoom.exe" }
    # To add a SHUT DOWN button: put a comma at the end of the last uncommented line above,
    # then remove the # from the line below.
    @{ Label = "SHUT DOWN"; Target = "shutdown.exe"; Args = "/s /t 0"; Confirm = "Turn the computer off?" }
)

# ---- LOOK AND FEEL: change these three colours and the font ----
# Colours can be a name (Black, White, Yellow, Navy, DarkBlue, Orange...)
# or a hex code such as #FFD600 (yellow) or #FFFFFF (white).
$BackgroundColourText = "Black"     # the screen behind the buttons
$ButtonColourText     = "#FFD600"   # the buttons themselves (foreground)
$FontColourText       = "Black"     # the writing on the buttons
$CloseButtonColourText = "#B00020"  # the big CLOSE button at the bottom (dark red)
$CloseFontColourText   = "White"    # writing on the CLOSE button
$FontName             = "Segoe UI"  # e.g. Arial, Verdana, Tahoma
$FontScale            = 1.0         # 1.0 = default size, 1.2 = 20% bigger, 0.8 = smaller
$CoverTaskbar         = $true       # $true = fills the whole screen
                                    # $false = leaves the taskbar and Start button visible
# ----------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-Colour($text, $fallback) {
    try { return [System.Drawing.ColorTranslator]::FromHtml($text) }
    catch { return [System.Drawing.Color]::FromName($fallback) }
}
$BackgroundColor = Get-Colour $BackgroundColourText "Black"
$ButtonColor     = Get-Colour $ButtonColourText "Yellow"
$TextColor       = Get-Colour $FontColourText "Black"
$CloseColor      = Get-Colour $CloseButtonColourText "Red"
$CloseTextColor  = Get-Colour $CloseFontColourText "White"

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$cols = if ($Items.Count -le 4) { 2 } else { 3 }
$rows = [math]::Ceiling($Items.Count / $cols)
$fontSize = [math]::Max(16, [int](($screen.Height / ($rows * 8)) * $FontScale))

$form = New-Object System.Windows.Forms.Form
$form.Text = "Home"
$form.FormBorderStyle = 'None'
if ($CoverTaskbar) {
    $form.WindowState = 'Maximized'
} else {
    $form.StartPosition = 'Manual'
    $form.Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
}
$form.BackColor = $BackgroundColor
$form.KeyPreview = $true

$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = 'Fill'
$table.Padding = New-Object System.Windows.Forms.Padding(20)
$table.ColumnCount = $cols
$table.RowCount = $rows
for ($c = 0; $c -lt $cols; $c++) {
    [void]$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', (100 / $cols))))
}
for ($r = 0; $r -lt $rows; $r++) {
    [void]$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', (100 / $rows))))
}

# Big YES / NO question box (used for buttons that have a Confirm message)
function Confirm-Big($message) {
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.FormBorderStyle = 'None'
    $dlg.StartPosition = 'CenterParent'
    $dlg.ShowInTaskbar = $false
    $dlg.Size = New-Object System.Drawing.Size([int]($screen.Width * 0.7), [int]($screen.Height * 0.6))
    $dlg.BackColor = $ButtonColor

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.Dock = 'Top'
    $label.Height = [int]($dlg.Height * 0.4)
    $label.TextAlign = 'MiddleCenter'
    $label.ForeColor = $TextColor
    $label.Font = New-Object System.Drawing.Font($FontName, [math]::Max(16, [int]($fontSize * 0.7)), [System.Drawing.FontStyle]::Bold)

    $tbl = New-Object System.Windows.Forms.TableLayoutPanel
    $tbl.Dock = 'Fill'
    $tbl.Padding = New-Object System.Windows.Forms.Padding(20)
    $tbl.ColumnCount = 2
    $tbl.RowCount = 1
    [void]$tbl.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)))
    [void]$tbl.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)))

    $yes = New-Object System.Windows.Forms.Button
    $yes.Text = "YES"
    $yes.DialogResult = 'Yes'
    $yes.BackColor = $CloseColor
    $yes.ForeColor = $CloseTextColor

    $no = New-Object System.Windows.Forms.Button
    $no.Text = "NO"
    $no.DialogResult = 'No'
    $no.BackColor = $BackgroundColor
    $no.ForeColor = $ButtonColor

    foreach ($b in @($yes, $no)) {
        $b.Dock = 'Fill'
        $b.Margin = New-Object System.Windows.Forms.Padding(15)
        $b.Font = New-Object System.Drawing.Font($FontName, [math]::Max(16, [int]($fontSize * 0.7)), [System.Drawing.FontStyle]::Bold)
        $b.FlatStyle = 'Flat'
        $b.FlatAppearance.BorderSize = 0
        [void]$tbl.Controls.Add($b)
    }

    $dlg.CancelButton = $no
    $dlg.Controls.Add($tbl)
    $dlg.Controls.Add($label)
    $tbl.BringToFront()

    $result = $dlg.ShowDialog($form)
    $dlg.Dispose()
    return ($result -eq 'Yes')
}

function Open-Item($item) {
    if ($item.Confirm -and -not (Confirm-Big $item.Confirm)) { return }
    try {
        # The launcher stays where it is and the new program opens in front of it.
        # When she closes that program, Windows drops straight back to the launcher.
        if ($item.Args) {
            Start-Process -FilePath $item.Target -ArgumentList $item.Args -WindowStyle Hidden -ErrorAction Stop
        } else {
            Start-Process -FilePath $item.Target -ErrorAction Stop
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Sorry, " + $item.Label + " could not be opened.",
            "Home") | Out-Null
    }
}

foreach ($item in $Items) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $item.Label
    $btn.Tag = $item
    $btn.Dock = 'Fill'
    $btn.Margin = New-Object System.Windows.Forms.Padding(15)
    $btn.Font = New-Object System.Drawing.Font($FontName, $fontSize, [System.Drawing.FontStyle]::Bold)
    $btn.BackColor = $ButtonColor
    $btn.ForeColor = $TextColor
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderSize = 0
    $btn.Add_Click({ param($s, $e) Open-Item $s.Tag })
    $table.Controls.Add($btn)
}

$form.Controls.Add($table)

# Big CLOSE button along the bottom
$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "CLOSE"
$closeBtn.Dock = 'Bottom'
$closeBtn.Height = [int]($screen.Height * 0.12)
$closeBtn.Font = New-Object System.Drawing.Font($FontName, [math]::Max(16, [int]($fontSize * 0.6)), [System.Drawing.FontStyle]::Bold)
$closeBtn.BackColor = $CloseColor
$closeBtn.ForeColor = $CloseTextColor
$closeBtn.FlatStyle = 'Flat'
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.Add_Click({ $form.Close() })
$form.Controls.Add($closeBtn)
$table.BringToFront()   # lets the buttons fill the space above CLOSE

# Hidden way for a helper to close it: Ctrl + Shift + Q
$form.Add_KeyDown({
    param($s, $e)
    if ($e.Control -and $e.Shift -and $e.KeyCode -eq 'Q') { $form.Close() }
})

[void]$form.ShowDialog()
