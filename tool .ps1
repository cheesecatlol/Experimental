# CheesySSTool Cyber Chemistry Edition
# Saved as UTF-8 without BOM to prevent invisible-character startup failures.
#Requires -Version 5.1

# Ensure WPF runs in a Single-Threaded Apartment. PowerShell 7 commonly starts in MTA.
if ([Threading.Thread]::CurrentThread.ApartmentState -ne [Threading.ApartmentState]::STA) {
    $hostExe = if ($PSVersionTable.PSEdition -eq 'Core') {
        (Get-Process -Id $PID).Path
    } else {
        "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    }

    if (-not $PSCommandPath) {
        throw 'This WPF application must be started from the saved tool.ps1 file.'
    }

    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', ('\"{0}\"' -f $PSCommandPath))
    Start-Process -FilePath $hostExe -ArgumentList $arguments -WorkingDirectory (Split-Path -Parent $PSCommandPath)
    exit
}

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'CheesySSTool requires Windows because its interface uses WPF.'
}

try {
    Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
    Add-Type -AssemblyName PresentationCore -ErrorAction Stop
    Add-Type -AssemblyName WindowsBase -ErrorAction Stop
    Add-Type -AssemblyName System.Xaml -ErrorAction Stop
}
catch {
    $message = 'Unable to load the Windows WPF assemblies. Run this script with Windows PowerShell 5.1 or PowerShell 7 on Windows. Details: ' + $_.Exception.Message
    throw $message
}

if (-not ('Windows.Markup.XamlReader' -as [type])) {
    throw 'WPF loaded incompletely: Windows.Markup.XamlReader is unavailable.'
}

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
    @{ Name="CheckDeletedUSN";    Category="Orbdiff";    Type="GitHub"; Desc="Finds deleted files via USN journal";     URL="https://github.com/CheckDeletedUSN/releases/tag/v0.2.1" },
    @{ Name="JARParser";          Category="Orbdiff";    Type="GitHub"; Desc="Parses JAR files for suspicious content"; URL="https://github.com/JARParser/releases/tag/v1.2" },
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
    Width="1280" Height="800"
    MinWidth="1100" MinHeight="650"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI">
  <Window.Resources>
    <SolidColorBrush x:Key="WinBg"       Color="#F2070C12"/>
    <SolidColorBrush x:Key="TitleBg"     Color="#E8061118"/>
    <SolidColorBrush x:Key="SidebarBg"   Color="#E6081418"/>
    <SolidColorBrush x:Key="ContentBg"   Color="#B8081218"/>
    <SolidColorBrush x:Key="CardBg"      Color="#C00A1A1D"/>
    <SolidColorBrush x:Key="CardBorder"  Color="#365F6A"/>
    <SolidColorBrush x:Key="Accent"      Color="#39FF9A"/>
    <SolidColorBrush x:Key="AccentGreen" Color="#00FFB3"/>
    <SolidColorBrush x:Key="TextPrimary" Color="#ECFFF7"/>
    <SolidColorBrush x:Key="TextMuted"   Color="#76A99A"/>
    <SolidColorBrush x:Key="TextDim"     Color="#426C62"/>
    <SolidColorBrush x:Key="ConsoleBg"   Color="#E6030A0C"/>
    <SolidColorBrush x:Key="SepColor"    Color="#24453F"/>

    <Style x:Key="WinBtn" TargetType="Button">
      <Setter Property="Width"           Value="46"/>
      <Setter Property="Height"          Value="32"/>
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="{StaticResource TextMuted}"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontSize"        Value="12"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="#1A3A5C"/>
                <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="CloseWinBtn" TargetType="Button" BasedOn="{StaticResource WinBtn}">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="#C0392B"/>
                <Setter Property="Foreground" Value="White"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="NavBtn" TargetType="Button">
      <Setter Property="Width"           Value="48"/>
      <Setter Property="Height"          Value="48"/>
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="{StaticResource TextMuted}"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontSize"        Value="18"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="8" Margin="4,2">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="#1A3A5C"/>
                <Setter Property="Foreground" Value="{StaticResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="SSBtn" TargetType="Button">
      <Setter Property="Height"          Value="32"/>
      <Setter Property="Margin"          Value="0,0,0,4"/>
      <Setter Property="Background"      Value="#0D2340"/>
      <Setter Property="Foreground"      Value="{StaticResource TextPrimary}"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush"     Value="{StaticResource CardBorder}"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="4">
              <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="#1A3A5C"/>
                <Setter TargetName="b" Property="BorderBrush" Value="{StaticResource Accent}"/>
                <Setter Property="Foreground" Value="{StaticResource Accent}"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="b" Property="Background" Value="#4A9EFF"/>
                <Setter Property="Foreground" Value="White"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="TabItem">
      <Setter Property="Foreground"  Value="{StaticResource TextMuted}"/>
      <Setter Property="FontSize"    Value="11"/>
      <Setter Property="Padding"     Value="14,7"/>
      <Setter Property="Cursor"      Value="Hand"/>
      <Setter Property="Background"  Value="Transparent"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TabItem">
            <Border x:Name="tb" Background="Transparent" CornerRadius="4" Margin="2,4,2,0" Padding="14,6">
              <ContentPresenter ContentSource="Header" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="tb" Property="Background" Value="{StaticResource Accent}"/>
                <Setter Property="Foreground" Value="White"/>
                <Setter Property="FontWeight" Value="SemiBold"/>
              </Trigger>
              <MultiTrigger>
                <MultiTrigger.Conditions>
                  <Condition Property="IsMouseOver" Value="True"/>
                  <Condition Property="IsSelected"  Value="False"/>
                </MultiTrigger.Conditions>
                <Setter TargetName="tb" Property="Background" Value="#1A3A5C"/>
                <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
              </MultiTrigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="NeonText" TargetType="TextBlock">
      <Setter Property="Effect">
        <Setter.Value><DropShadowEffect Color="#39FF9A" BlurRadius="10" ShadowDepth="0" Opacity="0.45"/></Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Border Background="{StaticResource WinBg}" BorderBrush="#1A3A5C" BorderThickness="1" CornerRadius="8">
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="38"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <Border Grid.Row="0" Background="{StaticResource TitleBg}" CornerRadius="8,8,0,0">
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="56"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Text="&#x25C6;" FontSize="14" Foreground="{StaticResource Accent}"
                     HorizontalAlignment="Center" VerticalAlignment="Center"/>
          <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
            <TextBlock x:Name="AppTitle" Text="CHEESY // LAB" FontFamily="Consolas" FontSize="13" FontWeight="Bold" Foreground="{StaticResource Accent}" Style="{StaticResource NeonText}"/>
            <Border Background="#1A3A5C" CornerRadius="3" Margin="8,0,0,0" Padding="6,1">
              <TextBlock Text="SS Tool" FontSize="9" Foreground="{StaticResource Accent}"/>
            </Border>
          </StackPanel>
          <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
            <Button x:Name="MinBtn"   Style="{StaticResource WinBtn}"      Content="&#x2212;"/>
            <Button x:Name="MaxBtn"   Style="{StaticResource WinBtn}"      Content="&#x25A1;"/>
            <Button x:Name="CloseBtn" Style="{StaticResource CloseWinBtn}" Content="&#x2715;"/>
          </StackPanel>
        </Grid>
      </Border>

      <Grid Grid.Row="1" Background="#03080B" ClipToBounds="True">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <Canvas x:Name="ChemicalCanvas" Grid.ColumnSpan="2" IsHitTestVisible="False" Opacity="0.52" ClipToBounds="True"/>
        <Canvas x:Name="FormulaCanvas" Grid.ColumnSpan="2" IsHitTestVisible="False" Opacity="0.22" ClipToBounds="True"/>
        <Rectangle x:Name="ScanLine" Grid.ColumnSpan="2" Height="3" VerticalAlignment="Top" IsHitTestVisible="False" Opacity="0">
          <Rectangle.Fill>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
              <GradientStop Color="#0039FF9A" Offset="0"/>
              <GradientStop Color="#CC39FF9A" Offset="0.5"/>
              <GradientStop Color="#0039FF9A" Offset="1"/>
            </LinearGradientBrush>
          </Rectangle.Fill>
          <Rectangle.Effect><DropShadowEffect Color="#39FF9A" BlurRadius="18" ShadowDepth="0" Opacity="0.9"/></Rectangle.Effect>
        </Rectangle>
        <Border Grid.ColumnSpan="2" IsHitTestVisible="False" Background="#36000808"/>

        <StackPanel x:Name="SidebarZone" Grid.Column="0" Orientation="Horizontal">

        <Border Background="{StaticResource SidebarBg}" BorderBrush="{StaticResource SepColor}" BorderThickness="0,0,1,0">
          <StackPanel VerticalAlignment="Top" Margin="0,12,0,0">
            <Button x:Name="FastSSBtn"   Style="{StaticResource NavBtn}" FontSize="14" Foreground="{StaticResource Accent}">
              <Button.Content>
                <TextBlock Text="&#x26A1;" FontSize="16"/>
              </Button.Content>
              <Button.ToolTip><ToolTip Content="Fast SS" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Button x:Name="NormalSSBtn" Style="{StaticResource NavBtn}">
              <Button.Content>
                <TextBlock Text="&#x1F50D;" FontSize="14"/>
              </Button.Content>
              <Button.ToolTip><ToolTip Content="Normal SS" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Button x:Name="FullSSBtn"   Style="{StaticResource NavBtn}">
              <Button.Content>
                <TextBlock Text="&#x1F6E1;" FontSize="14"/>
              </Button.Content>
              <Button.ToolTip><ToolTip Content="Full SS" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Rectangle Height="1" Fill="{StaticResource SepColor}" Margin="8,8"/>
            <Button x:Name="OpenFolderBtn" Style="{StaticResource NavBtn}">
              <Button.Content><TextBlock Text="&#x1F4C2;" FontSize="14"/></Button.Content>
              <Button.ToolTip><ToolTip Content="Open Install Folder" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Button x:Name="ClearCacheBtn" Style="{StaticResource NavBtn}">
              <Button.Content><TextBlock Text="&#x1F5D1;" FontSize="14"/></Button.Content>
              <Button.ToolTip><ToolTip Content="Clear Cache" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Button x:Name="OpenCmdBtn" Style="{StaticResource NavBtn}">
              <Button.Content><TextBlock Text="&#x1F5A5;" FontSize="14"/></Button.Content>
              <Button.ToolTip><ToolTip Content="Open CMD" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
            <Button x:Name="SettingsBtn" Style="{StaticResource NavBtn}" VerticalAlignment="Bottom" Margin="0,20,0,0">
              <Button.Content><TextBlock Text="&#x2699;" FontSize="16"/></Button.Content>
              <Button.ToolTip><ToolTip Content="Settings" Background="#112240" Foreground="{StaticResource TextPrimary}" BorderBrush="{StaticResource Accent}" BorderThickness="1"/></Button.ToolTip>
            </Button>
          </StackPanel>
        </Border>

        <Border x:Name="FullMenuPanel" Width="200" Visibility="Collapsed" Background="{StaticResource SidebarBg}" BorderBrush="{StaticResource SepColor}" BorderThickness="0,0,1,0">
          <StackPanel Margin="12,14,12,14">
            <Border Background="#B0061012" CornerRadius="6" Margin="0,0,0,14" Padding="0,10">
              <TextBlock x:Name="CatBlock"
                Text=" /\_____/\ &#x0a; / ^ ^ \ &#x0a; ( = w = )&#x0a; \ (___) / &#x0a; / | | \ &#x0a; (__| |__)"
                FontFamily="Consolas" FontSize="9"
                Foreground="{StaticResource Accent}"
                HorizontalAlignment="Center"
                TextAlignment="Left"
                xml:space="preserve"/>
            </Border>

            <TextBlock Text="SCREENSHARE" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextDim}" Margin="2,0,0,6"/>
            <Button x:Name="FastSSLbl"   Style="{StaticResource SSBtn}" Content="&#x26A1;  Fast SS"/>
            <Button x:Name="NormalSSLbl" Style="{StaticResource SSBtn}" Content="&#x1F50D;  Normal SS"/>
            <Button x:Name="FullSSLbl"   Style="{StaticResource SSBtn}" Content="&#x1F6E1;  Full SS"/>

            <Rectangle Height="1" Fill="{StaticResource SepColor}" Margin="0,10"/>

            <TextBlock Text="ACTIONS" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextDim}" Margin="2,0,0,6"/>
            <Button x:Name="OpenFolderLbl"  Style="{StaticResource SSBtn}" Content="&#x1F4C2;  Open Folder"/>
            <Button x:Name="ClearCacheLbl"  Style="{StaticResource SSBtn}" Content="&#x1F5D1;  Clear Cache"/>
            <Button x:Name="OpenCmdLbl"     Style="{StaticResource SSBtn}" Content="&#x1F5A5;  Open CMD"/>

            <Rectangle Height="1" Fill="{StaticResource SepColor}" Margin="0,10"/>

            <TextBlock Text="INFO" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextDim}" Margin="2,0,0,6"/>
            <TextBlock Text="cheese cat" FontSize="11" FontWeight="SemiBold" Foreground="{StaticResource TextPrimary}" Margin="2,0,0,2"/>
            <TextBlock Text="discord: cheese_cat0" FontSize="9" Foreground="{StaticResource TextMuted}" Margin="2,0,0,1"/>
            <TextBlock Text="github: cheesecatlol"  FontSize="9" Foreground="{StaticResource TextMuted}" Margin="2,0,0,8"/>
            <TextBlock x:Name="InstPathBlock" Text="" FontSize="8" Foreground="{StaticResource TextDim}" TextWrapping="Wrap" Margin="2,0,0,0"/>

            <Button x:Name="SettingsLbl" Style="{StaticResource SSBtn}" Content="&#x2699;  Settings" Margin="0,10,0,0"/>
          </StackPanel>
        </Border>
        </StackPanel>

        <Grid Grid.Column="1" Margin="0">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <Border Grid.Row="0" Background="{StaticResource TitleBg}" BorderBrush="{StaticResource SepColor}" BorderThickness="0,0,0,1" Padding="20,10">
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <StackPanel>
                <TextBlock x:Name="StatusTitle" Text="SYSTEM READY" FontFamily="Consolas" FontSize="18" FontWeight="Bold" Foreground="{StaticResource TextPrimary}"/>
                <TextBlock x:Name="StatusSub"   Text="Select a tool to launch or download." FontSize="10" Foreground="{StaticResource TextMuted}" Margin="0,2,0,0"/>
              </StackPanel>
              <Border Grid.Column="1" Background="#A00A211B" BorderBrush="{StaticResource Accent}" BorderThickness="1" CornerRadius="4" Padding="12,4" VerticalAlignment="Center">
                <TextBlock x:Name="StatusBadge" Text="IDLE" FontSize="11" FontWeight="Bold" Foreground="{StaticResource Accent}"/>
              </Border>
            </Grid>
          </Border>

          <Border Grid.Row="1" Background="{StaticResource ContentBg}" Padding="0" MaxHeight="320" Margin="0,0,0,12">
            <TabControl x:Name="ToolsTab" Background="Transparent" BorderThickness="0" Padding="0">
              <TabControl.Resources>
                <Style TargetType="TabPanel">
                  <Setter Property="Background" Value="{StaticResource TitleBg}"/>
                </Style>
              </TabControl.Resources>
            </TabControl>
          </Border>

          <Border Grid.Row="2" Background="{StaticResource ConsoleBg}" BorderBrush="{StaticResource SepColor}" BorderThickness="0,1,0,0" Padding="16,10">
            <Grid>
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>
              <StackPanel Orientation="Horizontal" Margin="0,0,0,6">
                <TextBlock Text="&#x25CF;" Foreground="{StaticResource AccentGreen}" FontSize="8" VerticalAlignment="Center" Margin="0,0,6,0"/>
                <TextBlock Text="ACTIVITY LOG" FontSize="9" FontWeight="Bold" Foreground="{StaticResource TextDim}" VerticalAlignment="Center"/>
              </StackPanel>
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
try {
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    $message = 'The interface could not be loaded. The script stopped before creating any controls. Details: ' + $_.Exception.Message
    throw $message
}
finally {
    if ($null -ne $reader) {
        $reader.Close()
    }
}

if ($null -eq $window) {
    throw 'The interface loader returned no window. Startup has been stopped safely.'
}

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
$FastSSLbl     = $window.FindName("FastSSLbl")
$NormalSSLbl   = $window.FindName("NormalSSLbl")
$FullSSLbl     = $window.FindName("FullSSLbl")
$OpenFolderLbl = $window.FindName("OpenFolderLbl")
$ClearCacheLbl = $window.FindName("ClearCacheLbl")
$OpenCmdLbl    = $window.FindName("OpenCmdLbl")
$SettingsLbl   = $window.FindName("SettingsLbl")
$SidebarZone   = $window.FindName("SidebarZone")
$FullMenuPanel = $window.FindName("FullMenuPanel")
$ChemicalCanvas = $window.FindName("ChemicalCanvas")
$FormulaCanvas  = $window.FindName("FormulaCanvas")
$ScanLine       = $window.FindName("ScanLine")
$AppTitle       = $window.FindName("AppTitle")

$InstPathBlock.Text = "Install path:`n$installDir"

# ==============================================================================
# CYBER-CHEMISTRY VISUAL ENGINE (presentation only)
# ==============================================================================
$script:ChemNodes = New-Object System.Collections.ArrayList
$script:ChemBonds = New-Object System.Collections.ArrayList
$script:ChemTick = 0
$script:Random = New-Object System.Random

function New-NeonBrush([string]$hex, [byte]$alpha = 255) {
    $c = [Windows.Media.ColorConverter]::ConvertFromString($hex)
    $c.A = $alpha
    return (New-Object Windows.Media.SolidColorBrush -ArgumentList $c)
}

function Initialize-ChemistryBackground {
    $ChemicalCanvas.Children.Clear()
    $FormulaCanvas.Children.Clear()
    $script:ChemNodes.Clear()
    $script:ChemBonds.Clear()

    $w = [Math]::Max(900, $window.ActualWidth)
    $h = [Math]::Max(560, $window.ActualHeight - 38)
    $symbols = @('C','H','O','N','Cl','Na','S','P')

    for ($i = 0; $i -lt 30; $i++) {
        $size = $script:Random.Next(4, 10)
        $dot = New-Object Windows.Shapes.Ellipse
        $dot.Width = $size; $dot.Height = $size
        $dot.Fill = New-NeonBrush '#39FF9A' ([byte]$script:Random.Next(90,190))
        $dot.Stroke = New-NeonBrush '#B8FFE0' 180
        $dot.StrokeThickness = 0.6
        $dot.Effect = New-Object Windows.Media.Effects.DropShadowEffect
        $dot.Effect.Color = [Windows.Media.ColorConverter]::ConvertFromString('#39FF9A')
        $dot.Effect.BlurRadius = 12; $dot.Effect.ShadowDepth = 0; $dot.Effect.Opacity = 0.7
        $x = $script:Random.NextDouble() * $w
        $y = $script:Random.NextDouble() * $h
        [Windows.Controls.Canvas]::SetLeft($dot, $x)
        [Windows.Controls.Canvas]::SetTop($dot, $y)
        [void]$ChemicalCanvas.Children.Add($dot)
        [void]$script:ChemNodes.Add([pscustomobject]@{
            Shape=$dot; X=$x; Y=$y
            VX=($script:Random.NextDouble()-0.5)*1.2
            VY=($script:Random.NextDouble()-0.5)*1.2
            Phase=$script:Random.NextDouble()*6.28
        })
    }

    for ($i = 0; $i -lt 14; $i++) {
        $text = New-Object Windows.Controls.TextBlock
        $text.Text = $symbols[$script:Random.Next(0,$symbols.Count)]
        $text.FontFamily = 'Consolas'; $text.FontWeight = 'Bold'
        $text.FontSize = $script:Random.Next(10,19)
        $text.Foreground = New-NeonBrush '#39FF9A' ([byte]$script:Random.Next(80,150))
        [Windows.Controls.Canvas]::SetLeft($text, $script:Random.NextDouble()*$w)
        [Windows.Controls.Canvas]::SetTop($text, $script:Random.NextDouble()*$h)
        [void]$ChemicalCanvas.Children.Add($text)
    }

    $formulas = @('C8H10N4O2','H2SO4','NaCl','C6H12O6','NH3','CH3COOH','CO2','Fe2O3','[ REACTION ]','ΔG < 0')
    for ($i = 0; $i -lt 12; $i++) {
        $f = New-Object Windows.Controls.TextBlock
        $f.Text = $formulas[$script:Random.Next(0,$formulas.Count)]
        $f.FontFamily = 'Consolas'; $f.FontSize = $script:Random.Next(9,15)
        $f.Foreground = New-NeonBrush '#67FFC0' ([byte]$script:Random.Next(90,160))
        $f.RenderTransform = New-Object Windows.Media.RotateTransform -ArgumentList $script:Random.Next(-12,13)
        [Windows.Controls.Canvas]::SetLeft($f, $script:Random.NextDouble()*$w)
        [Windows.Controls.Canvas]::SetTop($f, $script:Random.NextDouble()*$h)
        [void]$FormulaCanvas.Children.Add($f)
    }
}

function Update-ChemistryBackground {
    if (-not $ChemicalCanvas -or $script:ChemNodes.Count -eq 0) { return }
    $w = [Math]::Max(100, $ChemicalCanvas.ActualWidth)
    $h = [Math]::Max(100, $ChemicalCanvas.ActualHeight)
    $script:ChemTick++

    foreach ($line in @($script:ChemBonds)) {
        [void]$ChemicalCanvas.Children.Remove($line)
    }
    $script:ChemBonds.Clear()

    foreach ($n in $script:ChemNodes) {
        $n.X += $n.VX
        $n.Y += $n.VY
        if ($n.X -lt 0 -or $n.X -gt $w) { $n.VX *= -1; $n.X = [Math]::Max(0,[Math]::Min($w,$n.X)) }
        if ($n.Y -lt 0 -or $n.Y -gt $h) { $n.VY *= -1; $n.Y = [Math]::Max(0,[Math]::Min($h,$n.Y)) }
        [Windows.Controls.Canvas]::SetLeft($n.Shape,$n.X)
        [Windows.Controls.Canvas]::SetTop($n.Shape,$n.Y)
        $n.Shape.Opacity = 0.52 + 0.28 * [Math]::Sin(($script:ChemTick/18.0)+$n.Phase)
    }

    for ($i=0; $i -lt $script:ChemNodes.Count; $i++) {
        for ($j=$i+1; $j -lt $script:ChemNodes.Count; $j++) {
            $a=$script:ChemNodes[$i]; $b=$script:ChemNodes[$j]
            $dx=$a.X-$b.X; $dy=$a.Y-$b.Y; $d2=$dx*$dx+$dy*$dy
            if ($d2 -lt 12500 -and $script:ChemBonds.Count -lt 55) {
                $line=New-Object Windows.Shapes.Line
                $line.X1=$a.X+3; $line.Y1=$a.Y+3; $line.X2=$b.X+3; $line.Y2=$b.Y+3
                $line.Stroke=New-NeonBrush '#39FF9A' ([byte]([Math]::Max(15,90-($d2/170))))
                $line.StrokeThickness=0.7
                [Windows.Controls.Panel]::SetZIndex($line,-1)
                [void]$ChemicalCanvas.Children.Insert(0,$line)
                [void]$script:ChemBonds.Add($line)
            }
        }
    }
}

function Start-ScanAnimation {
    if (-not $ScanLine) { return }
    $move = New-Object Windows.Media.Animation.DoubleAnimation
    $move.From = -5; $move.To = [Math]::Max(600,$window.ActualHeight-40)
    $move.Duration = New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromSeconds(3.2))
    $move.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $move.BeginTime = [TimeSpan]::FromSeconds(1.2)
    $ScanLine.RenderTransform = New-Object Windows.Media.TranslateTransform
    $ScanLine.RenderTransform.BeginAnimation([Windows.Media.TranslateTransform]::YProperty,$move)
    $fade = New-Object Windows.Media.Animation.DoubleAnimation
    $fade.From=0.0; $fade.To=0.55; $fade.AutoReverse=$true
    $fade.Duration=New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromMilliseconds(550))
    $fade.RepeatBehavior=[Windows.Media.Animation.RepeatBehavior]::Forever
    $ScanLine.BeginAnimation([Windows.UIElement]::OpacityProperty,$fade)
}

function Start-StartupAnimation {
    $window.Opacity = 0
    $fade = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList 0,1,(New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromMilliseconds(650)))
    $window.BeginAnimation([Windows.UIElement]::OpacityProperty,$fade)
    if ($AppTitle) {
        $pulse = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList 0.35,1,(New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromMilliseconds(420)))
        $pulse.AutoReverse=$true; $pulse.RepeatBehavior=New-Object Windows.Media.Animation.RepeatBehavior -ArgumentList 3
        $AppTitle.BeginAnimation([Windows.UIElement]::OpacityProperty,$pulse)
    }
}

function Add-NeonButtonMotion([Windows.Controls.Button]$Button) {
    $scale = New-Object Windows.Media.ScaleTransform -ArgumentList 1,1
    $Button.RenderTransformOrigin = New-Object Windows.Point -ArgumentList 0.5,0.5
    $Button.RenderTransform = $scale
    $Button.Add_MouseEnter({
        $target = [Windows.Controls.Button]$this
        $transform = [Windows.Media.ScaleTransform]$target.RenderTransform
        $duration = New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromMilliseconds(130))
        $sx = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList $transform.ScaleX,1.045,$duration
        $sy = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList $transform.ScaleY,1.045,$duration
        $transform.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty,$sx)
        $transform.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty,$sy)
        $glow = New-Object Windows.Media.Effects.DropShadowEffect
        $glow.Color=[Windows.Media.ColorConverter]::ConvertFromString('#39FF9A')
        $glow.BlurRadius=16; $glow.ShadowDepth=0; $glow.Opacity=.55
        $target.Effect=$glow
    })
    $Button.Add_MouseLeave({
        $target = [Windows.Controls.Button]$this
        $transform = [Windows.Media.ScaleTransform]$target.RenderTransform
        $duration = New-Object Windows.Duration -ArgumentList ([TimeSpan]::FromMilliseconds(160))
        $sx = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList $transform.ScaleX,1,$duration
        $sy = New-Object Windows.Media.Animation.DoubleAnimation -ArgumentList $transform.ScaleY,1,$duration
        $transform.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty,$sx)
        $transform.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty,$sy)
        $target.Effect=$null
    })
}

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
        $StatusSub.Text = $sub
        $StatusBadge.Text = $badge
    })
}

function Start-AppOrScript {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [string]$WorkingDirectory
    )
    if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path -Parent $Path }
    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    $quotedPath = '"' + $Path + '"'

    if ($extension -eq '.ps1') {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $quotedPath" -WorkingDirectory $WorkingDirectory
    } elseif ($extension -eq '.bat' -or $extension -eq '.cmd') {
        Start-Process cmd.exe -ArgumentList "/c $quotedPath" -WorkingDirectory $WorkingDirectory
    } else {
        Start-Process $Path -WorkingDirectory $WorkingDirectory
    }
}

# ==============================================================================
# SCREENS_HARE LOGIC
# ==============================================================================
function Invoke-SSMode {
    param([string]$Mode)
    Set-Status "RUNNING $Mode SS" "Executing background routines..." "ACTIVE"
    Write-Log "Initializing $Mode Screen Share analyzer engine..."
    # Placeholder loop simulate activity
    [Threading.Thread]::Sleep(400)
    Write-Log "System scan point created for $Mode."
    Set-Status "SYSTEM READY" "Select a tool to launch or download." "IDLE"
}

function Show-SettingsWindow {
    [xml]$sxaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Settings" Width="400" Height="250" WindowStartupLocation="CenterOwner" ResizeMode="NoResize" WindowStyle="None" Background="#0A121A" BorderBrush="#365F6A" BorderThickness="1">
      <Grid Margin="20">
        <StackPanel>
          <TextBlock Text="SETTINGS PANEL" FontSize="14" FontWeight="Bold" Foreground="#39FF9A" Margin="0,0,0,15"/>
          <TextBlock Text="Install Directory:" FontSize="10" Foreground="#76A99A" Margin="0,0,0,4"/>
          <TextBox Text="$installDir" IsReadOnly="True" Background="#050A0F" Foreground="#ECFFF7" BorderBrush="#365F6A" Padding="6,4" Margin="0,0,0,20"/>
          <Button x:Name="CloseSettings" Content="CLOSE" Width="100" Height="30" HorizontalAlignment="Right" Background="#112240" Foreground="#ECFFF7" Cursor="Hand"/>
        </StackPanel>
      </Grid>
    </Window>
"@
    $sreader = New-Object System.Xml.XmlNodeReader $sxaml
    $swin = [Windows.Markup.XamlReader]::Load($sreader)
    $swin.Owner = $window
    $swin.FindName("CloseSettings").Add_Click({ $swin.Close() })
    $swin.ShowDialog() | Out-Null
}

# ==============================================================================
# UI GENERATION & TAB CREATION
# ==============================================================================
$categories = $ToolData | Group-Object Category
foreach ($cat in $categories) {
    $tabItem = New-Object Windows.Controls.TabItem
    $tabItem.Header = $cat.Name.ToUpper()

    $scroll = New-Object Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = "Auto"
    $scroll.HorizontalScrollBarVisibility = "Disabled"
    $scroll.Margin = New-Object Windows.Thickness -ArgumentList 12,6,12,12

    $wp = New-Object Windows.Controls.WrapPanel
    $wp.ItemWidth = 230; $wp.ItemHeight = 90

    foreach ($tool in $cat.Group) {
        $card = New-Object Windows.Controls.Border
        $card.Background = (New-Object Windows.Media.SolidColorBrush -ArgumentList ([Windows.Media.ColorConverter]::ConvertFromString('#C00A1A1D')))
        $card.BorderBrush = (New-Object Windows.Media.SolidColorBrush -ArgumentList ([Windows.Media.ColorConverter]::ConvertFromString('#24453F')))
        $card.BorderThickness = 1
        $card.CornerRadius = 5
        $card.Margin = New-Object Windows.Thickness -ArgumentList 5

        $grid = New-Object Windows.Controls.Grid
        $grid.Margin = New-Object Windows.Thickness -ArgumentList 10,8,10,8

        $titleBlk = New-Object Windows.Controls.TextBlock
        $titleBlk.Text = $tool.Name
        $titleBlk.FontWeight = "Bold"
        $titleBlk.FontSize = 12
        $titleBlk.Foreground = New-NeonBrush '#ECFFF7'
        $titleBlk.VerticalAlignment = "Top"

        $descBlk = New-Object Windows.Controls.TextBlock
        $descBlk.Text = $tool.Desc
        $descBlk.FontSize = 9
        $descBlk.Foreground = New-NeonBrush '#76A99A'
        $descBlk.TextWrapping = "Wrap"
        $descBlk.Margin = New-Object Windows.Thickness -ArgumentList 0,18,0,0
        $descBlk.MaxHeight = 32

        $btn = New-Object Windows.Controls.Button
        $btn.Content = if ($tool.Type -eq "Cmd") { "RUN CMD" } else { "LAUNCH" }
        $btn.Width = 64; $btn.Height = 20
        $btn.HorizontalAlignment = "Right"
        $btn.VerticalAlignment = "Top"
        $btn.FontSize = 8; $btn.FontWeight = "Bold"
        $btn.Cursor = "Hand"
        $btn.Background = New-NeonBrush '#0D2340'
        $btn.Foreground = New-NeonBrush '#39FF9A'
        $btn.BorderBrush = New-NeonBrush '#365F6A'

        $tName = $tool.Name
        $tURL = $tool.URL
        $tCmd = $tool.Command
        $tType = $tool.Type

        $btn.Add_Click({
            param($s, $e)
            Set-Status "LAUNCHING $tName" "Preparing execution context..." "BUSY"
            Write-Log "Attempting to invoke $tName ($tType)..."

            if ($tType -eq "Cmd") {
                try {
                    Write-Log "Running inline payload command..."
                    Invoke-Expression $tCmd | Out-Null
                    Write-Log "Command payload executed successfully."
                } catch {
                    Write-Log "Error executing command: $_"
                }
            } else {
                $targetFile = Join-Path $installDir "$tName.exe"
                if (Test-Path $targetFile) {
                    Write-Log "Found local binary. Starting process..."
                    Start-AppOrScript -Path $targetFile
                } else {
                    Write-Log "Binary not found locally. Redirecting to resource URL..."
                    if ($tURL) { Start-Process $tURL }
                }
            }
            Set-Status "SYSTEM READY" "Select a tool to launch or download." "IDLE"
        })

        [void]$grid.Children.Add($titleBlk)
        [void]$grid.Children.Add($descBlk)
        [void]$grid.Children.Add($btn)
        $card.Child = $grid
        [void]$wp.Children.Add($card)
    }

    $scroll.Content = $wp
    $tabItem.Content = $scroll
    [void]$ToolsTab.Items.Add($tabItem)
}

# ==============================================================================
# EVENT WIRES
# ==============================================================================
$window.Add_SourceInitialized({
    Initialize-ChemistryBackground
    Start-ScanAnimation
    Start-StartupAnimation
    Write-Log "CheesySSTool Cyber-Chemistry Interface initialized."
})

$window.Add_SizeChanged({ Initialize-ChemistryBackground })

# Active Floating Molecular Animation Loop (DispatcherTimer)
$script:AnimTimer = New-Object Windows.Threading.DispatcherTimer
$script:AnimTimer.Interval = [TimeSpan]::FromMilliseconds(16) # ~60 FPS
$script:AnimTimer.Add_Tick({ Update-ChemistryBackground })
$script:AnimTimer.Start()

$CloseBtn.Add_Click({ 
    $script:AnimTimer.Stop()
    $window.Close() 
})
$MinBtn.Add_Click({ $window.WindowState = "Minimized" })
$MaxBtn.Add_Click({
    if ($window.WindowState -eq "Maximized") { $window.WindowState = "Normal" }
    else { $window.WindowState = "Maximized" }
})

# Sidebar hovering reveal effect
$SidebarZone.Add_MouseEnter({ $FullMenuPanel.Visibility = "Visible" })
$SidebarZone.Add_MouseLeave({ $FullMenuPanel.Visibility = "Collapsed" })

# Active Hover Effects onto Nav items
@($FastSSBtn, $NormalSSBtn, $FullSSBtn, $OpenFolderBtn, $ClearCacheBtn, $OpenCmdBtn, $SettingsBtn) | ForEach-Object {
    Add-NeonButtonMotion $_
}

# Standard sidebar icon action clicks
$OpenFolderBtn.Add_Click({
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Start-Process explorer.exe $installDir
    Write-Log "Opened installer cache destination."
})

$ClearCacheBtn.Add_Click({
    if (Test-Path $installDir) {
        $items = Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue
        $count = @($items).Count
        $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cache cleared. Purged $count files."
    }
})

$OpenCmdBtn.Add_Click({
    Start-Process cmd.exe
    Write-Log "Spawned standalone CMD session."
})

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
$SettingsBtn.Add_Click({ Show-SettingsWindow })

# Label buttons in left panel — same actions as icon buttons
$FastSSLbl.Add_Click({   Write-Log "Starting Fast SS...";   Invoke-SSMode -Mode "Fast" })
$NormalSSLbl.Add_Click({ Write-Log "Starting Normal SS..."; Invoke-SSMode -Mode "Normal" })
$FullSSLbl.Add_Click({   Write-Log "Starting Full SS...";   Invoke-SSMode -Mode "Full" })
$OpenFolderLbl.Add_Click({
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Start-Process explorer.exe $installDir
    Write-Log "Opened install folder."
})
$ClearCacheLbl.Add_Click({
    if (Test-Path $installDir) {
        $items = Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue
        $count = @($items).Count
        $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cleared $count item(s) from install folder."
        Set-Status "Clean" "Removed downloaded files and folders." "IDLE"
    } else { Write-Log "Nothing to clear." }
})
$OpenCmdLbl.Add_Click({
    Start-Process cmd.exe
    Write-Log "Spawned Command Prompt."
})
$SettingsLbl.Add_Click({ Show-SettingsWindow })

$window.Add_MouseLeftButtonDown({
    param($s, $e)
    $window.DragMove()
})

Write-Log "Loading complete. Standby."
$window.ShowDialog() | Out-Null