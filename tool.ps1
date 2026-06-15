# =============================================================================
# CheesySSTool.ps1 — Single-file build
# Modern dark-themed screenshare review tool UI framework
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File "CheesySSTool.ps1"
# =============================================================================

#Requires -Version 5.1
Set-StrictMode -Off
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
try {
    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class DpiHelper {
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
"@
    [DpiHelper]::SetProcessDPIAware() | Out-Null
} catch {}

# =============================================================================
# CheesySSTool - Colors.ps1
# Centralized color palette for the entire application.
# All UI components reference these values for consistency.
# =============================================================================

$global:Colors = @{
    # Background layers (darkest to lightest)
    BgBase        = [System.Drawing.Color]::FromArgb(255, 13,  17,  23)   # #0D1117 - deepest bg
    BgSurface     = [System.Drawing.Color]::FromArgb(255, 22,  27,  34)   # #161B22 - card/panel bg
    BgElevated    = [System.Drawing.Color]::FromArgb(255, 30,  37,  48)   # #1E2530 - elevated panel
    BgHover       = [System.Drawing.Color]::FromArgb(255, 38,  47,  60)   # #262F3C - hover state
    BgSelected    = [System.Drawing.Color]::FromArgb(255, 31,  52,  84)   # #1F3454 - selected item

    # Borders
    BorderSubtle  = [System.Drawing.Color]::FromArgb(255, 33,  41,  54)   # #212936
    BorderDefault = [System.Drawing.Color]::FromArgb(255, 48,  61,  78)   # #303D4E
    BorderStrong  = [System.Drawing.Color]::FromArgb(255, 65,  82, 104)   # #415268

    # Text
    TextPrimary   = [System.Drawing.Color]::FromArgb(255, 230, 237, 243)  # #E6EDF3
    TextSecondary = [System.Drawing.Color]::FromArgb(255, 139, 148, 158)  # #8B949E
    TextMuted     = [System.Drawing.Color]::FromArgb(255, 88,  101, 116)  # #586574
    TextDisabled  = [System.Drawing.Color]::FromArgb(255, 55,  65,  78)   # #37414E

    # Accent / Brand
    AccentBlue    = [System.Drawing.Color]::FromArgb(255, 88,  166, 255)  # #58A6FF
    AccentGreen   = [System.Drawing.Color]::FromArgb(255, 63,  185, 80)   # #3FB950
    AccentOrange  = [System.Drawing.Color]::FromArgb(255, 255, 162, 59)   # #FFA23B
    AccentRed     = [System.Drawing.Color]::FromArgb(255, 248, 81,  73)   # #F85149
    AccentPurple  = [System.Drawing.Color]::FromArgb(255, 188, 140, 255)  # #BC8CFF
    AccentCyan    = [System.Drawing.Color]::FromArgb(255, 56,  189, 248)  # #38BDF8

    # Mode colors
    FastColor     = [System.Drawing.Color]::FromArgb(255, 63,  185, 80)   # green  - fast/lightweight
    NormalColor   = [System.Drawing.Color]::FromArgb(255, 88,  166, 255)  # blue   - balanced
    FullColor     = [System.Drawing.Color]::FromArgb(255, 188, 140, 255)  # purple - advanced

    # Status badge colors
    StatusReady   = [System.Drawing.Color]::FromArgb(255, 63,  185, 80)
    StatusIdle    = [System.Drawing.Color]::FromArgb(255, 139, 148, 158)
    StatusWarn    = [System.Drawing.Color]::FromArgb(255, 255, 162, 59)
    StatusError   = [System.Drawing.Color]::FromArgb(255, 248, 81,  73)

    # Titlebar / chrome
    TitleBar      = [System.Drawing.Color]::FromArgb(255, 13,  17,  23)
    TitleBarBtn   = [System.Drawing.Color]::FromArgb(255, 88,  101, 116)

    # Sidebar
    SidebarBg     = [System.Drawing.Color]::FromArgb(255, 16,  21,  29)
    SidebarActive = [System.Drawing.Color]::FromArgb(255, 31,  52,  84)
}
# =============================================================================
# CheesySSTool - Typography.ps1
# Font definitions used throughout the application.
# =============================================================================

$global:Fonts = @{
    # Base families
    Family        = "Segoe UI"
    FamilyMono    = "Consolas"
    FamilyFallback= "Arial"

    # Sizes
    TitleLarge    = [System.Drawing.Font]::new("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    TitleMedium   = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    TitleSmall    = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

    HeadingLarge  = [System.Drawing.Font]::new("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    HeadingMedium = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    HeadingSmall  = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    BodyLarge     = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    BodyMedium    = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Regular)
    BodySmall     = [System.Drawing.Font]::new("Segoe UI",  8, [System.Drawing.FontStyle]::Regular)

    Caption       = [System.Drawing.Font]::new("Segoe UI",  8, [System.Drawing.FontStyle]::Regular)
    Label         = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Bold)

    Mono          = [System.Drawing.Font]::new("Consolas",  9, [System.Drawing.FontStyle]::Regular)
    MonoSmall     = [System.Drawing.Font]::new("Consolas",  8, [System.Drawing.FontStyle]::Regular)

    NavItem       = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Regular)
    NavItemActive = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Bold)

    Badge         = [System.Drawing.Font]::new("Segoe UI",  7, [System.Drawing.FontStyle]::Bold)
    Tab           = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Regular)
    TabActive     = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Bold)

    ModeCard      = [System.Drawing.Font]::new("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    ModeCardSub   = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Regular)

    TitleBar      = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Regular)
    TitleBarBold  = [System.Drawing.Font]::new("Segoe UI",  9, [System.Drawing.FontStyle]::Bold)
}
# =============================================================================
# CheesySSTool - DarkTheme.ps1
# Loads colors and typography, and configures application-wide rendering hints.
# =============================================================================

. "$PSScriptRoot\Colors.ps1"
. "$PSScriptRoot\Typography.ps1"

# Apply WinForms rendering quality
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# Global spacing constants
$global:Spacing = @{
    XS  = 4
    SM  = 8
    MD  = 12
    LG  = 16
    XL  = 24
    XXL = 32
}

# Global radius constants (for painting rounded corners)
$global:Radius = @{
    SM  = 4
    MD  = 8
    LG  = 12
    XL  = 16
    Card= 10
    Btn = 6
    Badge=4
}

function global:Apply-DarkForm {
    <#
    .SYNOPSIS Applies dark theme defaults to a WinForms Form. #>
    param([System.Windows.Forms.Form]$Form)
    $Form.BackColor  = $global:Colors.BgBase
    $Form.ForeColor  = $global:Colors.TextPrimary
    $Form.Font       = $global:Fonts.BodyLarge
}

function global:Apply-DarkPanel {
    <#
    .SYNOPSIS Applies dark theme defaults to a Panel. #>
    param([System.Windows.Forms.Panel]$Panel, [string]$Level = "Surface")
    $Panel.BackColor = $global:Colors["Bg$Level"]
}
# =============================================================================
# CheesySSTool - Button.ps1
# Factory functions for creating styled buttons.
# =============================================================================

function global:New-AppButton {
    <#
    .SYNOPSIS
        Creates a styled application button.
    .PARAMETER Text
        Button label text.
    .PARAMETER Style
        "Primary" | "Secondary" | "Danger" | "Ghost"
    .PARAMETER Size
        "SM" | "MD" | "LG"
    #>
    param(
        [string]$Text      = "Button",
        [string]$Style     = "Primary",
        [string]$Size      = "MD",
        [scriptblock]$OnClick,
        [bool]$Enabled     = $true
    )

    $btn = [System.Windows.Forms.Button]::new()
    $btn.Text        = $Text
    $btn.FlatStyle   = [System.Windows.Forms.FlatStyle]::Flat
    $btn.Cursor      = [System.Windows.Forms.Cursors]::Hand
    $btn.Enabled     = $Enabled
    $btn.TextAlign   = [System.Drawing.ContentAlignment]::MiddleCenter

    switch ($Size) {
        "SM" { $btn.Height = 28; $btn.Font = $global:Fonts.BodySmall  ; $btn.Padding = [System.Windows.Forms.Padding]::new(8,0,8,0)  }
        "LG" { $btn.Height = 42; $btn.Font = $global:Fonts.HeadingSmall; $btn.Padding = [System.Windows.Forms.Padding]::new(20,0,20,0) }
        default { $btn.Height = 34; $btn.Font = $global:Fonts.BodyMedium; $btn.Padding = [System.Windows.Forms.Padding]::new(14,0,14,0) }
    }

    # Color sets: [normal bg, hover bg, text, border]
    $styles = @{
        Primary   = @($global:Colors.AccentBlue,   [System.Drawing.Color]::FromArgb(255,110,185,255), $global:Colors.BgBase,        $global:Colors.AccentBlue)
        Secondary = @($global:Colors.BgElevated,   $global:Colors.BgHover,                            $global:Colors.TextPrimary,   $global:Colors.BorderDefault)
        Danger    = @($global:Colors.AccentRed,    [System.Drawing.Color]::FromArgb(255,255,100,90),  [System.Drawing.Color]::White, $global:Colors.AccentRed)
        Ghost     = @([System.Drawing.Color]::Transparent, $global:Colors.BgHover,                    $global:Colors.TextSecondary, [System.Drawing.Color]::Transparent)
        Success   = @($global:Colors.AccentGreen,  [System.Drawing.Color]::FromArgb(255,90,210,105),  $global:Colors.BgBase,        $global:Colors.AccentGreen)
    }

    $set = $styles[$Style]
    $normalBg = $set[0]; $hoverBg = $set[1]; $fg = $set[2]; $border = $set[3]

    $btn.BackColor = $normalBg
    $btn.ForeColor = $fg
    $btn.FlatAppearance.BorderColor    = $border
    $btn.FlatAppearance.BorderSize     = 1
    $btn.FlatAppearance.MouseOverBackColor  = $hoverBg
    $btn.FlatAppearance.MouseDownBackColor  = $normalBg

    if ($OnClick) { $btn.Add_Click($OnClick) }

    return $btn
}

function global:New-IconButton {
    <#
    .SYNOPSIS Creates a small square icon-only button (for title bar, etc). #>
    param(
        [string]$Symbol    = "×",
        [string]$Tooltip   = "",
        [System.Drawing.Color]$HoverColor = [System.Drawing.Color]::FromArgb(255,200,50,40),
        [scriptblock]$OnClick
    )
    $btn = [System.Windows.Forms.Button]::new()
    $btn.Text      = $Symbol
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $btn.Size      = [System.Drawing.Size]::new(46, 32)
    $btn.Font      = $global:Fonts.BodyLarge
    $btn.BackColor = [System.Drawing.Color]::Transparent
    $btn.ForeColor = $global:Colors.TitleBarBtn
    $btn.FlatAppearance.BorderSize          = 0
    $btn.FlatAppearance.MouseOverBackColor  = $HoverColor
    $btn.FlatAppearance.MouseDownBackColor  = $HoverColor
    if ($Tooltip) {
        $tt = [System.Windows.Forms.ToolTip]::new()
        $tt.SetToolTip($btn, $Tooltip)
    }
    if ($OnClick) { $btn.Add_Click($OnClick) }
    return $btn
}
# =============================================================================
# CheesySSTool - StatusBadge.ps1
# Pill-shaped colored status indicator labels.
# =============================================================================

function global:New-StatusBadge {
    <#
    .SYNOPSIS Creates a colored status pill label.
    .PARAMETER Status "Ready"|"Idle"|"Waiting"|"Error"|"Running"
    .PARAMETER CustomText Override display text
    #>
    param(
        [string]$Status     = "Idle",
        [string]$CustomText = $null
    )

    $text   = if ($CustomText) { $CustomText } else { $Status }
    $color  = switch ($Status) {
        "Ready"   { $global:Colors.StatusReady  }
        "Running" { $global:Colors.AccentBlue   }
        "Waiting" { $global:Colors.AccentOrange  }
        "Error"   { $global:Colors.StatusError   }
        default   { $global:Colors.StatusIdle    }
    }

    # Use a Label with owner-draw look via paint event
    $lbl = [System.Windows.Forms.Label]::new()
    $lbl.Text      = "  $text  "
    $lbl.Font      = $global:Fonts.Badge
    $lbl.ForeColor = $color
    $lbl.BackColor = [System.Drawing.Color]::FromArgb(40, $color.R, $color.G, $color.B)
    $lbl.AutoSize  = $true
    $lbl.Padding   = [System.Windows.Forms.Padding]::new(6, 3, 6, 3)
    $lbl.BorderStyle = [System.Windows.Forms.BorderStyle]::None

    return $lbl
}
# =============================================================================
# CheesySSTool - Table.ps1
# Factory for creating styled DataGridView tables with placeholder rows.
# =============================================================================

function global:New-AppTable {
    <#
    .SYNOPSIS
        Creates a dark-themed DataGridView with defined columns and placeholder rows.
    .PARAMETER Columns
        Array of column header strings.
    .PARAMETER PlaceholderRows
        Number of empty placeholder rows to show. 0 = show "No data" label instead.
    .PARAMETER Dock
        DockStyle for the grid. Default Fill.
    #>
    param(
        [string[]]$Columns,
        [int]$PlaceholderRows   = 0,
        [System.Windows.Forms.DockStyle]$Dock = [System.Windows.Forms.DockStyle]::Fill
    )

    $dgv = [System.Windows.Forms.DataGridView]::new()
    $dgv.Dock                        = $Dock
    $dgv.AllowUserToAddRows          = $false
    $dgv.AllowUserToDeleteRows       = $false
    $dgv.ReadOnly                    = $true
    $dgv.SelectionMode               = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
    $dgv.MultiSelect                 = $false
    $dgv.RowHeadersVisible           = $false
    $dgv.AutoSizeColumnsMode         = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
    $dgv.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::DisableResizing
    $dgv.ColumnHeadersHeight         = 34
    $dgv.RowTemplate.Height          = 30
    $dgv.Font                        = $global:Fonts.BodyMedium
    $dgv.BorderStyle                 = [System.Windows.Forms.BorderStyle]::None
    $dgv.CellBorderStyle             = [System.Windows.Forms.DataGridViewCellBorderStyle]::SingleHorizontal
    $dgv.EnableHeadersVisualStyles   = $false
    $dgv.ScrollBars                  = [System.Windows.Forms.ScrollBars]::Vertical

    # Colors
    $dgv.BackgroundColor             = $global:Colors.BgSurface
    $dgv.GridColor                   = $global:Colors.BorderSubtle
    $dgv.DefaultCellStyle.BackColor  = $global:Colors.BgSurface
    $dgv.DefaultCellStyle.ForeColor  = $global:Colors.TextPrimary
    $dgv.DefaultCellStyle.SelectionBackColor = $global:Colors.BgSelected
    $dgv.DefaultCellStyle.SelectionForeColor = $global:Colors.TextPrimary
    $dgv.DefaultCellStyle.Padding    = [System.Windows.Forms.Padding]::new(6, 0, 6, 0)

    $dgv.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(255, 18, 23, 31)
    $dgv.AlternatingRowsDefaultCellStyle.ForeColor = $global:Colors.TextPrimary

    $dgv.ColumnHeadersDefaultCellStyle.BackColor   = $global:Colors.BgElevated
    $dgv.ColumnHeadersDefaultCellStyle.ForeColor   = $global:Colors.TextSecondary
    $dgv.ColumnHeadersDefaultCellStyle.Font        = $global:Fonts.Label
    $dgv.ColumnHeadersDefaultCellStyle.Padding     = [System.Windows.Forms.Padding]::new(6, 0, 6, 0)

    # Add columns
    foreach ($col in $Columns) {
        $c = [System.Windows.Forms.DataGridViewTextBoxColumn]::new()
        $c.HeaderText = $col
        $c.SortMode   = [System.Windows.Forms.DataGridViewColumnSortMode]::Programmatic
        $dgv.Columns.Add($c) | Out-Null
    }

    # Placeholder rows
    if ($PlaceholderRows -gt 0) {
        for ($i = 0; $i -lt $PlaceholderRows; $i++) {
            $row = @()
            foreach ($col in $Columns) {
                $row += "—"
            }
            $dgv.Rows.Add($row) | Out-Null
        }
    }

    return $dgv
}

function global:New-EmptyStatePanel {
    <#
    .SYNOPSIS
        Creates a centered "no data" placeholder panel.
    .PARAMETER Message
        Primary message text.
    .PARAMETER SubMessage
        Secondary hint text.
    #>
    param(
        [string]$Message    = "No data available",
        [string]$SubMessage = "Start an operation to see results here"
    )

    $panel = [System.Windows.Forms.Panel]::new()
    $panel.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $panel.BackColor = $global:Colors.BgSurface

    $lbl = [System.Windows.Forms.Label]::new()
    $lbl.Text      = $Message
    $lbl.Font      = $global:Fonts.HeadingMedium
    $lbl.ForeColor = $global:Colors.TextMuted
    $lbl.AutoSize  = $true
    $lbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

    $sub = [System.Windows.Forms.Label]::new()
    $sub.Text      = $SubMessage
    $sub.Font      = $global:Fonts.BodySmall
    $sub.ForeColor = $global:Colors.TextDisabled
    $sub.AutoSize  = $true
    $sub.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

    $panel.Controls.Add($lbl)
    $panel.Controls.Add($sub)

    $panel.Add_Resize({
        $lbl.Left = ($panel.Width  - $lbl.Width)  / 2
        $lbl.Top  = ($panel.Height - $lbl.Height - $sub.Height - 8) / 2
        $sub.Left = ($panel.Width  - $sub.Width)  / 2
        $sub.Top  = $lbl.Bottom + 8
    })

    return $panel
}
# =============================================================================
# CheesySSTool - SearchBar.ps1
# A styled search input with placeholder text and optional clear button.
# =============================================================================

function global:New-SearchBar {
    <#
    .SYNOPSIS Creates a styled dark search bar.
    .PARAMETER Placeholder Hint text shown when empty.
    .PARAMETER Width Fixed width. 0 = auto-fill parent.
    #>
    param(
        [string]$Placeholder = "Search...",
        [int]$Width          = 260
    )

    $container = [System.Windows.Forms.Panel]::new()
    $container.Height    = 34
    $container.BackColor = $global:Colors.BgElevated
    if ($Width -gt 0) { $container.Width = $Width }

    # Search icon label
    $icon = [System.Windows.Forms.Label]::new()
    $icon.Text      = "⌕"
    $icon.Font      = [System.Drawing.Font]::new("Segoe UI", 12)
    $icon.ForeColor = $global:Colors.TextMuted
    $icon.BackColor = [System.Drawing.Color]::Transparent
    $icon.Size      = [System.Drawing.Size]::new(30, 34)
    $icon.Location  = [System.Drawing.Point]::new(4, 0)
    $icon.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

    # Text input
    $tb = [System.Windows.Forms.TextBox]::new()
    $tb.Font        = $global:Fonts.BodyMedium
    $tb.BackColor   = $global:Colors.BgElevated
    $tb.ForeColor   = $global:Colors.TextMuted
    $tb.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $tb.Height      = 20
    $tb.Location    = [System.Drawing.Point]::new(34, 7)
    $tb.Text        = $Placeholder
    $tb.Tag         = $Placeholder

    # Placeholder behavior
    $tb.Add_Enter({
        if ($this.Text -eq $this.Tag) {
            $this.Text      = ""
            $this.ForeColor = $global:Colors.TextPrimary
        }
    })
    $tb.Add_Leave({
        if ($this.Text -eq "") {
            $this.Text      = $this.Tag
            $this.ForeColor = $global:Colors.TextMuted
        }
    })

    # Anchor width when container resizes
    if ($Width -eq 0) {
        $container.Add_Resize({
            $tb.Width = $container.Width - 38
        })
    } else {
        $tb.Width = $Width - 38
    }

    $container.Controls.Add($icon)
    $container.Controls.Add($tb)

    # Paint subtle border
    $container.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderDefault, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width - 1, $s.Height - 1)
        $pen.Dispose()
    })

    # Expose the TextBox as a public property via Tag
    $container | Add-Member -MemberType NoteProperty -Name "SearchBox" -Value $tb

    return $container
}
# =============================================================================
# CheesySSTool - Sidebar.ps1
# Vertical icon + label navigation sidebar component.
# =============================================================================

function global:New-Sidebar {
    <#
    .SYNOPSIS
        Creates a vertical sidebar with nav items.
    .PARAMETER Items
        Array of hashtables: @{Label="Overview"; Icon="◈"; Tag="overview"}
    .PARAMETER OnSelect
        Scriptblock called with the Tag of the selected item.
    .PARAMETER AccentColor
        Highlight color for active item indicator.
    #>
    param(
        [hashtable[]]$Items,
        [scriptblock]$OnSelect,
        [System.Drawing.Color]$AccentColor = $null
    )

    if (-not $AccentColor) { $AccentColor = $global:Colors.AccentBlue }

    $sidebar = [System.Windows.Forms.Panel]::new()
    $sidebar.Width     = 200
    $sidebar.Dock      = [System.Windows.Forms.DockStyle]::Left
    $sidebar.BackColor = $global:Colors.SidebarBg

    # Right border
    $sidebar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, $s.Width - 1, 0, $s.Width - 1, $s.Height)
        $pen.Dispose()
    })

    $buttonList   = [System.Collections.Generic.List[System.Windows.Forms.Panel]]::new()
    $yPos         = 8

    foreach ($item in $Items) {
        $itemPanel = [System.Windows.Forms.Panel]::new()
        $itemPanel.Size      = [System.Drawing.Size]::new($sidebar.Width, 40)
        $itemPanel.Location  = [System.Drawing.Point]::new(0, $yPos)
        $itemPanel.BackColor = [System.Drawing.Color]::Transparent
        $itemPanel.Cursor    = [System.Windows.Forms.Cursors]::Hand
        $itemPanel.Tag       = $item.Tag

        # Active indicator bar (left side)
        $indicator = [System.Windows.Forms.Panel]::new()
        $indicator.Size      = [System.Drawing.Size]::new(3, 26)
        $indicator.Location  = [System.Drawing.Point]::new(0, 7)
        $indicator.BackColor = [System.Drawing.Color]::Transparent
        $indicator.Tag       = "indicator"

        # Icon label
        $iconLbl = [System.Windows.Forms.Label]::new()
        $iconLbl.Text      = $item.Icon
        $iconLbl.Font      = [System.Drawing.Font]::new("Segoe UI", 11)
        $iconLbl.ForeColor = $global:Colors.TextMuted
        $iconLbl.BackColor = [System.Drawing.Color]::Transparent
        $iconLbl.Size      = [System.Drawing.Size]::new(28, 40)
        $iconLbl.Location  = [System.Drawing.Point]::new(16, 0)
        $iconLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

        # Text label
        $textLbl = [System.Windows.Forms.Label]::new()
        $textLbl.Text      = $item.Label
        $textLbl.Font      = $global:Fonts.NavItem
        $textLbl.ForeColor = $global:Colors.TextSecondary
        $textLbl.BackColor = [System.Drawing.Color]::Transparent
        $textLbl.Size      = [System.Drawing.Size]::new(140, 40)
        $textLbl.Location  = [System.Drawing.Point]::new(48, 0)
        $textLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $itemPanel.Controls.Add($indicator)
        $itemPanel.Controls.Add($iconLbl)
        $itemPanel.Controls.Add($textLbl)
        $sidebar.Controls.Add($itemPanel)
        $buttonList.Add($itemPanel)
        $yPos += 40

        # Hover / Click logic
        $hoverEnter = {
            param($s, $e)
            $panel = $s
            if ($panel -isnot [System.Windows.Forms.Panel]) { $panel = $s.Parent }
            if ($panel.BackColor -ne $global:Colors.SidebarActive) {
                $panel.BackColor = $global:Colors.BgHover
            }
        }
        $hoverLeave = {
            param($s, $e)
            $panel = $s
            if ($panel -isnot [System.Windows.Forms.Panel]) { $panel = $s.Parent }
            if ($panel.BackColor -ne $global:Colors.SidebarActive) {
                $panel.BackColor = [System.Drawing.Color]::Transparent
            }
        }

        # Capture loop variable
        $capturedItem = $item
        $capturedList = $buttonList
        $capturedColor = $AccentColor
        $capturedOnSelect = $OnSelect

        $clickHandler = {
            param($s, $e)
            $clicked = $s
            if ($clicked -isnot [System.Windows.Forms.Panel]) { $clicked = $s.Parent }

            # Deactivate all
            foreach ($btn in $capturedList) {
                $btn.BackColor = [System.Drawing.Color]::Transparent
                foreach ($c in $btn.Controls) {
                    if ($c.Tag -eq "indicator") { $c.BackColor = [System.Drawing.Color]::Transparent }
                    if ($c -is [System.Windows.Forms.Label]) {
                        $c.ForeColor = $global:Colors.TextSecondary
                        $c.Font      = $global:Fonts.NavItem
                    }
                }
            }

            # Activate clicked
            $clicked.BackColor = $global:Colors.SidebarActive
            foreach ($c in $clicked.Controls) {
                if ($c.Tag -eq "indicator") { $c.BackColor = $capturedColor }
                if ($c -is [System.Windows.Forms.Label]) {
                    $c.ForeColor = $global:Colors.TextPrimary
                    $c.Font      = $global:Fonts.NavItemActive
                }
            }

            if ($capturedOnSelect) { & $capturedOnSelect $clicked.Tag }
        }

        $itemPanel.Add_MouseEnter($hoverEnter)
        $itemPanel.Add_MouseLeave($hoverLeave)
        $itemPanel.Add_Click($clickHandler)
        foreach ($child in @($iconLbl, $textLbl, $indicator)) {
            $child.Add_MouseEnter($hoverEnter)
            $child.Add_MouseLeave($hoverLeave)
            $child.Add_Click($clickHandler)
        }
    }

    # Activate first item by default
    if ($buttonList.Count -gt 0) {
        $first = $buttonList[0]
        $first.BackColor = $global:Colors.SidebarActive
        foreach ($c in $first.Controls) {
            if ($c.Tag -eq "indicator") { $c.BackColor = $AccentColor }
            if ($c -is [System.Windows.Forms.Label]) {
                $c.ForeColor = $global:Colors.TextPrimary
                $c.Font      = $global:Fonts.NavItemActive
            }
        }
    }

    # Expose the button list so callers can programmatically select items
    $sidebar | Add-Member -MemberType NoteProperty -Name "NavItems" -Value $buttonList

    return $sidebar
}
# =============================================================================
# CheesySSTool - Notification.ps1
# Slide-in toast notification system.
# =============================================================================

$global:_ActiveToasts = [System.Collections.Generic.List[System.Windows.Forms.Form]]::new()

function global:Show-Toast {
    <#
    .SYNOPSIS Shows a toast notification in the bottom-right corner of the screen.
    .PARAMETER Message  Notification text.
    .PARAMETER Type     "Info"|"Success"|"Warning"|"Error"
    .PARAMETER Duration Milliseconds to display (default 3000).
    .PARAMETER Owner    Optional parent form to anchor to.
    #>
    param(
        [string]$Message   = "Notification",
        [string]$Type      = "Info",
        [int]$Duration     = 3000,
        [System.Windows.Forms.Form]$Owner = $null
    )

    $color = switch ($Type) {
        "Success" { $global:Colors.AccentGreen  }
        "Warning" { $global:Colors.AccentOrange }
        "Error"   { $global:Colors.AccentRed    }
        default   { $global:Colors.AccentBlue   }
    }
    $icon = switch ($Type) {
        "Success" { "✓" }
        "Warning" { "⚠" }
        "Error"   { "✕" }
        default   { "ℹ" }
    }

    $toast = [System.Windows.Forms.Form]::new()
    $toast.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $toast.ShowInTaskbar   = $false
    $toast.TopMost         = $true
    $toast.Size            = [System.Drawing.Size]::new(320, 56)
    $toast.BackColor       = $global:Colors.BgElevated
    $toast.Opacity         = 0.0

    # Position bottom-right
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $toastY = $screen.Bottom - 70 - ($global:_ActiveToasts.Count * 64)
    $toast.Location = [System.Drawing.Point]::new($screen.Right - 330, $toastY)

    # Left color strip
    $strip = [System.Windows.Forms.Panel]::new()
    $strip.Size      = [System.Drawing.Size]::new(4, 56)
    $strip.Location  = [System.Drawing.Point]::new(0, 0)
    $strip.BackColor = $color
    $toast.Controls.Add($strip)

    # Icon
    $iconLbl = [System.Windows.Forms.Label]::new()
    $iconLbl.Text      = $icon
    $iconLbl.Font      = [System.Drawing.Font]::new("Segoe UI", 13)
    $iconLbl.ForeColor = $color
    $iconLbl.BackColor = [System.Drawing.Color]::Transparent
    $iconLbl.Size      = [System.Drawing.Size]::new(32, 56)
    $iconLbl.Location  = [System.Drawing.Point]::new(12, 0)
    $iconLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $toast.Controls.Add($iconLbl)

    # Message
    $msgLbl = [System.Windows.Forms.Label]::new()
    $msgLbl.Text      = $Message
    $msgLbl.Font      = $global:Fonts.BodyMedium
    $msgLbl.ForeColor = $global:Colors.TextPrimary
    $msgLbl.BackColor = [System.Drawing.Color]::Transparent
    $msgLbl.Size      = [System.Drawing.Size]::new(258, 56)
    $msgLbl.Location  = [System.Drawing.Point]::new(48, 0)
    $msgLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $toast.Controls.Add($msgLbl)

    $global:_ActiveToasts.Add($toast)
    $toast.Show()

    # Fade in
    $fadeIn = [System.Windows.Forms.Timer]::new()
    $fadeIn.Interval = 20
    $fadeIn.Add_Tick({
        if ($toast.Opacity -lt 0.92) { $toast.Opacity += 0.08 }
        else { $fadeIn.Stop(); $fadeIn.Dispose() }
    })
    $fadeIn.Start()

    # Auto-dismiss
    $hold = [System.Windows.Forms.Timer]::new()
    $hold.Interval = $Duration
    $hold.Add_Tick({
        $hold.Stop(); $hold.Dispose()
        $fadeOut = [System.Windows.Forms.Timer]::new()
        $fadeOut.Interval = 25
        $fadeOut.Add_Tick({
            if ($toast.Opacity -gt 0.0) { $toast.Opacity -= 0.07 }
            else {
                $fadeOut.Stop(); $fadeOut.Dispose()
                $global:_ActiveToasts.Remove($toast)
                $toast.Close(); $toast.Dispose()
            }
        })
        $fadeOut.Start()
    })
    $hold.Start()
}
# =============================================================================
# CheesySSTool - Navigation.ps1
# Navigation state and page-switching helpers.
# =============================================================================

$global:NavState = @{
    CurrentMode = $null   # "fast" | "normal" | "full"
    CurrentPage = $null   # current tab/page tag
    History     = [System.Collections.Generic.Stack[string]]::new()
}

function global:Navigate-To {
    <#
    .SYNOPSIS Switches the visible page panel within a content host.
    .PARAMETER ContentHost The panel that contains page sub-panels.
    .PARAMETER PageTag     The Tag of the page panel to show.
    #>
    param(
        [System.Windows.Forms.Panel]$ContentHost,
        [string]$PageTag
    )

    foreach ($ctrl in $ContentHost.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) {
            $ctrl.Visible = ($ctrl.Tag -eq $PageTag)
        }
    }

    if ($global:NavState.CurrentPage -and $global:NavState.CurrentPage -ne $PageTag) {
        $global:NavState.History.Push($global:NavState.CurrentPage)
    }
    $global:NavState.CurrentPage = $PageTag
}

function global:Navigate-Back {
    <#
    .SYNOPSIS Goes back one step in navigation history. #>
    param([System.Windows.Forms.Panel]$ContentHost)
    if ($global:NavState.History.Count -gt 0) {
        $prev = $global:NavState.History.Pop()
        Navigate-To -ContentHost $ContentHost -PageTag $prev
    }
}

function global:New-ContentHost {
    <#
    .SYNOPSIS Creates a fill panel that hosts multiple page panels (one visible at a time). #>
    $host = [System.Windows.Forms.Panel]::new()
    $host.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $host.BackColor = $global:Colors.BgBase
    return $host
}

function global:Add-Page {
    <#
    .SYNOPSIS Adds a page panel to a content host.
    .PARAMETER Host    The content host panel.
    .PARAMETER Tag     Unique page identifier.
    .PARAMETER Builder Scriptblock that builds and returns the page panel.
    .PARAMETER Visible Whether this page is initially visible.
    #>
    param(
        [System.Windows.Forms.Panel]$Host,
        [string]$Tag,
        [scriptblock]$Builder,
        [bool]$Visible = $false
    )

    $page = & $Builder
    $page.Dock    = [System.Windows.Forms.DockStyle]::Fill
    $page.Tag     = $Tag
    $page.Visible = $Visible
    $Host.Controls.Add($page)
    return $page
}
# =============================================================================
# CheesySSTool - WindowManager.ps1
# Tracks open windows and provides show/close helpers.
# =============================================================================

$global:WindowRegistry = @{}

function global:Register-Window {
    param([string]$Name, [System.Windows.Forms.Form]$Form)
    $global:WindowRegistry[$Name] = $Form
}

function global:Get-Window {
    param([string]$Name)
    return $global:WindowRegistry[$Name]
}

function global:Close-Window {
    param([string]$Name)
    if ($global:WindowRegistry.ContainsKey($Name)) {
        $global:WindowRegistry[$Name].Close()
        $global:WindowRegistry.Remove($Name)
    }
}

function global:New-CustomTitleBar {
    <#
    .SYNOPSIS
        Creates a draggable custom title bar panel with minimize/maximize/close buttons.
    .PARAMETER ParentForm  The host form.
    .PARAMETER Title       Window title text.
    .PARAMETER Subtitle    Optional small subtitle.
    .PARAMETER AccentColor Left edge accent stripe color.
    #>
    param(
        [System.Windows.Forms.Form]$ParentForm,
        [string]$Title       = "CheesySSTool",
        [string]$Subtitle    = "",
        [System.Drawing.Color]$AccentColor = $null
    )
    if (-not $AccentColor) { $AccentColor = $global:Colors.AccentBlue }

    $bar = [System.Windows.Forms.Panel]::new()
    $bar.Dock      = [System.Windows.Forms.DockStyle]::Top
    $bar.Height    = 40
    $bar.BackColor = $global:Colors.TitleBar

    # Bottom border
    $bar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, $s.Height - 1, $s.Width, $s.Height - 1)
        $pen.Dispose()
    })

    # Accent stripe
    $stripe = [System.Windows.Forms.Panel]::new()
    $stripe.Size      = [System.Drawing.Size]::new(3, 40)
    $stripe.Location  = [System.Drawing.Point]::new(0, 0)
    $stripe.BackColor = $AccentColor
    $bar.Controls.Add($stripe)

    # App logo dot
    $dot = [System.Windows.Forms.Label]::new()
    $dot.Text      = "◆"
    $dot.Font      = [System.Drawing.Font]::new("Segoe UI", 9)
    $dot.ForeColor = $AccentColor
    $dot.BackColor = [System.Drawing.Color]::Transparent
    $dot.Size      = [System.Drawing.Size]::new(20, 40)
    $dot.Location  = [System.Drawing.Point]::new(10, 0)
    $dot.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $bar.Controls.Add($dot)

    # Title label
    $titleLbl = [System.Windows.Forms.Label]::new()
    $titleLbl.Text      = $Title
    $titleLbl.Font      = $global:Fonts.TitleBarBold
    $titleLbl.ForeColor = $global:Colors.TextPrimary
    $titleLbl.BackColor = [System.Drawing.Color]::Transparent
    $titleLbl.AutoSize  = $true
    $titleLbl.Location  = [System.Drawing.Point]::new(34, 12)
    $bar.Controls.Add($titleLbl)

    # Subtitle
    if ($Subtitle) {
        $subLbl = [System.Windows.Forms.Label]::new()
        $subLbl.Text      = $Subtitle
        $subLbl.Font      = $global:Fonts.TitleBar
        $subLbl.ForeColor = $global:Colors.TextMuted
        $subLbl.BackColor = [System.Drawing.Color]::Transparent
        $subLbl.AutoSize  = $true
        $subLbl.Location  = [System.Drawing.Point]::new(34, 24)
        $bar.Controls.Add($subLbl)
    }

    # --- Window control buttons (right side) ---
    $closeBtn = New-IconButton -Symbol "✕" -Tooltip "Close" `
        -HoverColor ([System.Drawing.Color]::FromArgb(255, 196, 43, 28)) `
        -OnClick { $ParentForm.Close() }

    $maxBtn = New-IconButton -Symbol "□" -Tooltip "Maximize" `
        -HoverColor $global:Colors.BgHover `
        -OnClick {
            if ($ParentForm.WindowState -eq [System.Windows.Forms.FormWindowState]::Maximized) {
                $ParentForm.WindowState = [System.Windows.Forms.FormWindowState]::Normal
            } else {
                $ParentForm.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
            }
        }

    $minBtn = New-IconButton -Symbol "─" -Tooltip "Minimize" `
        -HoverColor $global:Colors.BgHover `
        -OnClick { $ParentForm.WindowState = [System.Windows.Forms.FormWindowState]::Minimized }

    # Position buttons on the right
    $bar.Add_Resize({
        $closeBtn.Location = [System.Drawing.Point]::new($bar.Width - 46, 4)
        $maxBtn.Location   = [System.Drawing.Point]::new($bar.Width - 92, 4)
        $minBtn.Location   = [System.Drawing.Point]::new($bar.Width - 138, 4)
    })

    $closeBtn.Location = [System.Drawing.Point]::new(700, 4)
    $maxBtn.Location   = [System.Drawing.Point]::new(654, 4)
    $minBtn.Location   = [System.Drawing.Point]::new(608, 4)

    $bar.Controls.Add($minBtn)
    $bar.Controls.Add($maxBtn)
    $bar.Controls.Add($closeBtn)

    # Dragging support
    $isDragging = $false
    $dragOffset = [System.Drawing.Point]::new(0, 0)

    $mouseDown = {
        param($s, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $script:isDragging = $true
            $script:dragOffset = $e.Location
        }
    }
    $mouseMove = {
        param($s, $e)
        if ($script:isDragging) {
            $ParentForm.Location = [System.Drawing.Point]::new(
                $ParentForm.Left + $e.X - $script:dragOffset.X,
                $ParentForm.Top  + $e.Y - $script:dragOffset.Y
            )
        }
    }
    $mouseUp = { $script:isDragging = $false }

    foreach ($ctrl in @($bar, $dot, $titleLbl)) {
        $ctrl.Add_MouseDown($mouseDown)
        $ctrl.Add_MouseMove($mouseMove)
        $ctrl.Add_MouseUp($mouseUp)
    }

    return $bar
}

function global:New-BaseWindow {
    <#
    .SYNOPSIS Creates a base frameless dark window. #>
    param(
        [string]$Title       = "CheesySSTool",
        [string]$Subtitle    = "",
        [int]$Width          = 1100,
        [int]$Height         = 720,
        [System.Drawing.Color]$AccentColor = $null
    )
    if (-not $AccentColor) { $AccentColor = $global:Colors.AccentBlue }

    $form = [System.Windows.Forms.Form]::new()
    $form.Text            = $Title
    $form.Size            = [System.Drawing.Size]::new($Width, $Height)
    $form.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.BackColor       = $global:Colors.BgBase
    $form.ForeColor       = $global:Colors.TextPrimary
    $form.Font            = $global:Fonts.BodyMedium
    $form.MinimumSize     = [System.Drawing.Size]::new(900, 580)

    # Resize grip (bottom-right corner)
    $form.Padding = [System.Windows.Forms.Padding]::new(1)

    # Outer border paint
    $form.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderDefault, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width - 1, $s.Height - 1)
        $pen.Dispose()
    })

    $titleBar = New-CustomTitleBar -ParentForm $form -Title $Title -Subtitle $Subtitle -AccentColor $AccentColor
    $form.Controls.Add($titleBar)

    # Expose titlebar
    $form | Add-Member -MemberType NoteProperty -Name "TitleBar" -Value $titleBar

    return $form
}
# =============================================================================
# CheesySSTool - PageBuilders.ps1
# Shared page content builders used across Fast/Normal/Full SS windows.
# =============================================================================

# ── Section header helper ─────────────────────────────────────────────────────
function global:New-SectionHeader {
    param(
        [string]$Title,
        [string]$Subtitle = "",
        [string]$BadgeText = "",
        [string]$BadgeStatus = "Idle"
    )
    $p = [System.Windows.Forms.Panel]::new()
    $p.Dock      = [System.Windows.Forms.DockStyle]::Top
    $p.Height    = if ($Subtitle) { 70 } else { 52 }
    $p.BackColor = $global:Colors.BgBase
    $p.Padding   = [System.Windows.Forms.Padding]::new(24, 12, 24, 0)

    $t = [System.Windows.Forms.Label]::new()
    $t.Text      = $Title
    $t.Font      = $global:Fonts.HeadingLarge
    $t.ForeColor = $global:Colors.TextPrimary
    $t.BackColor = [System.Drawing.Color]::Transparent
    $t.AutoSize  = $true
    $t.Location  = [System.Drawing.Point]::new(24, 12)
    $p.Controls.Add($t)

    if ($BadgeText) {
        $badge = New-StatusBadge -Status $BadgeStatus -CustomText $BadgeText
        $badge.Location = [System.Drawing.Point]::new(200, 16)
        $p.Controls.Add($badge)
    }

    if ($Subtitle) {
        $s = [System.Windows.Forms.Label]::new()
        $s.Text      = $Subtitle
        $s.Font      = $global:Fonts.BodySmall
        $s.ForeColor = $global:Colors.TextMuted
        $s.BackColor = [System.Drawing.Color]::Transparent
        $s.AutoSize  = $true
        $s.Location  = [System.Drawing.Point]::new(24, 38)
        $p.Controls.Add($s)
    }
    return $p
}

# ── Divider ───────────────────────────────────────────────────────────────────
function global:New-Divider {
    $d = [System.Windows.Forms.Panel]::new()
    $d.Dock      = [System.Windows.Forms.DockStyle]::Top
    $d.Height    = 1
    $d.BackColor = $global:Colors.BorderSubtle
    return $d
}

# ── Stat card ─────────────────────────────────────────────────────────────────
function global:New-StatCard {
    param(
        [string]$Label = "Label",
        [string]$Value = "—",
        [string]$Icon  = "▪",
        [System.Drawing.Color]$Color = $null
    )
    if (-not $Color) { $Color = $global:Colors.AccentBlue }

    $card = [System.Windows.Forms.Panel]::new()
    $card.BackColor = $global:Colors.BgSurface
    $card.Size      = [System.Drawing.Size]::new(160, 80)

    $card.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width-1, $s.Height-1)
        $pen.Dispose()
        # Top accent
        $brush = [System.Drawing.SolidBrush]::new($Color)
        $e.Graphics.FillRectangle($brush, 0, 0, $s.Width, 3)
        $brush.Dispose()
    })

    $iconLbl = [System.Windows.Forms.Label]::new()
    $iconLbl.Text      = $Icon
    $iconLbl.Font      = [System.Drawing.Font]::new("Segoe UI", 10)
    $iconLbl.ForeColor = $Color
    $iconLbl.BackColor = [System.Drawing.Color]::Transparent
    $iconLbl.AutoSize  = $true
    $iconLbl.Location  = [System.Drawing.Point]::new(12, 12)
    $card.Controls.Add($iconLbl)

    $valLbl = [System.Windows.Forms.Label]::new()
    $valLbl.Text      = $Value
    $valLbl.Font      = $global:Fonts.TitleMedium
    $valLbl.ForeColor = $global:Colors.TextPrimary
    $valLbl.BackColor = [System.Drawing.Color]::Transparent
    $valLbl.AutoSize  = $true
    $valLbl.Location  = [System.Drawing.Point]::new(12, 28)
    $card.Controls.Add($valLbl)

    $lblLbl = [System.Windows.Forms.Label]::new()
    $lblLbl.Text      = $Label
    $lblLbl.Font      = $global:Fonts.Caption
    $lblLbl.ForeColor = $global:Colors.TextMuted
    $lblLbl.BackColor = [System.Drawing.Color]::Transparent
    $lblLbl.AutoSize  = $true
    $lblLbl.Location  = [System.Drawing.Point]::new(12, 58)
    $card.Controls.Add($lblLbl)

    return $card
}

# ── Toolbar row ───────────────────────────────────────────────────────────────
function global:New-Toolbar {
    param([scriptblock]$Builder)
    $bar = [System.Windows.Forms.Panel]::new()
    $bar.Dock      = [System.Windows.Forms.DockStyle]::Top
    $bar.Height    = 48
    $bar.BackColor = $global:Colors.BgBase
    $bar.Padding   = [System.Windows.Forms.Padding]::new(16, 0, 16, 0)

    $bar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, $s.Height-1, $s.Width, $s.Height-1)
        $pen.Dispose()
    })

    if ($Builder) { & $Builder $bar }
    return $bar
}

# ── Log panel ─────────────────────────────────────────────────────────────────
function global:New-LogPanel {
    param([string]$PlaceholderText = "No logs available")
    $p = [System.Windows.Forms.Panel]::new()
    $p.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $p.BackColor = $global:Colors.BgBase

    $rtb = [System.Windows.Forms.RichTextBox]::new()
    $rtb.Dock        = [System.Windows.Forms.DockStyle]::Fill
    $rtb.BackColor   = [System.Drawing.Color]::FromArgb(255, 10, 14, 20)
    $rtb.ForeColor   = $global:Colors.TextSecondary
    $rtb.Font        = $global:Fonts.Mono
    $rtb.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $rtb.ReadOnly    = $true
    $rtb.Text        = "[$(Get-Date -Format 'HH:mm:ss')] System initialized`r`n[$(Get-Date -Format 'HH:mm:ss')] $PlaceholderText`r`n[$(Get-Date -Format 'HH:mm:ss')] Awaiting operation..."
    $p.Controls.Add($rtb)
    return $p
}

# ── Overview page ─────────────────────────────────────────────────────────────
function global:Build-OverviewPage {
    param([System.Drawing.Color]$AccentColor = $null)
    if (-not $AccentColor) { $AccentColor = $global:Colors.AccentBlue }

    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $header = New-SectionHeader -Title "Overview" -Subtitle "Session status and summary" `
                                -BadgeText "Idle" -BadgeStatus "Idle"
    $page.Controls.Add($header)
    $page.Controls.Add((New-Divider))

    # Stat cards row
    $statsPanel = [System.Windows.Forms.Panel]::new()
    $statsPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
    $statsPanel.Height    = 100
    $statsPanel.BackColor = $global:Colors.BgBase
    $statsPanel.Padding   = [System.Windows.Forms.Padding]::new(24, 12, 24, 0)

    $statDefs = @(
        @{Label="Session Status"; Value="Idle";  Icon="◉"; Color=$global:Colors.StatusIdle  },
        @{Label="Items Reviewed"; Value="0";     Icon="☰"; Color=$AccentColor               },
        @{Label="Flags Raised";   Value="0";     Icon="⚑"; Color=$global:Colors.AccentOrange},
        @{Label="Duration";       Value="00:00"; Icon="◷"; Color=$global:Colors.TextMuted    }
    )
    $xPos = 24
    foreach ($sd in $statDefs) {
        $sc = New-StatCard -Label $sd.Label -Value $sd.Value -Icon $sd.Icon -Color $sd.Color
        $sc.Location = [System.Drawing.Point]::new($xPos, 12)
        $statsPanel.Controls.Add($sc)
        $xPos += 174
    }
    $page.Controls.Add($statsPanel)
    $page.Controls.Add((New-Divider))

    # Activity area
    $actHeader = New-SectionHeader -Title "Activity" -Subtitle "No activity detected"
    $page.Controls.Add($actHeader)

    $emptyState = New-EmptyStatePanel -Message "Awaiting Operation" -SubMessage "No scan or review has been started yet"
    $page.Controls.Add($emptyState)

    return $page
}

# ── Processes page ────────────────────────────────────────────────────────────
function global:Build-ProcessesPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Processes" -Subtitle "Running process list" -BadgeText "Not Started" -BadgeStatus "Idle"))
    $page.Controls.Add((New-Divider))

    $toolbar = New-Toolbar -Builder {
        param($bar)
        $search = New-SearchBar -Placeholder "Filter processes..." -Width 240
        $search.Location = [System.Drawing.Point]::new(16, 7)
        $bar.Controls.Add($search)

        $refreshBtn = New-AppButton -Text "↺  Refresh" -Style "Secondary" -Size "SM"
        $refreshBtn.Size     = [System.Drawing.Size]::new(90, 28)
        $refreshBtn.Location = [System.Drawing.Point]::new(270, 10)
        $bar.Controls.Add($refreshBtn)
    }
    $page.Controls.Add($toolbar)

    $table = New-AppTable -Columns @("Name","PID","Status","Type") -PlaceholderRows 0
    $page.Controls.Add($table)

    $empty = New-EmptyStatePanel -Message "No Processes Loaded" -SubMessage "No scan has been started"
    $page.Controls.Add($empty)

    return $page
}

# ── Files page ────────────────────────────────────────────────────────────────
function global:Build-FilesPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Files" -Subtitle "File system entries" -BadgeText "Not Started" -BadgeStatus "Idle"))
    $page.Controls.Add((New-Divider))

    $toolbar = New-Toolbar -Builder {
        param($bar)
        $search = New-SearchBar -Placeholder "Filter files..." -Width 240
        $search.Location = [System.Drawing.Point]::new(16, 7)
        $bar.Controls.Add($search)
    }
    $page.Controls.Add($toolbar)

    $empty = New-EmptyStatePanel -Message "No Files Loaded" -SubMessage "No data has been loaded yet"
    $page.Controls.Add($empty)

    return $page
}

# ── Logs page ─────────────────────────────────────────────────────────────────
function global:Build-LogsPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Logs" -Subtitle "Event and diagnostic output"))
    $page.Controls.Add((New-Divider))

    $toolbar = New-Toolbar -Builder {
        param($bar)
        $clearBtn = New-AppButton -Text "Clear" -Style "Ghost" -Size "SM"
        $clearBtn.Size     = [System.Drawing.Size]::new(70, 28)
        $clearBtn.Location = [System.Drawing.Point]::new(16, 10)
        $bar.Controls.Add($clearBtn)
    }
    $page.Controls.Add($toolbar)
    $page.Controls.Add((New-LogPanel))
    return $page
}

# ── Settings page ─────────────────────────────────────────────────────────────
function global:Build-SettingsPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Settings" -Subtitle "Application configuration"))
    $page.Controls.Add((New-Divider))

    $inner = [System.Windows.Forms.Panel]::new()
    $inner.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $inner.BackColor = $global:Colors.BgBase
    $inner.Padding   = [System.Windows.Forms.Padding]::new(24, 16, 24, 16)

    $settingDefs = @(
        @{Label="Theme"; Value="Dark (default)"},
        @{Label="Language"; Value="English"},
        @{Label="Log Level"; Value="Info"},
        @{Label="Auto-refresh"; Value="Disabled"},
        @{Label="Export Format"; Value="JSON"}
    )
    $yPos = 16
    foreach ($s in $settingDefs) {
        $row = [System.Windows.Forms.Panel]::new()
        $row.Size      = [System.Drawing.Size]::new(600, 40)
        $row.Location  = [System.Drawing.Point]::new(0, $yPos)
        $row.BackColor = $global:Colors.BgSurface

        $lbl = [System.Windows.Forms.Label]::new()
        $lbl.Text      = $s.Label
        $lbl.Font      = $global:Fonts.BodyMedium
        $lbl.ForeColor = $global:Colors.TextPrimary
        $lbl.BackColor = [System.Drawing.Color]::Transparent
        $lbl.Size      = [System.Drawing.Size]::new(200, 40)
        $lbl.Location  = [System.Drawing.Point]::new(16, 0)
        $lbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $val = [System.Windows.Forms.Label]::new()
        $val.Text      = $s.Value
        $val.Font      = $global:Fonts.BodyMedium
        $val.ForeColor = $global:Colors.TextSecondary
        $val.BackColor = [System.Drawing.Color]::Transparent
        $val.Size      = [System.Drawing.Size]::new(200, 40)
        $val.Location  = [System.Drawing.Point]::new(220, 0)
        $val.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $row.Controls.Add($lbl)
        $row.Controls.Add($val)
        $inner.Controls.Add($row)
        $yPos += 48
    }
    $page.Controls.Add($inner)
    return $page
}

# ── Injects page ──────────────────────────────────────────────────────────────
function global:Build-InjectsPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Injects" -Subtitle "Injection module list" -BadgeText "Not Started" -BadgeStatus "Idle"))
    $page.Controls.Add((New-Divider))

    $toolbar = New-Toolbar -Builder {
        param($bar)
        $search = New-SearchBar -Placeholder "Filter modules..." -Width 240
        $search.Location = [System.Drawing.Point]::new(16, 7)
        $bar.Controls.Add($search)
    }
    $page.Controls.Add($toolbar)
    $page.Controls.Add((New-AppTable -Columns @("Module","Source","Status") -PlaceholderRows 0))
    $page.Controls.Add((New-EmptyStatePanel -Message "No Inject Data" -SubMessage "No data loaded"))
    return $page
}

# ── Mod Analyzers page ────────────────────────────────────────────────────────
function global:Build-ModAnalyzersPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Mod Analyzers" -Subtitle "Module signature analysis"))
    $page.Controls.Add((New-Divider))
    $page.Controls.Add((New-EmptyStatePanel -Message "No Analysis Data" -SubMessage "No analyzer has been run"))
    return $page
}

# ── Macros page ───────────────────────────────────────────────────────────────
function global:Build-MacrosPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Macros" -Subtitle "Input macro detection"))
    $page.Controls.Add((New-Divider))
    $page.Controls.Add((New-EmptyStatePanel -Message "No Macro Data" -SubMessage "No macro scan started"))
    return $page
}
# =============================================================================
# CheesySSTool - MainWindow.ps1
# Main dashboard: three prominent mode-selection cards.
# =============================================================================

function global:Show-MainWindow {

    $form = New-BaseWindow -Title "CheesySSTool" -Subtitle "Screenshare Review Platform" `
                           -Width 860 -Height 560 -AccentColor $global:Colors.AccentBlue

    # ── Body below title bar ──────────────────────────────────────────────────
    $body = [System.Windows.Forms.Panel]::new()
    $body.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $body.BackColor = $global:Colors.BgBase
    $body.Padding   = [System.Windows.Forms.Padding]::new(0)
    $form.Controls.Add($body)

    # ── Header ───────────────────────────────────────────────────────────────
    $header = [System.Windows.Forms.Panel]::new()
    $header.Dock      = [System.Windows.Forms.DockStyle]::Top
    $header.Height    = 90
    $header.BackColor = $global:Colors.BgBase
    $header.Padding   = [System.Windows.Forms.Padding]::new(40, 20, 40, 0)
    $body.Controls.Add($header)

    $titleLbl = [System.Windows.Forms.Label]::new()
    $titleLbl.Text      = "Select Review Mode"
    $titleLbl.Font      = $global:Fonts.TitleLarge
    $titleLbl.ForeColor = $global:Colors.TextPrimary
    $titleLbl.BackColor = [System.Drawing.Color]::Transparent
    $titleLbl.AutoSize  = $true
    $titleLbl.Location  = [System.Drawing.Point]::new(40, 20)
    $header.Controls.Add($titleLbl)

    $subLbl = [System.Windows.Forms.Label]::new()
    $subLbl.Text      = "Choose the appropriate screenshare workflow for your session"
    $subLbl.Font      = $global:Fonts.BodyLarge
    $subLbl.ForeColor = $global:Colors.TextSecondary
    $subLbl.BackColor = [System.Drawing.Color]::Transparent
    $subLbl.AutoSize  = $true
    $subLbl.Location  = [System.Drawing.Point]::new(40, 52)
    $header.Controls.Add($subLbl)

    # ── Card container ────────────────────────────────────────────────────────
    $cardArea = [System.Windows.Forms.Panel]::new()
    $cardArea.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $cardArea.BackColor = $global:Colors.BgBase
    $body.Controls.Add($cardArea)

    # Mode definitions
    $modes = @(
        @{
            Label   = "Fast SS"
            Icon    = "⚡"
            Desc    = "Optimized for quick reviews and lightweight workflows"
            Sub     = "5 sections · Minimal controls"
            Color   = $global:Colors.FastColor
            Action  = { Show-FastSSWindow }
        },
        @{
            Label   = "Normal SS"
            Icon    = "⊞"
            Desc    = "Balanced workflow with filters, search, and status indicators"
            Sub     = "7 sections · Moderate depth"
            Color   = $global:Colors.NormalColor
            Action  = { Show-NormalSSWindow }
        },
        @{
            Label   = "Full SS"
            Icon    = "◈"
            Desc    = "Comprehensive interface with advanced panels and analytics"
            Sub     = "8 sections · Full suite"
            Color   = $global:Colors.FullColor
            Action  = { Show-FullSSWindow }
        }
    )

    # Build cards dynamically on resize
    $buildCards = {
        $cardArea.Controls.Clear()
        $padding = 36
        $gap     = 16
        $count   = $modes.Count
        $totalW  = $cardArea.Width - ($padding * 2) - ($gap * ($count - 1))
        $cardW   = [int]($totalW / $count)
        $cardH   = [System.Math]::Min(320, $cardArea.Height - 48)
        $topY    = ($cardArea.Height - $cardH) / 2

        for ($i = 0; $i -lt $count; $i++) {
            $m = $modes[$i]
            $x = $padding + $i * ($cardW + $gap)
            $card = New-ModeCard -Mode $m -Size ([System.Drawing.Size]::new($cardW, $cardH)) `
                                 -Location ([System.Drawing.Point]::new($x, $topY))
            $cardArea.Controls.Add($card)
        }
    }

    $cardArea.Add_Resize($buildCards)

    # ── Footer ────────────────────────────────────────────────────────────────
    $footer = [System.Windows.Forms.Panel]::new()
    $footer.Dock      = [System.Windows.Forms.DockStyle]::Bottom
    $footer.Height    = 36
    $footer.BackColor = $global:Colors.BgBase

    $verLbl = [System.Windows.Forms.Label]::new()
    $verLbl.Text      = "CheesySSTool v2.0  ·  Ready"
    $verLbl.Font      = $global:Fonts.Caption
    $verLbl.ForeColor = $global:Colors.TextMuted
    $verLbl.BackColor = [System.Drawing.Color]::Transparent
    $verLbl.AutoSize  = $true
    $verLbl.Location  = [System.Drawing.Point]::new(24, 10)
    $footer.Controls.Add($verLbl)

    $footer.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
        $pen.Dispose()
    })
    $body.Controls.Add($footer)

    $form.Add_Shown({ & $buildCards })

    Register-Window -Name "Main" -Form $form
    $form.ShowDialog() | Out-Null
}

function global:New-ModeCard {
    <#
    .SYNOPSIS Creates a single mode selection card with icon, title, desc, and launch button.
    #>
    param(
        [hashtable]$Mode,
        [System.Drawing.Size]$Size,
        [System.Drawing.Point]$Location
    )

    $card = [System.Windows.Forms.Panel]::new()
    $card.Size      = $Size
    $card.Location  = $Location
    $card.BackColor = $global:Colors.BgSurface
    $card.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $accentColor   = $Mode.Color
    $isHovered     = $false

    # Paint: rounded card with border
    $card.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $r = $global:Radius.Card
        $w = $s.Width - 1; $h = $s.Height - 1

        # Background fill
        $bgBrush = [System.Drawing.SolidBrush]::new($s.BackColor)
        # Simple rounded rectangle approximation via region
        $path = New-RoundedPath -X 0 -Y 0 -W $w -H $h -R $r
        $g.FillPath($bgBrush, $path)

        # Top accent stripe
        $accentBrush = [System.Drawing.SolidBrush]::new($accentColor)
        $accentPath  = New-RoundedPath -X 0 -Y 0 -W $w -H 4 -R 0
        $g.FillRectangle($accentBrush, 0, 0, $w, 4)

        # Border
        $borderPen = if ($isHovered) {
            [System.Drawing.Pen]::new($accentColor, 1)
        } else {
            [System.Drawing.Pen]::new($global:Colors.BorderDefault, 1)
        }
        $g.DrawPath($borderPen, $path)

        $bgBrush.Dispose(); $accentBrush.Dispose(); $borderPen.Dispose(); $path.Dispose()
    })

    $card.Add_MouseEnter({
        $card.BackColor = $global:Colors.BgElevated
        $script:isHovered = $true
        $card.Invalidate()
    })
    $card.Add_MouseLeave({
        $card.BackColor = $global:Colors.BgSurface
        $script:isHovered = $false
        $card.Invalidate()
    })

    # Icon
    $iconLbl = [System.Windows.Forms.Label]::new()
    $iconLbl.Text      = $Mode.Icon
    $iconLbl.Font      = [System.Drawing.Font]::new("Segoe UI", 28)
    $iconLbl.ForeColor = $accentColor
    $iconLbl.BackColor = [System.Drawing.Color]::Transparent
    $iconLbl.Size      = [System.Drawing.Size]::new($Size.Width - 40, 54)
    $iconLbl.Location  = [System.Drawing.Point]::new(20, 28)
    $iconLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $card.Controls.Add($iconLbl)

    # Mode label
    $modeLbl = [System.Windows.Forms.Label]::new()
    $modeLbl.Text      = $Mode.Label
    $modeLbl.Font      = $global:Fonts.ModeCard
    $modeLbl.ForeColor = $global:Colors.TextPrimary
    $modeLbl.BackColor = [System.Drawing.Color]::Transparent
    $modeLbl.Size      = [System.Drawing.Size]::new($Size.Width - 40, 28)
    $modeLbl.Location  = [System.Drawing.Point]::new(20, 88)
    $card.Controls.Add($modeLbl)

    # Description
    $descLbl = [System.Windows.Forms.Label]::new()
    $descLbl.Text      = $Mode.Desc
    $descLbl.Font      = $global:Fonts.ModeCardSub
    $descLbl.ForeColor = $global:Colors.TextSecondary
    $descLbl.BackColor = [System.Drawing.Color]::Transparent
    $descLbl.Size      = [System.Drawing.Size]::new($Size.Width - 40, 46)
    $descLbl.Location  = [System.Drawing.Point]::new(20, 118)
    $card.Controls.Add($descLbl)

    # Sub info badge
    $subLbl = [System.Windows.Forms.Label]::new()
    $subLbl.Text      = $Mode.Sub
    $subLbl.Font      = $global:Fonts.Caption
    $subLbl.ForeColor = $accentColor
    $subLbl.BackColor = [System.Drawing.Color]::FromArgb(30, $accentColor.R, $accentColor.G, $accentColor.B)
    $subLbl.AutoSize  = $true
    $subLbl.Location  = [System.Drawing.Point]::new(20, 172)
    $subLbl.Padding   = [System.Windows.Forms.Padding]::new(6, 3, 6, 3)
    $card.Controls.Add($subLbl)

    # Launch button
    $btn = New-AppButton -Text "Launch $($Mode.Label)  →" -Style "Primary" -Size "LG" `
        -OnClick $Mode.Action
    $btn.BackColor = $accentColor
    $btn.FlatAppearance.BorderColor = $accentColor
    $btn.Size     = [System.Drawing.Size]::new($Size.Width - 40, 42)
    $btn.Location = [System.Drawing.Point]::new(20, $Size.Height - 70)
    $card.Controls.Add($btn)

    # Forward mouse events on children to card for hover
    foreach ($child in $card.Controls) {
        $child.Add_MouseEnter({ $card.BackColor = $global:Colors.BgElevated; $card.Invalidate() })
        $child.Add_MouseLeave({ $card.BackColor = $global:Colors.BgSurface;  $card.Invalidate() })
    }

    return $card
}

function global:New-RoundedPath {
    param([int]$X, [int]$Y, [int]$W, [int]$H, [int]$R)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    if ($R -lt 2) {
        $path.AddRectangle([System.Drawing.Rectangle]::new($X, $Y, $W, $H))
    } else {
        $path.AddArc($X, $Y, $R*2, $R*2, 180, 90)
        $path.AddArc($X+$W-$R*2, $Y, $R*2, $R*2, 270, 90)
        $path.AddArc($X+$W-$R*2, $Y+$H-$R*2, $R*2, $R*2, 0, 90)
        $path.AddArc($X, $Y+$H-$R*2, $R*2, $R*2, 90, 90)
        $path.CloseFigure()
    }
    return $path
}
# =============================================================================
# CheesySSTool - FastSSWindow.ps1
# Lightweight 5-section screenshare review window.
# =============================================================================

function global:Show-FastSSWindow {

    $form = New-BaseWindow -Title "CheesySSTool  —  Fast SS" -Subtitle "Quick lightweight review" `
                           -Width 1000 -Height 680 -AccentColor $global:Colors.FastColor

    # ── Layout: Sidebar + Content ─────────────────────────────────────────────
    $body = [System.Windows.Forms.Panel]::new()
    $body.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $body.BackColor = $global:Colors.BgBase
    $form.Controls.Add($body)

    $navItems = @(
        @{Label="Overview";  Icon="◉"; Tag="overview" },
        @{Label="Processes"; Icon="⊞"; Tag="processes"},
        @{Label="Files";     Icon="☰"; Tag="files"    },
        @{Label="Logs";      Icon="≡"; Tag="logs"     },
        @{Label="Settings";  Icon="⚙"; Tag="settings" }
    )

    $contentHost = New-ContentHost

    $sidebar = New-Sidebar -Items $navItems -AccentColor $global:Colors.FastColor -OnSelect {
        param($tag)
        Navigate-To -ContentHost $contentHost -PageTag $tag
    }

    # Build all pages
    Add-Page -Host $contentHost -Tag "overview"  -Builder { Build-OverviewPage -AccentColor $global:Colors.FastColor } -Visible $true
    Add-Page -Host $contentHost -Tag "processes" -Builder { Build-ProcessesPage }
    Add-Page -Host $contentHost -Tag "files"     -Builder { Build-FilesPage     }
    Add-Page -Host $contentHost -Tag "logs"      -Builder { Build-LogsPage      }
    Add-Page -Host $contentHost -Tag "settings"  -Builder { Build-SettingsPage  }

    $body.Controls.Add($contentHost)
    $body.Controls.Add($sidebar)

    # ── Bottom status bar ─────────────────────────────────────────────────────
    $statusBar = [System.Windows.Forms.Panel]::new()
    $statusBar.Dock      = [System.Windows.Forms.DockStyle]::Bottom
    $statusBar.Height    = 26
    $statusBar.BackColor = $global:Colors.BgElevated
    $statusBar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
        $pen.Dispose()
    })

    $modeLbl = [System.Windows.Forms.Label]::new()
    $modeLbl.Text      = "  ⚡ Fast SS  ·  Ready  ·  No scan in progress"
    $modeLbl.Font      = $global:Fonts.Caption
    $modeLbl.ForeColor = $global:Colors.TextMuted
    $modeLbl.BackColor = [System.Drawing.Color]::Transparent
    $modeLbl.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $modeLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $statusBar.Controls.Add($modeLbl)

    $form.Controls.Add($statusBar)

    Register-Window -Name "FastSS" -Form $form
    $form.ShowDialog() | Out-Null
}
# =============================================================================
# CheesySSTool - NormalSSWindow.ps1
# Balanced 7-section screenshare review window with search/filter bars.
# =============================================================================

function global:Show-NormalSSWindow {

    $form = New-BaseWindow -Title "CheesySSTool  —  Normal SS" -Subtitle "Balanced review workflow" `
                           -Width 1100 -Height 720 -AccentColor $global:Colors.NormalColor

    $body = [System.Windows.Forms.Panel]::new()
    $body.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $body.BackColor = $global:Colors.BgBase
    $form.Controls.Add($body)

    $navItems = @(
        @{Label="Overview";      Icon="◉"; Tag="overview"     },
        @{Label="Injects";       Icon="⊕"; Tag="injects"      },
        @{Label="Mod Analyzers"; Icon="◈"; Tag="mod-analyzers"},
        @{Label="Processes";     Icon="⊞"; Tag="processes"    },
        @{Label="Files";         Icon="☰"; Tag="files"        },
        @{Label="Logs";          Icon="≡"; Tag="logs"         },
        @{Label="Settings";      Icon="⚙"; Tag="settings"     }
    )

    $contentHost = New-ContentHost

    $sidebar = New-Sidebar -Items $navItems -AccentColor $global:Colors.NormalColor -OnSelect {
        param($tag)
        Navigate-To -ContentHost $contentHost -PageTag $tag
    }

    Add-Page -Host $contentHost -Tag "overview"      -Builder { Build-OverviewPage -AccentColor $global:Colors.NormalColor } -Visible $true
    Add-Page -Host $contentHost -Tag "injects"       -Builder { Build-InjectsPage       }
    Add-Page -Host $contentHost -Tag "mod-analyzers" -Builder { Build-ModAnalyzersPage  }
    Add-Page -Host $contentHost -Tag "processes"     -Builder { Build-ProcessesPage     }
    Add-Page -Host $contentHost -Tag "files"         -Builder { Build-FilesPage         }
    Add-Page -Host $contentHost -Tag "logs"          -Builder { Build-LogsPage          }
    Add-Page -Host $contentHost -Tag "settings"      -Builder { Build-SettingsPage      }

    $body.Controls.Add($contentHost)
    $body.Controls.Add($sidebar)

    # Status bar
    $statusBar = [System.Windows.Forms.Panel]::new()
    $statusBar.Dock      = [System.Windows.Forms.DockStyle]::Bottom
    $statusBar.Height    = 26
    $statusBar.BackColor = $global:Colors.BgElevated
    $statusBar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
        $pen.Dispose()
    })

    $modeLbl = [System.Windows.Forms.Label]::new()
    $modeLbl.Text      = "  ⊞ Normal SS  ·  Ready  ·  No scan in progress"
    $modeLbl.Font      = $global:Fonts.Caption
    $modeLbl.ForeColor = $global:Colors.TextMuted
    $modeLbl.BackColor = [System.Drawing.Color]::Transparent
    $modeLbl.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $modeLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $statusBar.Controls.Add($modeLbl)

    $form.Controls.Add($statusBar)

    Register-Window -Name "NormalSS" -Form $form
    $form.ShowDialog() | Out-Null
}
# =============================================================================
# CheesySSTool - FullSSWindow.ps1
# Advanced 8-section screenshare review window with full analytics suite.
# =============================================================================

function global:Show-FullSSWindow {

    $form = New-BaseWindow -Title "CheesySSTool  —  Full SS" -Subtitle "Comprehensive review suite" `
                           -Width 1280 -Height 800 -AccentColor $global:Colors.FullColor

    $body = [System.Windows.Forms.Panel]::new()
    $body.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $body.BackColor = $global:Colors.BgBase
    $form.Controls.Add($body)

    $navItems = @(
        @{Label="Overview";      Icon="◉"; Tag="overview"     },
        @{Label="Injects";       Icon="⊕"; Tag="injects"      },
        @{Label="Mod Analyzers"; Icon="◈"; Tag="mod-analyzers"},
        @{Label="Macros";        Icon="⌨"; Tag="macros"       },
        @{Label="Processes";     Icon="⊞"; Tag="processes"    },
        @{Label="Files";         Icon="☰"; Tag="files"        },
        @{Label="Logs";          Icon="≡"; Tag="logs"         },
        @{Label="Settings";      Icon="⚙"; Tag="settings"     }
    )

    $contentHost = New-ContentHost

    $sidebar = New-Sidebar -Items $navItems -AccentColor $global:Colors.FullColor -OnSelect {
        param($tag)
        Navigate-To -ContentHost $contentHost -PageTag $tag
    }

    Add-Page -Host $contentHost -Tag "overview"      -Builder { Build-FullOverviewPage    } -Visible $true
    Add-Page -Host $contentHost -Tag "injects"       -Builder { Build-InjectsPage         }
    Add-Page -Host $contentHost -Tag "mod-analyzers" -Builder { Build-ModAnalyzersPage    }
    Add-Page -Host $contentHost -Tag "macros"        -Builder { Build-MacrosPage          }
    Add-Page -Host $contentHost -Tag "processes"     -Builder { Build-FullProcessesPage   }
    Add-Page -Host $contentHost -Tag "files"         -Builder { Build-FilesPage           }
    Add-Page -Host $contentHost -Tag "logs"          -Builder { Build-LogsPage            }
    Add-Page -Host $contentHost -Tag "settings"      -Builder { Build-SettingsPage        }

    $body.Controls.Add($contentHost)
    $body.Controls.Add($sidebar)

    # Status bar with more info
    $statusBar = [System.Windows.Forms.Panel]::new()
    $statusBar.Dock      = [System.Windows.Forms.DockStyle]::Bottom
    $statusBar.Height    = 28
    $statusBar.BackColor = $global:Colors.BgElevated
    $statusBar.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
        $pen.Dispose()
    })

    $modeLbl = [System.Windows.Forms.Label]::new()
    $modeLbl.Text      = "  ◈ Full SS  ·  Ready  ·  Session: Not Started  ·  0 items reviewed  ·  0 flags"
    $modeLbl.Font      = $global:Fonts.Caption
    $modeLbl.ForeColor = $global:Colors.TextMuted
    $modeLbl.BackColor = [System.Drawing.Color]::Transparent
    $modeLbl.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $modeLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $statusBar.Controls.Add($modeLbl)

    # Right side clock
    $clockLbl = [System.Windows.Forms.Label]::new()
    $clockLbl.Text      = (Get-Date -Format "HH:mm")
    $clockLbl.Font      = $global:Fonts.Caption
    $clockLbl.ForeColor = $global:Colors.TextMuted
    $clockLbl.BackColor = [System.Drawing.Color]::Transparent
    $clockLbl.AutoSize  = $true
    $clockLbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $statusBar.Controls.Add($clockLbl)
    $statusBar.Add_Resize({
        $clockLbl.Location = [System.Drawing.Point]::new($statusBar.Width - $clockLbl.Width - 16, 6)
    })

    $clockTimer = [System.Windows.Forms.Timer]::new()
    $clockTimer.Interval = 30000
    $clockTimer.Add_Tick({ $clockLbl.Text = (Get-Date -Format "HH:mm") })
    $clockTimer.Start()
    $form.Add_FormClosed({ $clockTimer.Stop(); $clockTimer.Dispose() })

    $form.Controls.Add($statusBar)

    Register-Window -Name "FullSS" -Form $form
    $form.ShowDialog() | Out-Null
}

# ── Full Overview (enhanced) ──────────────────────────────────────────────────
function global:Build-FullOverviewPage {

    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Overview" -Subtitle "Full session dashboard" `
                                          -BadgeText "Idle" -BadgeStatus "Idle"))
    $page.Controls.Add((New-Divider))

    # ── Top stats row ─────────────────────────────────────────────────────────
    $statsPanel = [System.Windows.Forms.Panel]::new()
    $statsPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
    $statsPanel.Height    = 100
    $statsPanel.BackColor = $global:Colors.BgBase
    $statsPanel.Padding   = [System.Windows.Forms.Padding]::new(24, 12, 24, 0)

    $statDefs = @(
        @{Label="Session Status"; Value="Idle";  Icon="◉"; Color=$global:Colors.StatusIdle   },
        @{Label="Items Reviewed"; Value="0";     Icon="☰"; Color=$global:Colors.FullColor    },
        @{Label="Flags Raised";   Value="0";     Icon="⚑"; Color=$global:Colors.AccentOrange },
        @{Label="Injects Found";  Value="0";     Icon="⊕"; Color=$global:Colors.AccentRed    },
        @{Label="Duration";       Value="00:00"; Icon="◷"; Color=$global:Colors.TextMuted     }
    )
    $xPos = 24
    foreach ($sd in $statDefs) {
        $sc = New-StatCard -Label $sd.Label -Value $sd.Value -Icon $sd.Icon -Color $sd.Color
        $sc.Location = [System.Drawing.Point]::new($xPos, 12)
        $statsPanel.Controls.Add($sc)
        $xPos += 174
    }
    $page.Controls.Add($statsPanel)
    $page.Controls.Add((New-Divider))

    # ── Two-column lower section ───────────────────────────────────────────────
    $columns = [System.Windows.Forms.Panel]::new()
    $columns.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $columns.BackColor = $global:Colors.BgBase

    # Left: Activity Dashboard
    $leftCol = [System.Windows.Forms.Panel]::new()
    $leftCol.Dock      = [System.Windows.Forms.DockStyle]::Left
    $leftCol.Width     = 420
    $leftCol.BackColor = $global:Colors.BgBase
    $leftCol.Padding   = [System.Windows.Forms.Padding]::new(16)

    $actHeader = [System.Windows.Forms.Label]::new()
    $actHeader.Text      = "Activity Dashboard"
    $actHeader.Font      = $global:Fonts.HeadingSmall
    $actHeader.ForeColor = $global:Colors.TextSecondary
    $actHeader.BackColor = [System.Drawing.Color]::Transparent
    $actHeader.AutoSize  = $true
    $actHeader.Location  = [System.Drawing.Point]::new(16, 12)
    $leftCol.Controls.Add($actHeader)

    $actPanel = [System.Windows.Forms.Panel]::new()
    $actPanel.BackColor = $global:Colors.BgSurface
    $actPanel.Size      = [System.Drawing.Size]::new(386, 200)
    $actPanel.Location  = [System.Drawing.Point]::new(16, 38)
    $actPanel.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width-1, $s.Height-1)
        $pen.Dispose()
    })

    $noActLbl = [System.Windows.Forms.Label]::new()
    $noActLbl.Text      = "No activity detected"
    $noActLbl.Font      = $global:Fonts.BodyMedium
    $noActLbl.ForeColor = $global:Colors.TextDisabled
    $noActLbl.BackColor = [System.Drawing.Color]::Transparent
    $noActLbl.AutoSize  = $true
    $noActLbl.Location  = [System.Drawing.Point]::new(130, 90)
    $actPanel.Controls.Add($noActLbl)
    $leftCol.Controls.Add($actPanel)

    # Session info panel
    $sessionHeader = [System.Windows.Forms.Label]::new()
    $sessionHeader.Text      = "Session Information"
    $sessionHeader.Font      = $global:Fonts.HeadingSmall
    $sessionHeader.ForeColor = $global:Colors.TextSecondary
    $sessionHeader.BackColor = [System.Drawing.Color]::Transparent
    $sessionHeader.AutoSize  = $true
    $sessionHeader.Location  = [System.Drawing.Point]::new(16, 252)
    $leftCol.Controls.Add($sessionHeader)

    $sessionRows = @(
        @{Key="Session ID";    Val="Not assigned"},
        @{Key="Start Time";    Val="—"},
        @{Key="Reviewer";      Val="—"},
        @{Key="Mode";          Val="Full SS"},
        @{Key="Profile";       Val="Default"}
    )
    $yOff = 278
    foreach ($row in $sessionRows) {
        $kLbl = [System.Windows.Forms.Label]::new()
        $kLbl.Text      = $row.Key
        $kLbl.Font      = $global:Fonts.Caption
        $kLbl.ForeColor = $global:Colors.TextMuted
        $kLbl.BackColor = [System.Drawing.Color]::Transparent
        $kLbl.Size      = [System.Drawing.Size]::new(130, 22)
        $kLbl.Location  = [System.Drawing.Point]::new(16, $yOff)
        $leftCol.Controls.Add($kLbl)

        $vLbl = [System.Windows.Forms.Label]::new()
        $vLbl.Text      = $row.Val
        $vLbl.Font      = $global:Fonts.BodySmall
        $vLbl.ForeColor = $global:Colors.TextPrimary
        $vLbl.BackColor = [System.Drawing.Color]::Transparent
        $vLbl.Size      = [System.Drawing.Size]::new(220, 22)
        $vLbl.Location  = [System.Drawing.Point]::new(150, $yOff)
        $leftCol.Controls.Add($vLbl)

        $yOff += 24
    }

    $columns.Controls.Add($leftCol)

    # Right: Statistics + Advanced Filters
    $rightCol = [System.Windows.Forms.Panel]::new()
    $rightCol.Dock      = [System.Windows.Forms.DockStyle]::Fill
    $rightCol.BackColor = $global:Colors.BgBase
    $rightCol.Padding   = [System.Windows.Forms.Padding]::new(16)

    $statsHeader = [System.Windows.Forms.Label]::new()
    $statsHeader.Text      = "Statistics Panel"
    $statsHeader.Font      = $global:Fonts.HeadingSmall
    $statsHeader.ForeColor = $global:Colors.TextSecondary
    $statsHeader.BackColor = [System.Drawing.Color]::Transparent
    $statsHeader.AutoSize  = $true
    $statsHeader.Location  = [System.Drawing.Point]::new(16, 12)
    $rightCol.Controls.Add($statsHeader)

    # Placeholder progress bars
    $pbarDefs = @(
        @{Label="Processes Scanned"; Value=0; Color=$global:Colors.AccentBlue   },
        @{Label="Files Reviewed";    Value=0; Color=$global:Colors.FullColor    },
        @{Label="Injects Checked";   Value=0; Color=$global:Colors.AccentOrange }
    )
    $pbarY = 38
    foreach ($pb in $pbarDefs) {
        $lbl = [System.Windows.Forms.Label]::new()
        $lbl.Text      = "$($pb.Label)  —  0%"
        $lbl.Font      = $global:Fonts.Caption
        $lbl.ForeColor = $global:Colors.TextMuted
        $lbl.BackColor = [System.Drawing.Color]::Transparent
        $lbl.AutoSize  = $true
        $lbl.Location  = [System.Drawing.Point]::new(16, $pbarY)
        $rightCol.Controls.Add($lbl)
        $pbarY += 18

        $track = [System.Windows.Forms.Panel]::new()
        $track.Size      = [System.Drawing.Size]::new(380, 6)
        $track.Location  = [System.Drawing.Point]::new(16, $pbarY)
        $track.BackColor = $global:Colors.BgElevated
        $rightCol.Controls.Add($track)

        $fill = [System.Windows.Forms.Panel]::new()
        $fill.Size      = [System.Drawing.Size]::new(0, 6)
        $fill.Location  = [System.Drawing.Point]::new(0, 0)
        $fill.BackColor = $pb.Color
        $track.Controls.Add($fill)

        $pbarY += 26
    }

    # Advanced filters section
    $filtersHeader = [System.Windows.Forms.Label]::new()
    $filtersHeader.Text      = "Advanced Filters"
    $filtersHeader.Font      = $global:Fonts.HeadingSmall
    $filtersHeader.ForeColor = $global:Colors.TextSecondary
    $filtersHeader.BackColor = [System.Drawing.Color]::Transparent
    $filtersHeader.AutoSize  = $true
    $filtersHeader.Location  = [System.Drawing.Point]::new(16, $pbarY + 8)
    $rightCol.Controls.Add($filtersHeader)

    $filterPanel = [System.Windows.Forms.Panel]::new()
    $filterPanel.BackColor = $global:Colors.BgSurface
    $filterPanel.Size      = [System.Drawing.Size]::new(380, 110)
    $filterPanel.Location  = [System.Drawing.Point]::new(16, $pbarY + 32)
    $filterPanel.Add_Paint({
        param($s, $e)
        $pen = [System.Drawing.Pen]::new($global:Colors.BorderSubtle, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width-1, $s.Height-1)
        $pen.Dispose()
    })

    $filterItems = @("Category", "Status", "Time Range", "Flag Level")
    $fxPos = 12; $fyPos = 14
    foreach ($f in $filterItems) {
        $fLbl = [System.Windows.Forms.Label]::new()
        $fLbl.Text      = "${f}:"
        $fLbl.Font      = $global:Fonts.Caption
        $fLbl.ForeColor = $global:Colors.TextMuted
        $fLbl.BackColor = [System.Drawing.Color]::Transparent
        $fLbl.AutoSize  = $true
        $fLbl.Location  = [System.Drawing.Point]::new($fxPos, $fyPos)
        $filterPanel.Controls.Add($fLbl)

        $fDrop = [System.Windows.Forms.ComboBox]::new()
        $fDrop.Items.Add("All") | Out-Null
        $fDrop.SelectedIndex  = 0
        $fDrop.FlatStyle      = [System.Windows.Forms.FlatStyle]::Flat
        $fDrop.Font           = $global:Fonts.Caption
        $fDrop.BackColor      = $global:Colors.BgElevated
        $fDrop.ForeColor      = $global:Colors.TextSecondary
        $fDrop.Size           = [System.Drawing.Size]::new(130, 22)
        $fDrop.Location       = [System.Drawing.Point]::new($fxPos + 70, $fyPos - 2)
        $filterPanel.Controls.Add($fDrop)

        $fyPos += 24
        if ($fyPos -gt 70) { $fxPos = 210; $fyPos = 14 }
    }
    $rightCol.Controls.Add($filterPanel)
    $columns.Controls.Add($rightCol)
    $page.Controls.Add($columns)

    return $page
}

# ── Full Processes (with extra columns) ───────────────────────────────────────
function global:Build-FullProcessesPage {
    $page = [System.Windows.Forms.Panel]::new()
    $page.BackColor = $global:Colors.BgBase

    $page.Controls.Add((New-SectionHeader -Title "Processes" -Subtitle "Extended process analysis" `
                                          -BadgeText "Not Started" -BadgeStatus "Idle"))
    $page.Controls.Add((New-Divider))

    $toolbar = New-Toolbar -Builder {
        param($bar)
        $search = New-SearchBar -Placeholder "Filter processes..." -Width 240
        $search.Location = [System.Drawing.Point]::new(16, 7)
        $bar.Controls.Add($search)

        $catDrop = [System.Windows.Forms.ComboBox]::new()
        @("All Types","System","User","Unknown") | ForEach-Object { $catDrop.Items.Add($_) | Out-Null }
        $catDrop.SelectedIndex = 0
        $catDrop.FlatStyle     = [System.Windows.Forms.FlatStyle]::Flat
        $catDrop.Font          = $global:Fonts.Caption
        $catDrop.BackColor     = $global:Colors.BgElevated
        $catDrop.ForeColor     = $global:Colors.TextSecondary
        $catDrop.Size          = [System.Drawing.Size]::new(120, 28)
        $catDrop.Location      = [System.Drawing.Point]::new(270, 10)
        $bar.Controls.Add($catDrop)

        $statusDrop = [System.Windows.Forms.ComboBox]::new()
        @("All Status","Running","Stopped","Suspended") | ForEach-Object { $statusDrop.Items.Add($_) | Out-Null }
        $statusDrop.SelectedIndex = 0
        $statusDrop.FlatStyle     = [System.Windows.Forms.FlatStyle]::Flat
        $statusDrop.Font          = $global:Fonts.Caption
        $statusDrop.BackColor     = $global:Colors.BgElevated
        $statusDrop.ForeColor     = $global:Colors.TextSecondary
        $statusDrop.Size          = [System.Drawing.Size]::new(120, 28)
        $statusDrop.Location      = [System.Drawing.Point]::new(400, 10)
        $bar.Controls.Add($statusDrop)

        $refreshBtn = New-AppButton -Text "↺  Refresh" -Style "Secondary" -Size "SM"
        $refreshBtn.Size     = [System.Drawing.Size]::new(90, 28)
        $refreshBtn.Location = [System.Drawing.Point]::new(530, 10)
        $bar.Controls.Add($refreshBtn)
    }
    $page.Controls.Add($toolbar)

    $table = New-AppTable -Columns @("Name","PID","Status","Type","CPU%","Memory","Flag") -PlaceholderRows 0
    $page.Controls.Add($table)
    $page.Controls.Add((New-EmptyStatePanel -Message "No Process Data" -SubMessage "No scan has been started"))

    return $page
}

# ── Launch ───────────────────────────────────────────────────────────────────
Show-MainWindow
