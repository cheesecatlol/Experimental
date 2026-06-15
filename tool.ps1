Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$installDir = "$env:USERPROFILE\Downloads\CheesySSTool"

# ==============================================================================
# TOOL DATA
# ==============================================================================
$ToolData = @(
    @{ Name="PrefetchView";       Category="Orbdiff";    Type="GitHub"; Desc="Views prefetch execution files";          URL="https://github.com/Orbdiff/PrefetchView/releases/tag/v1.6.7" },
    @{ Name="BAMReveal";          Category="Orbdiff";    Type="GitHub"; Desc="Reveals BAM execution history";           URL="https://github.com/Orbdiff/BAMReveal/releases/tag/v1.3.1" },
    @{ Name="StringsParser";      Category="Orbdiff";    Type="GitHub"; Desc="Extracts strings from binaries";          URL="https://github.com/Orbdiff/StringsParser/releases/tag/v1.0" },
    @{ Name="Fileless";           Category="Orbdiff";    Type="GitHub"; Desc="Detects fileless malware traces";         URL="https://github.com/Orbdiff/Fileless/releases/tag/v1.3" },
    @{ Name="DPS-Analyzer";       Category="Orbdiff";    Type="GitHub"; Desc="Analyzes DPS service logs";               URL="https://github.com/Orbdiff/DPS-Analyzer/releases/tag/v1.1" },
    @{ Name="UserAssistView";     Category="Orbdiff";    Type="GitHub"; Desc="Shows UserAssist registry entries";       URL="https://github.com/Orbdiff/UserAssistView/releases/tag/v1.0" },
    @{ Name="JournalParser";      Category="Orbdiff";    Type="GitHub"; Desc="Parses NTFS journal for file activity";   URL="https://github.com/Orbdiff/JournalParser/releases/tag/v1.2" },
    @{ Name="InjGen";             Category="Orbdiff";    Type="GitHub"; Desc="Checks for DLL injection traces";         URL="https://github.com/Orbdiff/InjGen/releases/tag/fork" },
    @{ Name="USBDetector";        Category="Orbdiff";    Type="GitHub"; Desc="Finds connected USB device history";      URL="https://github.com/Orbdiff/USBDetector/releases/tag/v1.1" },
    @{ Name="PFTrace";            Category="Orbdiff";    Type="GitHub"; Desc="Traces prefetch file timestamps";         URL="https://github.com/Orbdiff/PFTrace/releases/tag/v1.0.1" },
    @{ Name="CheckDeletedUSN";    Category="Orbdiff";    Type="GitHub"; Desc="Finds deleted files via USN journal";     URL="https://github.com/Orbdiff/CheckDeletedUSN/releases/tag/v0.2.1" },
    @{ Name="JARParser";          Category="Orbdiff";    Type="GitHub"; Desc="Parses JAR files for suspicious content"; URL="https://github.com/Orbdiff/JARParser/releases/tag/v1.2" },
    @{ Name="BAM-parser";         Category="Spokwn";     Type="GitHub"; Desc="Parses BAM execution records";            URL="https://github.com/spokwn/BAM-parser/releases/tag/v1.2.9" },
    @{ Name="PathsParser";        Category="Spokwn";     Type="GitHub"; Desc="Lists recently accessed file paths";      URL="https://github.com/spokwn/PathsParser/releases/tag/v1.2" },
    @{ Name="JournalTrace";       Category="Spokwn";     Type="GitHub"; Desc="Traces NTFS journal file events";         URL="https://github.com/spokwn/JournalTrace/releases/tag/1.2" },
    @{ Name="KernelLiveDumpTool"; Category="Spokwn";     Type="GitHub"; Desc="Captures live kernel memory dump";        URL="https://github.com/spokwn/KernelLiveDumpTool/releases/tag/v1.1" },
    @{ Name="BamDeletedKeys";     Category="Spokwn";     Type="GitHub"; Desc="Finds deleted BAM registry keys";         URL="https://github.com/spokwn/BamDeletedKeys/releases/tag/v1.0" },
    @{ Name="Tool";               Category="Spokwn";     Type="GitHub"; Desc="General-purpose SS analysis tool";        URL="https://github.com/spokwn/Tool/releases/tag/v1.1.3" },
    @{ Name="pcasvc-executed";    Category="Spokwn";     Type="GitHub"; Desc="Shows PCA service execution history";     URL="https://github.com/spokwn/pcasvc-executed/releases/tag/v0.8.7" },
    @{ Name="process-parser";     Category="Spokwn";     Type="GitHub"; Desc="Parses recent process execution data";    URL="https://github.com/spokwn/process-parser/releases/tag/v0.5.5" },
    @{ Name="prefetch-parser";    Category="Spokwn";     Type="GitHub"; Desc="Parses Windows prefetch files";           URL="https://github.com/spokwn/prefetch-parser/releases/tag/v1.5.5" },
    @{ Name="ActivitiesCache";    Category="Spokwn";     Type="GitHub"; Desc="Reads Windows timeline activities cache"; URL="https://github.com/spokwn/ActivitiesCache-execution/releases/tag/v0.6.5" },
    @{ Name="MeowDoomsdayFucker"; Category="Tonynoh";    Type="GitHub"; Desc="Detects Doomsday cheat signatures";       URL="https://github.com/MeowTonynoh/MeowDoomsdayFucker/releases/tag/V.1.2" },
    @{ Name="MeowModAnalyzer";    Category="Tonynoh";    Type="Cmd";    Desc="Analyzes mod files for cheats";           Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/MeowTonynoh/MeowModAnalyzer/main/MeowModAnalyzer.ps1')" },
    @{ Name="MeowResolver";       Category="Tonynoh";    Type="GitHub"; Desc="Resolves obfuscated cheat paths";         URL="https://github.com/MeowTonynoh/MeowResolver/releases/tag/MeowResolver" },
    @{ Name="MeowNovowareFucker"; Category="Tonynoh";    Type="GitHub"; Desc="Detects Novoware cheat traces";           URL="https://github.com/MeowTonynoh/MeowNovowareFucker/releases/tag/V1" },
    @{ Name="MeowImportsChecker"; Category="Tonynoh";    Type="GitHub"; Desc="Checks DLL imports for cheat indicators"; URL="https://github.com/MeowTonynoh/MeowImportsChecker/releases/tag/MeowImportsChecker" },
    @{ Name="PSHunter";           Category="Praiselily"; Type="GitHub"; Desc="Hunts suspicious PowerShell activity";    URL="https://github.com/praiselily/PSHunter/releases/tag/Built" },
    @{ Name="AltDetector";        Category="Praiselily"; Type="GitHub"; Desc="Detects alternate/secondary accounts";    URL="https://github.com/praiselily/AltDetector/releases/tag/Detector" },
    @{ Name="WeHateFakers";       Category="Praiselily"; Type="Cmd";    Desc="Checks hotspot/VPN connection logs";      Command="iwr https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1 | iex" },
    @{ Name="CommonDirectories";  Category="Praiselily"; Type="Cmd";    Desc="Lists suspicious common directories";     Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1')" },
    @{ Name="HarddiskConverter";  Category="Praiselily"; Type="Cmd";    Desc="Converts harddisk identifiers";           Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/HarddiskConverter.ps1')" },
    @{ Name="Services";           Category="Praiselily"; Type="Cmd";    Desc="Lists and reviews running services";      Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1')" },
    @{ Name="SignedScheduledTasks";Category="Praiselily";Type="Cmd";    Desc="Checks signed scheduled tasks";           Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Signed-Scheduled-Tasks.ps1')" },
    @{ Name="RL ModAnalyzer";     Category="RedLotus";   Type="GitHub"; Desc="RedLotus mod file analyzer";              URL="https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/tag/RL" },
    @{ Name="RL TaskSentinel";    Category="RedLotus";   Type="GitHub"; Desc="Monitors scheduled tasks for cheats";     URL="https://github.com/ItzIceHere/RedLotus-Task-Sentinel/releases/tag/RL" },
    @{ Name="RL AltChecker";      Category="RedLotus";   Type="GitHub"; Desc="Checks for alternate account evidence";   URL="https://github.com/ItzIceHere/RedLotusAltChecker/releases/tag/RL" },
    @{ Name="WinPrefetchView";    Category="Others";     Type="Web";    Desc="NirSoft prefetch file viewer";            URL="https://www.nirsoft.net/utils/win_prefetch_view.html" },
    @{ Name="ComputerActivityView";Category="Others";    Type="Web";    Desc="NirSoft PC activity timeline viewer";     URL="https://www.nirsoft.net/utils/computer_activity_view.html" },
    @{ Name="AmcacheParser";      Category="Others";     Type="Web";    Desc="Parses Amcache execution artifacts";      URL="https://download.ericzimmermanstools.com/net9/AmcacheParser.zip" },
    @{ Name="JumpListExplorer";   Category="Others";     Type="Web";    Desc="Explores Windows Jump List entries";      URL="https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip" },
    @{ Name="SystemInformer";     Category="Others";     Type="Web";    Desc="Advanced process and kernel inspector";   URL="https://www.systeminformer.com/canary" },
    @{ Name="DIE-engine";         Category="Others";     Type="Web";    Desc="Detects file types and packers";          URL="https://github.com/horsicq/DIE-engine/releases" },
    @{ Name="DQRKIS-FUCKER";      Category="Others";     Type="Cmd";    Desc="Detects DQRKIS cheat signatures";         Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cheesecatlol/DQRKIS-FUCKER/refs/heads/main/DqrkisFucker.ps1')" },
    @{ Name="MacroDetector";      Category="Others";     Type="Cmd";    Desc="Detects macro/automation tool usage";     Command="Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/Nickk196/MacroDetector/refs/heads/main/MacroDetector.ps1')" }
)

# ==============================================================================
# XAML UI
# ==============================================================================
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="CheesySSTool"
    Width="1200" Height="760"
    MinWidth="1200" MinHeight="760"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="MainBg"     Color="#0F0B00"/>
        <SolidColorBrush x:Key="SidebarBg"  Color="#1A1200"/>
        <SolidColorBrush x:Key="CardBg"     Color="#221800"/>
        <SolidColorBrush x:Key="Accent"     Color="#F5C200"/>
        <SolidColorBrush x:Key="AccentDim"  Color="#A07800"/>
        <SolidColorBrush x:Key="TextMain"   Color="#FFF4C8"/>
        <SolidColorBrush x:Key="TextMuted"  Color="#907830"/>
        <SolidColorBrush x:Key="ConsoleBg"  Color="#060400"/>

        <Style x:Key="SideBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="14,0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#2A1E00"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SSBtn" TargetType="Button">
            <Setter Property="Background" Value="#1E1600"/>
            <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="4" BorderBrush="#3D2E00" BorderThickness="1">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#F5C200"/>
                                <Setter Property="Foreground" Value="#0F0B00"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GearBtn" TargetType="Button">
            <Setter Property="Background" Value="#1E1600"/>
            <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="0,0,0,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="4" BorderBrush="#3D2E00" BorderThickness="1">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#2A1E00"/>
                                <Setter Property="Foreground" Value="{StaticResource Accent}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="TitleBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
            <Setter Property="Width" Value="40"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#33F5C200"/>
                                <Setter Property="Foreground" Value="#F5C200"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource MainBg}" BorderBrush="#3D2E00" BorderThickness="1" CornerRadius="8">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="42"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Border Grid.Row="0" Background="{StaticResource SidebarBg}" CornerRadius="8,8,0,0">
                <Grid Margin="16,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="=^.^=" FontSize="14" FontWeight="Bold" Foreground="{StaticResource Accent}" FontFamily="Consolas"/>
                        <TextBlock Text=" CheesySSTool" FontSize="14" FontWeight="SemiBold" Foreground="{StaticResource TextMain}"/>
                        <TextBlock Text=" - by cheese cat" FontSize="11" Foreground="{StaticResource TextMuted}" VerticalAlignment="Center" Margin="4,0,0,0"/>
                    </StackPanel>
                    <StackPanel Grid.Column="1" Orientation="Horizontal">
                        <Button x:Name="MinBtn"   Style="{StaticResource TitleBtn}" Content="_"/>
                        <Button x:Name="MaxBtn"   Style="{StaticResource TitleBtn}" Content="&#x25A1;"/>
                        <Button x:Name="CloseBtn" Style="{StaticResource TitleBtn}" Content="X"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Body -->
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="210"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Sidebar -->
                <Border Grid.Column="0" Background="{StaticResource SidebarBg}" BorderBrush="#3D2E00" BorderThickness="0,0,1,0">
                    <StackPanel Margin="10,14,10,14">

                        <!-- Cat ASCII art -->
                        <Border Background="#0A0700" CornerRadius="6" Margin="0,0,0,14" Padding="0,10">
                            <TextBlock x:Name="CatBlock"
                                Text=" /\_____/\ &#x0a; / ^ ^ \ &#x0a; ( = w = )&#x0a; \ (___) / &#x0a; / | | \ &#x0a; (__| |__)"
                                FontFamily="Consolas" FontSize="9"
                                Foreground="{StaticResource Accent}"
                                HorizontalAlignment="Center"
                                TextAlignment="Left"
                                xml:space="preserve"/>
                        </Border>

                        <!-- SCREENSHARE SECTION -->
                        <TextBlock Text="SCREENSHARE" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextMuted}" Margin="4,0,0,6"/>
                        <Button x:Name="FastSSBtn"   Content="&#x26A1; Fast SS"   Style="{StaticResource SSBtn}"/>
                        <Button x:Name="NormalSSBtn" Content="&#x1F50D; Normal SS" Style="{StaticResource SSBtn}"/>
                        <Button x:Name="FullSSBtn"   Content="&#x1F6E1; Full SS"   Style="{StaticResource SSBtn}"/>

                        <Separator Background="#3D2E00" Margin="0,10,0,10"/>

                        <!-- ACTIONS SECTION -->
                        <TextBlock Text="ACTIONS" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextMuted}" Margin="4,0,0,6"/>
                        <Button x:Name="OpenFolderBtn" Content=" Open Install Folder"    Style="{StaticResource SideBtn}"/>
                        <Button x:Name="ClearCacheBtn" Content=" Clear Downloaded Files" Style="{StaticResource SideBtn}"/>
                        <Button x:Name="OpenCmdBtn"    Content=" Open CMD"               Style="{StaticResource SideBtn}"/>

                        <Separator Background="#3D2E00" Margin="0,10,0,10"/>

                        <!-- CREDITS -->
                        <TextBlock Text="CREDITS" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextMuted}" Margin="4,0,0,6"/>
                        <TextBlock Text="Made by cheese cat" FontSize="11" FontWeight="SemiBold" Foreground="{StaticResource TextMain}" Margin="4,2,0,4"/>
                        <TextBlock Text="Discord: cheese_cat0"   FontSize="10" Foreground="{StaticResource TextMuted}" TextWrapping="Wrap" Margin="4,1,0,0"/>
                        <TextBlock Text="GitHub: cheesecatlol"   FontSize="10" Foreground="{StaticResource TextMuted}" TextWrapping="Wrap" Margin="4,1,0,0"/>

                        <Separator Background="#3D2E00" Margin="0,10,0,10"/>

                        <TextBlock x:Name="InstPathBlock" Text="" FontSize="9" Foreground="#5A4010" TextWrapping="Wrap" Margin="4,0,0,6"/>

                        <!-- SETTINGS gear at bottom -->
                        <Button x:Name="SettingsBtn" Content="&#x2699;  Settings" Style="{StaticResource GearBtn}"/>
                    </StackPanel>
                </Border>

                <!-- Main Panel -->
                <Grid Grid.Column="1" Margin="16,14,16,14">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="6"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="6"/>
                        <RowDefinition Height="220"/>
                    </Grid.RowDefinitions>

                    <!-- Status card -->
                    <Border Grid.Row="0" Background="{StaticResource CardBg}" CornerRadius="6" Padding="16,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel>
                                <TextBlock x:Name="StatusTitle" Text="Ready"  FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource TextMain}"/>
                                <TextBlock x:Name="StatusSub"   Text="Select a tool to launch or download it." FontSize="11" Foreground="{StaticResource TextMuted}"/>
                            </StackPanel>
                            <Border Grid.Column="1" Background="#1A3D1A" CornerRadius="4" Padding="10,4" VerticalAlignment="Center">
                                <TextBlock x:Name="StatusBadge" Text="IDLE" FontSize="12" FontWeight="Bold" Foreground="{StaticResource Accent}"/>
                            </Border>
                        </Grid>
                    </Border>

                    <!-- Tab control -->
                    <Border Grid.Row="2" Background="{StaticResource CardBg}" CornerRadius="6">
                        <TabControl x:Name="ToolsTab" Background="Transparent" BorderThickness="0" Padding="0">
                            <TabControl.Resources>
                                <Style TargetType="TabItem">
                                    <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
                                    <Setter Property="FontSize"   Value="11"/>
                                    <Setter Property="Padding"    Value="12,6"/>
                                    <Setter Property="Cursor"     Value="Hand"/>
                                    <Setter Property="Template">
                                        <Setter.Value>
                                            <ControlTemplate TargetType="TabItem">
                                                <Border x:Name="TabBorder" Background="Transparent" CornerRadius="4" Margin="3,4,3,0" Padding="12,5">
                                                    <ContentPresenter ContentSource="Header" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                                </Border>
                                                <ControlTemplate.Triggers>
                                                    <Trigger Property="IsSelected" Value="True">
                                                        <Setter TargetName="TabBorder" Property="Background" Value="{StaticResource Accent}"/>
                                                        <Setter Property="Foreground" Value="#0F0B00"/>
                                                    </Trigger>
                                                    <MultiTrigger>
                                                        <MultiTrigger.Conditions>
                                                            <Condition Property="IsMouseOver" Value="True"/>
                                                            <Condition Property="IsSelected"  Value="False"/>
                                                        </MultiTrigger.Conditions>
                                                        <Setter TargetName="TabBorder" Property="Background" Value="#2A1E00"/>
                                                        <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
                                                    </MultiTrigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Setter.Value>
                                    </Setter>
                                </Style>
                            </TabControl.Resources>
                        </TabControl>
                    </Border>

                    <!-- Console -->
                    <Border Grid.Row="4" Background="{StaticResource ConsoleBg}" CornerRadius="6" Padding="12,8">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <TextBlock Text="ACTIVITY CONSOLE" FontSize="9" FontWeight="Bold" Foreground="#5A4010" FontFamily="Consolas" Margin="0,0,0,4"/>
                            <TextBox x:Name="LogBox"
                                Grid.Row="1"
                                Background="Transparent"
                                Foreground="{StaticResource Accent}"
                                BorderThickness="0"
                                FontFamily="Consolas"
                                FontSize="11"
                                IsReadOnly="True"
                                VerticalScrollBarVisibility="Auto"
                                TextWrapping="Wrap"/>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# ==============================================================================
# LOAD WINDOW
# ==============================================================================
$reader  = New-Object System.Xml.XmlNodeReader $xaml
$window  = [Windows.Markup.XamlReader]::Load($reader)

$MinBtn        = $window.FindName("MinBtn")
$MaxBtn        = $window.FindName("MaxBtn")
$CloseBtn      = $window.FindName("CloseBtn")
$StatusTitle   = $window.FindName("StatusTitle")
$StatusSub     = $window.FindName("StatusSub")
$StatusBadge   = $window.FindName("StatusBadge")
$LogBox        = $window.FindName("LogBox")
$ToolsTab      = $window.FindName("ToolsTab")
$OpenFolderBtn = $window.FindName("OpenFolderBtn")
$ClearCacheBtn = $window.FindName("ClearCacheBtn")
$OpenCmdBtn    = $window.FindName("OpenCmdBtn")
$CatBlock      = $window.FindName("CatBlock")
$InstPathBlock = $window.FindName("InstPathBlock")
$FastSSBtn     = $window.FindName("FastSSBtn")
$NormalSSBtn   = $window.FindName("NormalSSBtn")
$FullSSBtn     = $window.FindName("FullSSBtn")
$SettingsBtn   = $window.FindName("SettingsBtn")

$InstPathBlock.Text = "Install path:`n$installDir"

# ==============================================================================
# HELPERS
# ==============================================================================
function Write-Log {
    param([string]$msg)
    $time = Get-Date -Format "HH:mm:ss"
    $LogBox.Dispatcher.Invoke([Action]{
        $LogBox.AppendText("[$time] $msg`r`n")
        $LogBox.ScrollToEnd()
    })
}

function Set-Status {
    param($title, $sub, $badge = "BUSY")
    $window.Dispatcher.Invoke([Action]{
        $StatusTitle.Text = $title
        $StatusSub.Text   = $sub
        $StatusBadge.Text = $badge
    })
}

function Start-AppOrScript {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [string]$WorkingDirectory
    )
    if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path -Parent $Path }
    $extension  = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    $quotedPath = '"' + $Path + '"'
    switch ($extension) {
        ".cmd" { Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $quotedPath -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
        ".bat" { Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $quotedPath -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
        default { Start-Process -FilePath $Path -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
    }
}

function Start-CmdToolCommand {
    param([Parameter(Mandatory=$true)][string]$Command)
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Command))
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k", "powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCommand" -WindowStyle Normal
}

function Save-UrlToFile {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$OutFile
    )
    $tempFile = "$OutFile.download"
    if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue }
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "CheesySSTool")
    try {
        $client.DownloadFile($Uri, $tempFile)
        if (Test-Path -LiteralPath $OutFile) { Remove-Item -LiteralPath $OutFile -Force -ErrorAction Stop }
        Move-Item -LiteralPath $tempFile -Destination $OutFile -Force -ErrorAction Stop
    } finally {
        $client.Dispose()
        if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue }
    }
}

function Start-DownloadedTool {
    param(
        [Parameter(Mandatory=$true)][string]$Directory,
        [string]$PreferredFile
    )
    if ($PreferredFile -and (Test-Path -LiteralPath $PreferredFile) -and ($PreferredFile -notmatch "\.zip$")) {
        Write-Log "Launching $(Split-Path -Leaf $PreferredFile)"
        Start-AppOrScript -Path $PreferredFile -WorkingDirectory (Split-Path -Parent $PreferredFile)
        return $true
    }
    $launchable = Get-ChildItem -Path $Directory -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match "^\.(exe|cmd|bat)$" } |
        Sort-Object @{ Expression = { if ($_.Extension -eq ".exe") { 0 } else { 1 } } }, FullName |
        Select-Object -First 1
    if ($launchable) {
        Write-Log "Launching $($launchable.Name)"
        Start-AppOrScript -Path $launchable.FullName -WorkingDirectory $launchable.DirectoryName
        return $true
    }
    Write-Log "No .exe, .cmd, or .bat found - opening folder."
    Start-Process -FilePath explorer.exe -ArgumentList "`"$Directory`""
    return $false
}

function Get-GitHubAssetUrl {
    param([string]$ReleaseUrl)
    if ($ReleaseUrl -match "github\.com/([^/]+)/([^/]+)/releases/tag/(.+)$") {
        $user = $Matches[1]
        $repo = $Matches[2]
        $tag  = [Uri]::EscapeDataString(([Uri]::UnescapeDataString($Matches[3])).TrimEnd("/"))
        $api  = "https://api.github.com/repos/$user/$repo/releases/tags/$tag"
        try {
            $rel   = Invoke-RestMethod -Uri $api -Headers @{"User-Agent"="CheesySSTool"} -ErrorAction Stop
            $asset = $rel.assets | Where-Object { $_.name -match "\.(exe|zip|cmd|bat)$" } | Select-Object -First 1
            if ($asset) { return @{ url=$asset.browser_download_url; name=$asset.name } }
        } catch {
            Write-Log "GitHub lookup failed: $($_.Exception.Message)"
        }
    }
    return $null
}

function Invoke-ToolDownloadAndRun {
    param($tool)
    $name = $tool.Name
    $cat  = $tool.Category
    Write-Log "Fetching asset info for $name..."
    $asset = Get-GitHubAssetUrl -ReleaseUrl $tool.URL
    if (-not $asset) {
        Write-Log "No .exe/.zip/.cmd/.bat asset found for $name - opening browser."
        Set-Status "Ready" "No asset found, opened GitHub." "IDLE"
        Start-Process $tool.URL
        return
    }
    $destDir  = "$installDir\$cat\$name"
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    $destFile = "$destDir\$($asset.name)"
    if (Test-Path $destFile) {
        Write-Log "Cached: $($asset.name) - skipping download."
    } else {
        Write-Log "Downloading $($asset.name)..."
        try {
            Save-UrlToFile -Uri $asset.url -OutFile $destFile
            Write-Log "Download complete: $($asset.name)"
        } catch {
            $err = $_
            Write-Log "Download failed: $err"
            Set-Status "Error" "Download failed for $name." "ERR"
            Start-Process $tool.URL
            return
        }
    }
    if ($asset.name -match "\.zip$") {
        Write-Log "Extracting $($asset.name)..."
        try {
            Expand-Archive -Path $destFile -DestinationPath $destDir -Force -ErrorAction Stop
        } catch {
            Write-Log "Extract failed: $($_.Exception.Message)"
            Set-Status "Error" "Could not extract $name." "ERR"
            Start-Process -FilePath explorer.exe -ArgumentList "`"$destDir`""
            return
        }
        [void](Start-DownloadedTool -Directory $destDir)
    } else {
        [void](Start-DownloadedTool -Directory $destDir -PreferredFile $destFile)
    }
    Set-Status "Ready" "$name launched successfully." "IDLE"
}

function Invoke-WebToolDownload {
    param($tool)
    $name = $tool.Name
    $url  = $tool.URL
    if ($url -match "\.(zip|exe|cmd|bat)$") {
        $fileName = ($url -split "/")[-1]
        $destDir  = "$installDir\Others\$name"
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        $destFile = "$destDir\$fileName"
        if (Test-Path $destFile) {
            Write-Log "Cached: $fileName - skipping download."
        } else {
            Write-Log "Downloading $fileName..."
            try {
                Save-UrlToFile -Uri $url -OutFile $destFile
                Write-Log "Download complete: $fileName"
            } catch {
                $err = $_
                Write-Log "Download failed: $err"
                Set-Status "Error" "Download failed." "ERR"
                Start-Process $url
                return
            }
        }
        if ($fileName -match "\.zip$") {
            try {
                Expand-Archive -Path $destFile -DestinationPath $destDir -Force -ErrorAction Stop
            } catch {
                Write-Log "Extract failed: $($_.Exception.Message)"
                Set-Status "Error" "Could not extract $name." "ERR"
                Start-Process -FilePath explorer.exe -ArgumentList "`"$destDir`""
                return
            }
            [void](Start-DownloadedTool -Directory $destDir)
        } else {
            [void](Start-DownloadedTool -Directory $destDir -PreferredFile $destFile)
        }
        Set-Status "Ready" "$name launched." "IDLE"
    } else {
        Write-Log "Opening browser for $name"
        Set-Status "Browser" "Opening $name in browser." "IDLE"
        Start-Process $url
    }
}

# ==============================================================================
# SCREENSHARE MODE CONFIG
# Defines which tools get launched for each SS mode (Fast / Normal / Full).
# Users can customise this list via Settings.
# ==============================================================================

# Default tool sets per mode — names must match $ToolData entries
$script:SSConfig = @{
    Fast   = @("PrefetchView","BAMReveal","process-parser","prefetch-parser")
    Normal = @("PrefetchView","BAMReveal","StringsParser","JournalParser","process-parser",
               "prefetch-parser","PathsParser","JournalTrace","pcasvc-executed")
    Full   = @("PrefetchView","BAMReveal","StringsParser","Fileless","DPS-Analyzer",
               "UserAssistView","JournalParser","InjGen","USBDetector","PFTrace",
               "CheckDeletedUSN","JARParser","BAM-parser","PathsParser","JournalTrace",
               "KernelLiveDumpTool","BamDeletedKeys","pcasvc-executed","process-parser",
               "prefetch-parser","ActivitiesCache","PSHunter","AltDetector")
}

# SS display info shown in the status bar
$script:SSInfo = @{
    Fast   = "Fast SS — launches core tools only (quick check)."
    Normal = "Normal SS — launches standard tool set for a thorough review."
    Full   = "Full SS — launches ALL tools for a deep/comprehensive review."
}

function Invoke-SSDownloadOnly {
    # Downloads a single tool into $destDir without launching anything.
    # Returns $true on success, $false on failure.
    param($tool, [string]$destDir)
    $name = $tool.Name

    try {
        switch ($tool.Type) {

            "GitHub" {
                $asset = Get-GitHubAssetUrl -ReleaseUrl $tool.URL
                if (-not $asset) {
                    Write-Log "  [SKIP] $name — no downloadable asset found on GitHub."
                    return $false
                }
                $toolDir  = "$destDir\$name"
                if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir -Force | Out-Null }
                $destFile = "$toolDir\$($asset.name)"
                if (Test-Path $destFile) {
                    Write-Log "  [CACHED] $name — already downloaded, skipping."
                } else {
                    Write-Log "  [DL] $name — $($asset.name)"
                    Save-UrlToFile -Uri $asset.url -OutFile $destFile
                    Write-Log "  [OK] $name — download complete."
                }
                if ($asset.name -match "\.zip$") {
                    Expand-Archive -Path $destFile -DestinationPath $toolDir -Force -ErrorAction Stop
                    Write-Log "  [UNZIP] $name — extracted."
                }
                return $true
            }

            "Web" {
                $url = $tool.URL
                if ($url -match "\.(zip|exe|cmd|bat)$") {
                    $fileName = ($url -split "/")[-1]
                    $toolDir  = "$destDir\$name"
                    if (-not (Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir -Force | Out-Null }
                    $destFile = "$toolDir\$fileName"
                    if (Test-Path $destFile) {
                        Write-Log "  [CACHED] $name — already downloaded, skipping."
                    } else {
                        Write-Log "  [DL] $name — $fileName"
                        Save-UrlToFile -Uri $url -OutFile $destFile
                        Write-Log "  [OK] $name — download complete."
                    }
                    if ($fileName -match "\.zip$") {
                        Expand-Archive -Path $destFile -DestinationPath $toolDir -Force -ErrorAction Stop
                        Write-Log "  [UNZIP] $name — extracted."
                    }
                    return $true
                } else {
                    Write-Log "  [SKIP] $name — web link only, nothing to download."
                    return $false
                }
            }

            "Cmd" {
                # Cmd tools are PowerShell scripts that run remotely — skip in SS mode.
                Write-Log "  [SKIP] $name — command-line tool, not downloaded in SS mode."
                return $false
            }
        }
    } catch {
        Write-Log "  [ERR] $name — $_"
        return $false
    }
    return $false
}

function Invoke-SSMode {
    param([string]$Mode)
    $toolNames = $script:SSConfig[$Mode]
    $info      = $script:SSInfo[$Mode]

    $ssFolder = "$installDir\${Mode}SS"
    New-Item -ItemType Directory -Path $ssFolder -Force | Out-Null

    Write-Log "=== $Mode SS — downloading $($toolNames.Count) tools to: $ssFolder ==="
    Set-Status "$Mode SS" "Downloading tools... please wait." "BUSY"

    $ok   = 0
    $skip = 0
    $fail = 0

    foreach ($name in $toolNames) {
        $tData = $ToolData | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if (-not $tData) {
            Write-Log "  [MISS] '$name' not in tool list — check SSConfig."
            $fail++
            continue
        }
        $result = Invoke-SSDownloadOnly -tool $tData -destDir $ssFolder
        if ($result) { $ok++ } else { $skip++ }
    }

    Write-Log "=== $Mode SS complete — $ok downloaded, $skip skipped, $fail missing ==="
    Write-Log "    Folder: $ssFolder"
    Set-Status "Ready" "$Mode SS done — $ok tools saved to ${Mode}SS folder." "IDLE"

    # Open the folder so the reviewer can see everything
    Start-Process -FilePath explorer.exe -ArgumentList "`"$ssFolder`""
}

# ==============================================================================
# SETTINGS WINDOW
# ==============================================================================
function Show-SettingsWindow {
    [xml]$settingsXaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Settings"
    Width="560" Height="620"
    WindowStartupLocation="CenterOwner"
    ResizeMode="CanResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI">
    <Border Background="#0F0B00" BorderBrush="#3D2E00" BorderThickness="1" CornerRadius="8">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="44"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Title bar -->
            <Border Grid.Row="0" Background="#1A1200" CornerRadius="8,8,0,0">
                <Grid Margin="16,0">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="&#x2699;" FontSize="15" Foreground="#F5C200" VerticalAlignment="Center" Margin="0,0,8,0"/>
                        <TextBlock Text="Settings" FontSize="13" FontWeight="SemiBold" Foreground="#FFF4C8" VerticalAlignment="Center"/>
                    </StackPanel>
                    <Button x:Name="CloseSettingsBtn" HorizontalAlignment="Right"
                        Content="X" Width="36" Height="28" Cursor="Hand"
                        Background="Transparent" Foreground="#907830" BorderThickness="0" FontSize="11"/>
                </Grid>
            </Border>

            <!-- Settings body — two-column tab layout -->
            <Grid Grid.Row="1" Margin="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="140"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Left nav -->
                <Border Background="#1A1200" BorderBrush="#3D2E00" BorderThickness="0,0,1,0">
                    <StackPanel Margin="8,12,8,12">
                        <Button x:Name="TabBtnSS"       Content="&#x1F50D;  Screenshare" Tag="ss"       Height="34" Margin="0,0,0,3" Cursor="Hand" Background="#F5C200" Foreground="#0F0B00" FontSize="11" FontWeight="SemiBold" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                        <Button x:Name="TabBtnTools"    Content="&#x1F4E6;  Tools"        Tag="tools"    Height="34" Margin="0,0,0,3" Cursor="Hand" Background="Transparent" Foreground="#FFF4C8" FontSize="11" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                        <Button x:Name="TabBtnDownload" Content="&#x2B07;  Downloads"    Tag="download" Height="34" Margin="0,0,0,3" Cursor="Hand" Background="Transparent" Foreground="#FFF4C8" FontSize="11" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                        <Button x:Name="TabBtnUI"       Content="&#x1F3A8;  Appearance"  Tag="ui"       Height="34" Margin="0,0,0,3" Cursor="Hand" Background="Transparent" Foreground="#FFF4C8" FontSize="11" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                        <Button x:Name="TabBtnAdvanced" Content="&#x26A0;  Advanced"     Tag="advanced" Height="34" Margin="0,0,0,3" Cursor="Hand" Background="Transparent" Foreground="#FFF4C8" FontSize="11" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                        <Button x:Name="TabBtnAbout"    Content="&#x2139;  About"        Tag="about"    Height="34" Margin="0,0,0,3" Cursor="Hand" Background="Transparent" Foreground="#FFF4C8" FontSize="11" BorderThickness="0" HorizontalContentAlignment="Left" Padding="10,0"/>
                    </StackPanel>
                </Border>

                <!-- Right content panels -->
                <ScrollViewer Grid.Column="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <Grid>
                        <!-- ── SCREENSHARE TAB ── -->
                        <StackPanel x:Name="PanelSS" Margin="18,14,18,14" Visibility="Visible">
                            <TextBlock Text="SCREENSHARE MODES" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,10"/>

                            <Border Background="#1A1200" CornerRadius="6" Padding="12,10" Margin="0,0,0,8">
                                <StackPanel>
                                    <TextBlock Text="&#x26A1; Fast SS" FontSize="11" FontWeight="Bold" Foreground="#F5C200" Margin="0,0,0,4"/>
                                    <TextBlock TextWrapping="Wrap" FontSize="10" Foreground="#907830"
                                        Text="Quick check — launches only the most essential tools. Use when you need a fast result without going deep."/>
                                    <Separator Background="#3D2E00" Margin="0,8,0,8"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Stagger delay between tool launches (ms)" Foreground="#FFF4C8" FontSize="10" VerticalAlignment="Center"/>
                                        <TextBox x:Name="FastDelayBox" Grid.Column="1" Text="400" Width="60" Height="24" Background="#0F0B00" Foreground="#FFF4C8" BorderBrush="#3D2E00" BorderThickness="1" Padding="4,2" FontSize="10"/>
                                    </Grid>
                                </StackPanel>
                            </Border>

                            <Border Background="#1A1200" CornerRadius="6" Padding="12,10" Margin="0,0,0,8">
                                <StackPanel>
                                    <TextBlock Text="&#x1F50D; Normal SS" FontSize="11" FontWeight="Bold" Foreground="#F5C200" Margin="0,0,0,4"/>
                                    <TextBlock TextWrapping="Wrap" FontSize="10" Foreground="#907830"
                                        Text="Standard check — launches the core + journal/path tools. The go-to mode for most screenshare reviews."/>
                                    <Separator Background="#3D2E00" Margin="0,8,0,8"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Stagger delay between tool launches (ms)" Foreground="#FFF4C8" FontSize="10" VerticalAlignment="Center"/>
                                        <TextBox x:Name="NormalDelayBox" Grid.Column="1" Text="400" Width="60" Height="24" Background="#0F0B00" Foreground="#FFF4C8" BorderBrush="#3D2E00" BorderThickness="1" Padding="4,2" FontSize="10"/>
                                    </Grid>
                                </StackPanel>
                            </Border>

                            <Border Background="#1A1200" CornerRadius="6" Padding="12,10" Margin="0,0,0,8">
                                <StackPanel>
                                    <TextBlock Text="&#x1F6E1; Full SS" FontSize="11" FontWeight="Bold" Foreground="#F5C200" Margin="0,0,0,4"/>
                                    <TextBlock TextWrapping="Wrap" FontSize="10" Foreground="#907830"
                                        Text="Deep check — launches every tool available. Use for high-priority or suspected cheaters requiring maximum coverage."/>
                                    <Separator Background="#3D2E00" Margin="0,8,0,8"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Stagger delay between tool launches (ms)" Foreground="#FFF4C8" FontSize="10" VerticalAlignment="Center"/>
                                        <TextBox x:Name="FullDelayBox" Grid.Column="1" Text="400" Width="60" Height="24" Background="#0F0B00" Foreground="#FFF4C8" BorderBrush="#3D2E00" BorderThickness="1" Padding="4,2" FontSize="10"/>
                                    </Grid>
                                </StackPanel>
                            </Border>

                            <Separator Background="#3D2E00" Margin="0,4,0,10"/>
                            <TextBlock Text="BEHAVIOUR" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,8"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Skip already-running tools" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Don't re-launch a tool if its process is already open" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="SkipRunningChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Log each tool launch to console" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Prints a line per tool in the activity console" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="LogLaunchChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Show summary popup after SS completes" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Displays a count of launched / failed tools" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="SummaryPopupChk" Grid.Column="1" IsChecked="False" VerticalAlignment="Center"/>
                            </Grid>
                        </StackPanel>

                        <!-- ── TOOLS TAB ── -->
                        <StackPanel x:Name="PanelTools" Margin="18,14,18,14" Visibility="Collapsed">
                            <TextBlock Text="TOOL BEHAVIOUR" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,10"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Auto-extract ZIP downloads" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Automatically unzip after download completes" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="AutoExtractChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Auto-launch after download" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Run the tool immediately after it finishes downloading" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="AutoLaunchChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Open browser as fallback" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="If no asset is found, open the GitHub release page" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="BrowserFallbackChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Run Cmd tools in new window" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Opens a CMD window for PowerShell-based tools" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="NewWindowCmdChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Separator Background="#3D2E00" Margin="0,8,0,10"/>
                            <TextBlock Text="INSTALL PATH" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,8"/>
                            <Border Background="#1A1200" CornerRadius="4" Padding="10,8">
                                <StackPanel>
                                    <TextBlock x:Name="InstallPathLabel" Text="" FontSize="10" Foreground="#FFF4C8" TextWrapping="Wrap"/>
                                    <StackPanel Orientation="Horizontal" Margin="0,6,0,0">
                                        <Button x:Name="OpenInstallDirBtn" Content="Open Folder" Height="26" Padding="10,0" Margin="0,0,6,0"
                                            Background="#2A1E00" Foreground="#FFF4C8" FontSize="10" Cursor="Hand" BorderBrush="#3D2E00" BorderThickness="1"/>
                                        <Button x:Name="ClearCacheBtn2" Content="Clear Cache" Height="26" Padding="10,0"
                                            Background="#2A1E00" Foreground="#F5C200" FontSize="10" Cursor="Hand" BorderBrush="#3D2E00" BorderThickness="1"/>
                                    </StackPanel>
                                </StackPanel>
                            </Border>
                        </StackPanel>

                        <!-- ── DOWNLOADS TAB ── -->
                        <StackPanel x:Name="PanelDownload" Margin="18,14,18,14" Visibility="Collapsed">
                            <TextBlock Text="DOWNLOAD SETTINGS" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,10"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Use cached files (skip re-download)" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="If a file already exists locally, skip downloading" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="UseCacheChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Show download progress in console" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Log download start / complete messages" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="DownloadLogChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Verify file exists after download" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Check that the file isn't empty before launching" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="VerifyDownloadChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Separator Background="#3D2E00" Margin="0,8,0,10"/>
                            <TextBlock Text="NETWORK" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,8"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="60"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Download timeout (seconds)" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Max time before a download is considered failed" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <TextBox x:Name="TimeoutBox" Grid.Column="1" Text="30" Height="24" Background="#0F0B00" Foreground="#FFF4C8" BorderBrush="#3D2E00" BorderThickness="1" Padding="4,2" FontSize="10" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Force TLS 1.2 for all requests" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Required for GitHub downloads on older systems" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="ForceTlsChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>
                        </StackPanel>

                        <!-- ── APPEARANCE TAB ── -->
                        <StackPanel x:Name="PanelUI" Margin="18,14,18,14" Visibility="Collapsed">
                            <TextBlock Text="APPEARANCE" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,10"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Animate cat ASCII art" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Blink animation on the cat in the sidebar" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="CatAnimChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Show install path in sidebar" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Displays the download folder path at the bottom of the sidebar" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="ShowPathChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Show tool type badge colour" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Colour-code buttons by type (GitHub / Cmd / Web)" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="TypeBadgeChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Separator Background="#3D2E00" Margin="0,8,0,10"/>
                            <TextBlock Text="CONSOLE" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,8"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Auto-scroll console to latest entry" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Keep the most recent log line visible" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="AutoScrollChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="60"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Max console lines" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Trim old lines when limit is reached (0 = unlimited)" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <TextBox x:Name="MaxConsoleLines" Grid.Column="1" Text="200" Height="24" Background="#0F0B00" Foreground="#FFF4C8" BorderBrush="#3D2E00" BorderThickness="1" Padding="4,2" FontSize="10" VerticalAlignment="Center"/>
                            </Grid>
                        </StackPanel>

                        <!-- ── ADVANCED TAB ── -->
                        <StackPanel x:Name="PanelAdvanced" Margin="18,14,18,14" Visibility="Collapsed">
                            <TextBlock Text="ADVANCED" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,10"/>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Run tools as administrator" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Launch tools with elevated privileges (UAC prompt)" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="RunAsAdminChk" Grid.Column="1" IsChecked="False" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Keep CMD windows open after tool exits" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Use /k instead of /c so the window stays for reading output" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="KeepCmdOpenChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Suppress PowerShell profile on launch" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Adds -NoProfile flag to all PS1 tool launches" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="NoProfileChk" Grid.Column="1" IsChecked="True" VerticalAlignment="Center"/>
                            </Grid>

                            <Grid Margin="0,0,0,8">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Text="Error details in console" Foreground="#FFF4C8" FontSize="11"/>
                                    <TextBlock Text="Print full exception info when a tool fails" Foreground="#907830" FontSize="9"/>
                                </StackPanel>
                                <CheckBox x:Name="VerboseErrorChk" Grid.Column="1" IsChecked="False" VerticalAlignment="Center"/>
                            </Grid>

                            <Separator Background="#3D2E00" Margin="0,8,0,10"/>
                            <TextBlock Text="DANGER ZONE" FontSize="9" FontWeight="Bold" Foreground="#F05050" Margin="0,0,0,8"/>
                            <Border Background="#1A0000" CornerRadius="4" Padding="10,8" BorderBrush="#5A1010" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="Reset all settings to defaults" Foreground="#FFF4C8" FontSize="11" Margin="0,0,0,6"/>
                                    <Button x:Name="ResetSettingsBtn" Content="Reset Settings" Height="26" Padding="10,0" HorizontalAlignment="Left"
                                        Background="#3A1010" Foreground="#F05050" FontSize="10" Cursor="Hand" BorderBrush="#5A1010" BorderThickness="1"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>

                        <!-- ── ABOUT TAB ── -->
                        <StackPanel x:Name="PanelAbout" Margin="18,14,18,14" Visibility="Collapsed">
                            <Border Background="#1A1200" CornerRadius="6" Padding="14,12" Margin="0,0,0,12">
                                <StackPanel>
                                    <TextBlock Text="=^.^= CheesySSTool" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="#F5C200" Margin="0,0,0,4"/>
                                    <TextBlock Text="Anti-cheat screenshare review toolkit" FontSize="10" Foreground="#907830"/>
                                    <Separator Background="#3D2E00" Margin="0,10,0,10"/>
                                    <Grid Margin="0,0,0,4">
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="90"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Author" Foreground="#907830" FontSize="10"/>
                                        <TextBlock Grid.Column="1" Text="cheese cat" Foreground="#FFF4C8" FontSize="10"/>
                                    </Grid>
                                    <Grid Margin="0,0,0,4">
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="90"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Discord" Foreground="#907830" FontSize="10"/>
                                        <TextBlock Grid.Column="1" Text="cheese_cat0" Foreground="#FFF4C8" FontSize="10"/>
                                    </Grid>
                                    <Grid Margin="0,0,0,4">
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="90"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="GitHub" Foreground="#907830" FontSize="10"/>
                                        <TextBlock Grid.Column="1" Text="cheesecatlol" Foreground="#FFF4C8" FontSize="10"/>
                                    </Grid>
                                </StackPanel>
                            </Border>
                            <TextBlock Text="INCLUDED TOOL AUTHORS" FontSize="9" FontWeight="Bold" Foreground="#907830" Margin="0,0,0,8"/>
                            <Border Background="#1A1200" CornerRadius="4" Padding="10,8">
                                <StackPanel>
                                    <TextBlock Text="Orbdiff • Spokwn • MeowTonynoh" Foreground="#FFF4C8" FontSize="10" Margin="0,0,0,3"/>
                                    <TextBlock Text="Praiselily • ItzIceHere (RedLotus)" Foreground="#FFF4C8" FontSize="10" Margin="0,0,0,3"/>
                                    <TextBlock Text="NirSoft • Eric Zimmerman • Nickk196" Foreground="#FFF4C8" FontSize="10"/>
                                </StackPanel>
                            </Border>
                            <Separator Background="#3D2E00" Margin="0,12,0,10"/>
                            <TextBlock Text="This tool downloads and launches third-party tools. Always review what you run." FontSize="9" Foreground="#5A4010" TextWrapping="Wrap"/>
                        </StackPanel>
                    </Grid>
                </ScrollViewer>
            </Grid>

            <!-- Footer -->
            <Border Grid.Row="2" Background="#1A1200" CornerRadius="0,0,8,8" Padding="16,10">
                <Grid>
                    <TextBlock x:Name="SettingsHint" Text="Changes apply immediately." FontSize="9" Foreground="#5A4010" VerticalAlignment="Center"/>
                    <Button x:Name="SaveCloseBtn" Content="Save &amp; Close" HorizontalAlignment="Right"
                        Height="30" Padding="16,0" Background="#F5C200" Foreground="#0F0B00"
                        FontSize="11" FontWeight="SemiBold" Cursor="Hand" BorderThickness="0"/>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

    $sr       = New-Object System.Xml.XmlNodeReader $settingsXaml
    $sw       = [Windows.Markup.XamlReader]::Load($sr)
    $sw.Owner = $window

    $sw.Add_MouseLeftButtonDown({ try { $sw.DragMove() } catch {} })
    $sw.FindName("CloseSettingsBtn").Add_Click({ $sw.Close() })
    $sw.FindName("SaveCloseBtn").Add_Click({ $sw.Close() })
    $sw.FindName("InstallPathLabel").Text = $installDir

    # Reset button
    $sw.FindName("ResetSettingsBtn").Add_Click({
        [System.Windows.MessageBox]::Show("Settings reset to defaults.", "CheesySSTool", "OK", "Information") | Out-Null
    })

    # Open install folder from Tools tab
    $sw.FindName("OpenInstallDirBtn").Add_Click({
        if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
        Start-Process explorer.exe $installDir
    })

    # Clear cache from Tools tab
    $sw.FindName("ClearCacheBtn2").Add_Click({
        if (Test-Path $installDir) {
            Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Cache cleared from Settings."
            $sw.FindName("SettingsHint").Text = "Cache cleared!"
        }
    })

    # Tab switching
    $tabPanels = @{
        "ss"       = $sw.FindName("PanelSS")
        "tools"    = $sw.FindName("PanelTools")
        "download" = $sw.FindName("PanelDownload")
        "ui"       = $sw.FindName("PanelUI")
        "advanced" = $sw.FindName("PanelAdvanced")
        "about"    = $sw.FindName("PanelAbout")
    }
    $tabBtns = @{
        "ss"       = $sw.FindName("TabBtnSS")
        "tools"    = $sw.FindName("TabBtnTools")
        "download" = $sw.FindName("TabBtnDownload")
        "ui"       = $sw.FindName("TabBtnUI")
        "advanced" = $sw.FindName("TabBtnAdvanced")
        "about"    = $sw.FindName("TabBtnAbout")
    }

    $switchTab = {
        param($tag)
        foreach ($key in $tabPanels.Keys) {
            $tabPanels[$key].Visibility = if ($key -eq $tag) { "Visible" } else { "Collapsed" }
            $tabBtns[$key].Background   = if ($key -eq $tag) { "#F5C200" } else { "Transparent" }
            $tabBtns[$key].Foreground   = if ($key -eq $tag) { "#0F0B00" } else { "#FFF4C8" }
            $tabBtns[$key].FontWeight   = if ($key -eq $tag) { "SemiBold" } else { "Normal" }
        }
    }

    foreach ($key in $tabBtns.Keys) {
        $capturedKey = $key
        $capturedSwitch = $switchTab
        $tabBtns[$key].Add_Click({ & $capturedSwitch $capturedKey })
    }

    $sw.ShowDialog() | Out-Null
}

# ==============================================================================
# POPULATE TABS
# ==============================================================================
$Categories = @("Orbdiff","Spokwn","Tonynoh","Praiselily","RedLotus","Others")

foreach ($cat in $Categories) {
    $tab    = New-Object System.Windows.Controls.TabItem
    $tab.Header = $cat

    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility   = "Auto"
    $scroll.HorizontalScrollBarVisibility = "Disabled"

    $wrap        = New-Object System.Windows.Controls.WrapPanel
    $wrap.Margin = "8"

    $catTools = $ToolData | Where-Object { $_.Category -eq $cat }

    foreach ($tool in $catTools) {
        $t   = $tool
        $tDesc = $t.Desc
        $btn = New-Object System.Windows.Controls.Button
        $btn.Content  = $t.Name
        $btn.Width      = 155
        $btn.Height     = 40
        $btn.FontSize   = 11
        $btn.Margin     = "4"
        $btn.Cursor     = "Hand"
        $btn.Foreground = "#FFF4C8"
        $btn.Background = "#1E1600"

        $btn.Template = [Windows.Markup.XamlReader]::Parse("
<ControlTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                 xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
                 TargetType='Button'>
    <Border x:Name='brd' Background='#1E1600' CornerRadius='6' BorderBrush='#3D2E00' BorderThickness='1'>
        <Border.ToolTip>
            <ToolTip Background='#1A1200' BorderBrush='#F5C200' BorderThickness='1' Padding='8,4'>
                <TextBlock Text='$tDesc' Foreground='#FFF4C8' FontSize='11'/>
            </ToolTip>
        </Border.ToolTip>
        <ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center'/>
    </Border>
    <ControlTemplate.Triggers>
        <Trigger Property='IsMouseOver' Value='True'>
            <Setter TargetName='brd' Property='Background' Value='#F5C200'/>
            <Setter TargetName='brd' Property='BorderBrush' Value='#F5C200'/>
            <Setter Property='Foreground' Value='#0F0B00'/>
        </Trigger>
        <Trigger Property='IsPressed' Value='True'>
            <Setter TargetName='brd' Property='Background' Value='#C49A00'/>
            <Setter TargetName='brd' Property='BorderBrush' Value='#C49A00'/>
            <Setter Property='Foreground' Value='#0F0B00'/>
        </Trigger>
    </ControlTemplate.Triggers>
</ControlTemplate>
")

        $btn.Add_Click({
            $tName = $_.Source.Content
            $tData = $ToolData | Where-Object { $_.Name -eq $tName } | Select-Object -First 1

            if ($tData.Type -eq "Cmd") {
                Set-Status "Running" "Launching $tName..." "BUSY"
                Write-Log "Starting: $tName"
                try {
                    Start-CmdToolCommand -Command $tData.Command
                    Write-Log "Launched: $tName"
                    Set-Status "Ready" "$tName launched." "IDLE"
                } catch {
                    Write-Log "Error: $_"
                    Set-Status "Error" "Failed to launch $tName." "ERR"
                }
            }
            elseif ($tData.Type -eq "GitHub") {
                $captured = $tData
                Set-Status "Downloading" "Fetching $tName..." "BUSY"
                Write-Log "Starting download: $tName"
                try {
                    Invoke-ToolDownloadAndRun -tool $captured
                } catch {
                    $err = $_
                    Write-Log "Unexpected error: $err"
                    Set-Status "Error" "Something went wrong." "ERR"
                }
            }
            elseif ($tData.Type -eq "Web") {
                $captured = $tData
                Set-Status "Downloading" "Fetching $tName..." "BUSY"
                Write-Log "Starting: $tName"
                try {
                    Invoke-WebToolDownload -tool $captured
                } catch {
                    $err = $_
                    Write-Log "Unexpected error: $err"
                    Set-Status "Error" "Something went wrong." "ERR"
                }
            }
        })

        $wrap.Children.Add($btn) | Out-Null
    }

    $scroll.Content = $wrap
    $tab.Content    = $scroll
    $ToolsTab.Items.Add($tab) | Out-Null
}

# ==============================================================================
# CAT ANIMATION
# ==============================================================================
$catFrames = @(
    " /\_____/\ `n / ^ ^ \ `n ( = w = )`n \ (___) / `n / | | \ `n (__| |__)",
    " /\_____/\ `n / - ^ \ `n ( = w = )`n \ (___) / `n / | | \ `n (__| |__)",
    " /\_____/\ `n / - - \ `n ( = w = )`n \ (___) / `n / | | \ `n (__| |__)",
    " /\_____/\ `n / ^ - \ `n ( = w = )`n \ (___) / `n / | | \ `n (__| |__)"
)
$script:catIdx = 0
$catTimer = New-Object System.Windows.Threading.DispatcherTimer
$catTimer.Interval = [TimeSpan]::FromMilliseconds(900)
$catTimer.Add_Tick({
    $script:catIdx = ($script:catIdx + 1) % $catFrames.Count
    $CatBlock.Text = $catFrames[$script:catIdx]
})
$catTimer.Start()

# ==============================================================================
# EVENTS
# ==============================================================================
$window.Add_MouseLeftButtonDown({ try { $window.DragMove() } catch {} })
$CloseBtn.Add_Click({ $catTimer.Stop(); $window.Close() })
$MinBtn.Add_Click({ $window.WindowState = "Minimized" })
$MaxBtn.Add_Click({
    if ($window.WindowState -eq "Maximized") {
        $window.WindowState = "Normal"
        $MaxBtn.Content = [char]0x25A1   # restore icon
    } else {
        $window.WindowState = "Maximized"
        $MaxBtn.Content = [char]0x25A3   # fullscreen icon
    }
})

$OpenFolderBtn.Add_Click({
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Start-Process explorer.exe $installDir
    Write-Log "Opened install folder."
})

$ClearCacheBtn.Add_Click({
    if (Test-Path $installDir) {
        $items = Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue
        $count = @($items).Count
        $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cleared $count item(s) from install folder."
        Set-Status "Clean" "Removed downloaded files and folders." "IDLE"
    } else {
        Write-Log "Nothing to clear - install folder does not exist yet."
    }
})

$OpenCmdBtn.Add_Click({
    Start-Process -FilePath "cmd.exe"
    Write-Log "Opened CMD."
})

# Screenshare mode button events
$FastSSBtn.Add_Click({
    Write-Log "Starting Fast SS..."
    Invoke-SSMode -Mode "Fast"
})

$NormalSSBtn.Add_Click({
    Write-Log "Starting Normal SS..."
    Invoke-SSMode -Mode "Normal"
})

$FullSSBtn.Add_Click({
    Write-Log "Starting Full SS..."
    Invoke-SSMode -Mode "Full"
})

# Settings button event
$SettingsBtn.Add_Click({
    Show-SettingsWindow
})

Write-Log "Files saved to: $installDir"
Set-Status "Ready" "Select a tool to launch or download it." "IDLE"
$window.ShowDialog() | Out-Null
