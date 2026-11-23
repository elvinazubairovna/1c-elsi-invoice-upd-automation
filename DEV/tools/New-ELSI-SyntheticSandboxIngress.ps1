Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-ELSIIngressPathEligibility {
    param(
        [AllowNull()][string] $LocalApplicationDataPath,
        [AllowNull()][string] $TargetPath,
        [AllowNull()][string] $PayloadPath,
        [bool] $BaseExists,
        [bool] $BaseIsDirectory,
        [bool] $BaseIsReparsePoint,
        [bool] $TargetExists,
        [bool] $TargetIsReparsePoint,
        [bool] $PayloadExists,
        [bool] $PayloadIsReparsePoint
    )

    if ([string]::IsNullOrWhiteSpace($LocalApplicationDataPath) -or
        [string]::IsNullOrWhiteSpace($TargetPath) -or
        [string]::IsNullOrWhiteSpace($PayloadPath)) { return 'PATH_UNVERIFIED' }

    try {
        if (-not [System.IO.Path]::IsPathRooted($LocalApplicationDataPath) -or
            -not [System.IO.Path]::IsPathRooted($TargetPath) -or
            -not [System.IO.Path]::IsPathRooted($PayloadPath)) { return 'PATH_UNVERIFIED' }

        $baseFull = [System.IO.Path]::GetFullPath($LocalApplicationDataPath)
        $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
        $payloadFull = [System.IO.Path]::GetFullPath($PayloadPath)
        $expectedTarget = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($baseFull, 'ELSI-Sandbox-Synthetic-Ingress-022'))
        $expectedPayload = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($expectedTarget, 'payload'))
    }
    catch { return 'PATH_UNVERIFIED' }

    $comparison = [System.StringComparison]::OrdinalIgnoreCase
    if (-not [string]::Equals($targetFull, $expectedTarget, $comparison) -or
        -not [string]::Equals($payloadFull, $expectedPayload, $comparison)) { return 'PATH_ESCAPE' }

    if (-not $BaseExists -or -not $BaseIsDirectory -or $BaseIsReparsePoint -or
        $TargetIsReparsePoint -or $PayloadIsReparsePoint) { return 'PATH_UNVERIFIED' }
    if ($TargetExists -or $PayloadExists) { return 'TARGET_EXISTS' }
    return 'NONE'
}

function New-ELSIIngressConfigurationXml {
    param(
        [Parameter(Mandatory)][string] $HostFolder,
        [Parameter(Mandatory)][string] $SandboxFolder
    )

    if ([string]::IsNullOrWhiteSpace($HostFolder) -or
        -not [System.IO.Path]::IsPathRooted($HostFolder) -or
        $SandboxFolder -cne 'C:\SandboxSyntheticIngress') { return $null }

    $builder = [System.Text.StringBuilder]::new()
    $settings = [System.Xml.XmlWriterSettings]::new()
    $settings.OmitXmlDeclaration = $true
    $settings.Indent = $true
    $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
    $writer = $null
    try {
        $writer = [System.Xml.XmlWriter]::Create($builder, $settings)
        $writer.WriteStartElement('Configuration')
        $writer.WriteElementString('vGPU', 'Disable')
        $writer.WriteElementString('Networking', 'Disable')
        $writer.WriteElementString('AudioInput', 'Disable')
        $writer.WriteElementString('VideoInput', 'Disable')
        $writer.WriteElementString('PrinterRedirection', 'Disable')
        $writer.WriteElementString('ClipboardRedirection', 'Disable')
        $writer.WriteElementString('ProtectedClient', 'Enable')
        $writer.WriteStartElement('MappedFolders')
        $writer.WriteStartElement('MappedFolder')
        $writer.WriteElementString('HostFolder', $HostFolder)
        $writer.WriteElementString('SandboxFolder', $SandboxFolder)
        $writer.WriteElementString('ReadOnly', 'true')
        $writer.WriteEndElement()
        $writer.WriteEndElement()
        $writer.WriteEndElement()
        $writer.Flush()
        return $builder.ToString()
    }
    catch { return $null }
    finally { if ($null -ne $writer) { $writer.Dispose() } }
}

function Test-ELSIIngressConfigurationXml {
    param(
        [AllowNull()][string] $XmlText,
        [AllowNull()][string] $ExpectedHostFolder,
        [AllowNull()][string] $ExpectedSandboxFolder
    )

    if ([string]::IsNullOrWhiteSpace($XmlText)) { return 'XML_INVALID' }
    if ([string]::IsNullOrWhiteSpace($ExpectedHostFolder) -or
        [string]::IsNullOrWhiteSpace($ExpectedSandboxFolder)) { return 'PATH_UNVERIFIED' }
    if ($ExpectedSandboxFolder -cne 'C:\SandboxSyntheticIngress') { return 'UNSAFE_CONFIGURATION' }

    try {
        if (-not [System.IO.Path]::IsPathRooted($ExpectedHostFolder)) { return 'PATH_UNVERIFIED' }
        $expectedHost = [System.IO.Path]::GetFullPath($ExpectedHostFolder)
    }
    catch { return 'PATH_UNVERIFIED' }

    $settings = [System.Xml.XmlReaderSettings]::new()
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $settings.XmlResolver = $null
    $stringReader = $null
    $xmlReader = $null
    $document = [System.Xml.XmlDocument]::new()
    $document.XmlResolver = $null
    try {
        $stringReader = [System.IO.StringReader]::new($XmlText)
        $xmlReader = [System.Xml.XmlReader]::Create($stringReader, $settings)
        $document.Load($xmlReader)
    }
    catch { return 'XML_INVALID' }
    finally {
        if ($null -ne $xmlReader) { $xmlReader.Dispose() }
        if ($null -ne $stringReader) { $stringReader.Dispose() }
    }

    if ($document.ChildNodes.Count -ne 1 -or
        $document.DocumentElement.LocalName -cne 'Configuration' -or
        $document.DocumentElement.NamespaceURI -cne '' -or
        $document.DocumentElement.Attributes.Count -ne 0) { return 'UNSAFE_CONFIGURATION' }

    $root = $document.DocumentElement
    $expectedOrder = @('vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection', 'ProtectedClient', 'MappedFolders')
    $elements = [System.Collections.Generic.List[System.Xml.XmlElement]]::new()
    foreach ($node in $root.ChildNodes) {
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            if ($node.LocalName -notin $expectedOrder -or $node.NamespaceURI -cne '' -or $node.Attributes.Count -ne 0) {
                return 'UNSAFE_CONFIGURATION'
            }
            $elements.Add([System.Xml.XmlElement]$node)
            continue
        }
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Text -and [string]::IsNullOrWhiteSpace($node.Value)) { continue }
        if ($node.NodeType -in @([System.Xml.XmlNodeType]::Whitespace, [System.Xml.XmlNodeType]::SignificantWhitespace)) { continue }
        return 'UNSAFE_CONFIGURATION'
    }
    if ($elements.Count -ne $expectedOrder.Count) { return 'UNSAFE_CONFIGURATION' }

    for ($index = 0; $index -lt $expectedOrder.Count - 1; $index++) {
        $element = $elements[$index]
        if ($element.LocalName -cne $expectedOrder[$index] -or $element.ChildNodes.Count -ne 1 -or
            $element.FirstChild.NodeType -ne [System.Xml.XmlNodeType]::Text) { return 'UNSAFE_CONFIGURATION' }
        $expectedValue = switch -CaseSensitive ($expectedOrder[$index]) {
            'ProtectedClient' { 'Enable' }
            default { 'Disable' }
        }
        if ($element.InnerText -cne $expectedValue) { return 'UNSAFE_CONFIGURATION' }
    }

    $mappedFolders = $elements[$expectedOrder.Count - 1]
    if ($mappedFolders.LocalName -cne 'MappedFolders' -or $mappedFolders.Attributes.Count -ne 0 -or
        $mappedFolders.ChildNodes.Count -ne 1) { return 'UNSAFE_CONFIGURATION' }
    $mappedFolder = $mappedFolders.FirstChild
    if ($mappedFolder.NodeType -ne [System.Xml.XmlNodeType]::Element -or
        $mappedFolder.LocalName -cne 'MappedFolder' -or $mappedFolder.NamespaceURI -cne '' -or
        $mappedFolder.Attributes.Count -ne 0 -or $mappedFolder.ChildNodes.Count -ne 3) { return 'UNSAFE_CONFIGURATION' }

    $mappedNames = @('HostFolder', 'SandboxFolder', 'ReadOnly')
    $mappedExpected = @($expectedHost, $ExpectedSandboxFolder, 'true')
    for ($index = 0; $index -lt $mappedNames.Count; $index++) {
        $node = $mappedFolder.ChildNodes[$index]
        if ($node.NodeType -ne [System.Xml.XmlNodeType]::Element -or
            $node.LocalName -cne $mappedNames[$index] -or $node.NamespaceURI -cne '' -or
            $node.Attributes.Count -ne 0 -or $node.ChildNodes.Count -ne 1 -or
            $node.FirstChild.NodeType -ne [System.Xml.XmlNodeType]::Text) { return 'UNSAFE_CONFIGURATION' }

        if ($mappedNames[$index] -eq 'HostFolder') {
            try {
                if (-not [System.IO.Path]::IsPathRooted($node.InnerText)) { return 'PATH_UNVERIFIED' }
                $actualHost = [System.IO.Path]::GetFullPath($node.InnerText)
            }
            catch { return 'PATH_UNVERIFIED' }
            if (-not [string]::Equals($actualHost, $mappedExpected[$index], [System.StringComparison]::OrdinalIgnoreCase)) {
                return 'PATH_ESCAPE'
            }
        }
        elseif ($node.InnerText -cne $mappedExpected[$index]) { return 'UNSAFE_CONFIGURATION' }
    }

    return 'NONE'
}

function Get-ELSIIngressSafeOutput {
    param(
        [Parameter(Mandatory)][ValidateSet('PREPARED', 'BLOCKED', 'FAIL')][string] $Status,
        [Parameter(Mandatory)][ValidateSet('NONE', 'TARGET_EXISTS', 'PATH_UNVERIFIED', 'PATH_ESCAPE', 'CREATE_ERROR', 'XML_INVALID', 'UNSAFE_CONFIGURATION', 'HOST_UNSUPPORTED', 'ELEVATED_SESSION')][string] $Category
    )

    $payloadStatus = if ($Status -eq 'PREPARED') { 'SYNTHETIC_MARKER_ONLY' } else { 'NOT_CONFIRMED' }
    $mappingStatus = if ($Status -eq 'PREPARED') { 'READ_ONLY_ONE_FOLDER' } else { 'NOT_CONFIRMED' }
    $networkingStatus = if ($Status -eq 'PREPARED') { 'DISABLED_IN_CONFIG' } else { 'NOT_CONFIRMED' }
    return @(
        "STATUS=$Status",
        "ERROR_CATEGORY=$Category",
        "PAYLOAD=$payloadStatus",
        "MAPPING=$mappingStatus",
        "NETWORKING=$networkingStatus",
        'GUEST_LAUNCH=NOT_ATTEMPTED',
        'TEST_ACCESS=NONE',
        'PRODUCTION_ACCESS=NONE',
        'NEXT=WAIT_FOR_SEPARATE_AUDIT_AND_OPERATOR_LAUNCH'
    )
}

function Test-ELSIPathChainNoReparsePoints {
    param([Parameter(Mandatory)][string] $Path)

    try {
        $fullPath = [System.IO.Path]::GetFullPath($Path)
        $root = [System.IO.Path]::GetPathRoot($fullPath)
        if ([string]::IsNullOrWhiteSpace($root) -or $root -notmatch '^[A-Za-z]:\\$') { return $false }
        $current = $root
        $rootAttributes = [System.IO.File]::GetAttributes($current)
        if (($rootAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
            ($rootAttributes -band [System.IO.FileAttributes]::Directory) -eq 0) { return $false }

        $relative = $fullPath.Substring($root.Length)
        foreach ($segment in @($relative -split '[\\/]+' | Where-Object { $_.Length -gt 0 })) {
            $current = [System.IO.Path]::Combine($current, $segment)
            $attributes = [System.IO.File]::GetAttributes($current)
            if (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
                ($attributes -band [System.IO.FileAttributes]::Directory) -eq 0) { return $false }
        }
        return $true
    }
    catch { return $false }
}

function Get-ELSIExistingPathObservation {
    param([Parameter(Mandatory)][string] $Path)

    try {
        $attributes = [System.IO.File]::GetAttributes($Path)
        return [pscustomobject]@{
            Exists = $true
            IsReparsePoint = (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
        }
    }
    catch [System.IO.FileNotFoundException] {
        return [pscustomobject]@{ Exists = $false; IsReparsePoint = $false }
    }
    catch [System.IO.DirectoryNotFoundException] {
        return [pscustomobject]@{ Exists = $false; IsReparsePoint = $false }
    }
    catch { throw 'PATH_UNVERIFIED' }
}

function New-ELSIIngressDirectoryExclusive {
    param([Parameter(Mandatory)][string] $Path)

    $type = 'ELSI.SyntheticIngressNative' -as [type]
    if ($null -eq $type) {
        $source = @'
using System;
using System.Runtime.InteropServices;
namespace ELSI {
    public static class SyntheticIngressNative {
        [DllImport("kernel32.dll", EntryPoint="CreateDirectoryW", CharSet=CharSet.Unicode, SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool CreateDirectory(string path, IntPtr securityAttributes);
    }
}
'@
        Add-Type -TypeDefinition $source -ErrorAction Stop
        $type = 'ELSI.SyntheticIngressNative' -as [type]
    }
    if ($null -eq $type) { throw 'CREATE_ERROR' }
    if (-not $type::CreateDirectory($Path, [IntPtr]::Zero)) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if ($errorCode -in @(80, 183)) { throw 'TARGET_EXISTS' }
        throw 'CREATE_ERROR'
    }
}

function Write-ELSIIngressNewFile {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Content
    )

    $stream = $null
    $writer = $null
    try {
        $stream = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        $encoding = [System.Text.UTF8Encoding]::new($false)
        $writer = [System.IO.StreamWriter]::new($stream, $encoding)
        $stream = $null
        $writer.Write($Content)
        $writer.Flush()
    }
    finally {
        if ($null -ne $writer) { $writer.Dispose() }
        if ($null -ne $stream) { $stream.Dispose() }
    }
}

function Get-ELSIHostRunGate {
    if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        return 'HOST_UNSUPPORTED'
    }
    $identity = $null
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        if ($null -eq $identity) { return 'PATH_UNVERIFIED' }
        $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
        if ($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) { return 'ELEVATED_SESSION' }
        return 'NONE'
    }
    catch { return 'PATH_UNVERIFIED' }
    finally { if ($null -ne $identity) { $identity.Dispose() } }
}

$hostGate = 'PATH_UNVERIFIED'
try { $hostGate = Get-ELSIHostRunGate } catch { $hostGate = 'PATH_UNVERIFIED' }
if ($hostGate -ne 'NONE') {
    $status = if ($hostGate -in @('HOST_UNSUPPORTED', 'ELEVATED_SESSION')) { 'BLOCKED' } else { 'BLOCKED' }
    $category = if ($hostGate -in @('HOST_UNSUPPORTED', 'ELEVATED_SESSION')) { $hostGate } else { 'PATH_UNVERIFIED' }
    Get-ELSIIngressSafeOutput -Status $status -Category $category
    return
}

try {
    $basePath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
    if ([string]::IsNullOrWhiteSpace($basePath) -or -not (Test-ELSIPathChainNoReparsePoints -Path $basePath)) {
        Get-ELSIIngressSafeOutput -Status 'BLOCKED' -Category 'PATH_UNVERIFIED'
        return
    }

    $basePath = [System.IO.Path]::GetFullPath($basePath)
    $targetPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($basePath, 'ELSI-Sandbox-Synthetic-Ingress-022'))
    $payloadPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($targetPath, 'payload'))
    $targetObservation = Get-ELSIExistingPathObservation -Path $targetPath
    $payloadObservation = if ($targetObservation.Exists) { Get-ELSIExistingPathObservation -Path $payloadPath } else { [pscustomobject]@{ Exists = $false; IsReparsePoint = $false } }
    $eligibility = Test-ELSIIngressPathEligibility -LocalApplicationDataPath $basePath -TargetPath $targetPath -PayloadPath $payloadPath `
        -BaseExists $true -BaseIsDirectory $true -BaseIsReparsePoint $false `
        -TargetExists $targetObservation.Exists -TargetIsReparsePoint $targetObservation.IsReparsePoint `
        -PayloadExists $payloadObservation.Exists -PayloadIsReparsePoint $payloadObservation.IsReparsePoint
    if ($eligibility -ne 'NONE') {
        $status = if ($eligibility -eq 'TARGET_EXISTS') { 'BLOCKED' } else { 'BLOCKED' }
        $category = if ($eligibility -in @('TARGET_EXISTS', 'PATH_UNVERIFIED', 'PATH_ESCAPE')) { $eligibility } else { 'PATH_UNVERIFIED' }
        Get-ELSIIngressSafeOutput -Status $status -Category $category
        return
    }

    New-ELSIIngressDirectoryExclusive -Path $targetPath
    if (-not (Test-ELSIPathChainNoReparsePoints -Path $targetPath)) { throw 'PATH_UNVERIFIED' }
    New-ELSIIngressDirectoryExclusive -Path $payloadPath
    if (-not (Test-ELSIPathChainNoReparsePoints -Path $payloadPath)) { throw 'PATH_UNVERIFIED' }

    Write-ELSIIngressNewFile -Path ([System.IO.Path]::Combine($payloadPath, 'ELSI_SANDBOX_SYNTHETIC_INGRESS_ONLY.txt')) `
        -Content 'ELSI_SANDBOX_SYNTHETIC_INGRESS_ONLY'
    $sandboxFolder = 'C:\SandboxSyntheticIngress'
    $xml = New-ELSIIngressConfigurationXml -HostFolder $payloadPath -SandboxFolder $sandboxFolder
    if ($null -eq $xml -or (Test-ELSIIngressConfigurationXml -XmlText $xml -ExpectedHostFolder $payloadPath -ExpectedSandboxFolder $sandboxFolder) -ne 'NONE') {
        throw 'XML_INVALID'
    }
    Write-ELSIIngressNewFile -Path ([System.IO.Path]::Combine($targetPath, 'ELSI_SYNTHETIC_INGRESS_022.wsb')) -Content $xml
    Get-ELSIIngressSafeOutput -Status 'PREPARED' -Category 'NONE'
}
catch {
    $category = 'CREATE_ERROR'
    if ($_.Exception.Message -ceq 'PATH_UNVERIFIED') { $category = 'PATH_UNVERIFIED' }
    elseif ($_.Exception.Message -ceq 'PATH_ESCAPE') { $category = 'PATH_ESCAPE' }
    elseif ($_.Exception.Message -ceq 'TARGET_EXISTS') { $category = 'TARGET_EXISTS' }
    elseif ($_.Exception.Message -ceq 'XML_INVALID') { $category = 'XML_INVALID' }
    Get-ELSIIngressSafeOutput -Status 'FAIL' -Category $category
}
