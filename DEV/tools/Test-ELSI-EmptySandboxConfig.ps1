Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-ELSIEmptySandboxXml {
    param([Parameter(Mandatory)][string] $XmlText)

    $expected = [ordered]@{
        vGPU = 'Disable'
        Networking = 'Disable'
        AudioInput = 'Disable'
        VideoInput = 'Disable'
        PrinterRedirection = 'Disable'
        ClipboardRedirection = 'Disable'
        ProtectedClient = 'Enable'
    }
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
    catch {
        return 'XML_INVALID'
    }
    finally {
        if ($null -ne $xmlReader) { $xmlReader.Dispose() }
        if ($null -ne $stringReader) { $stringReader.Dispose() }
    }

    if ($document.ChildNodes.Count -ne 1 -or $document.DocumentElement.LocalName -cne 'Configuration' -or
        $document.DocumentElement.NamespaceURI -cne '' -or $document.DocumentElement.Attributes.Count -ne 0) {
        return 'UNSAFE_ELEMENTS'
    }

    $root = $document.DocumentElement
    $elements = [System.Collections.Generic.List[System.Xml.XmlElement]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($node in $root.ChildNodes) {
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            if ($node.LocalName -notin $expected.Keys -or $node.NamespaceURI -cne '' -or $node.Attributes.Count -ne 0 -or -not $seen.Add($node.LocalName)) {
                return 'UNSAFE_ELEMENTS'
            }
            $elements.Add([System.Xml.XmlElement]$node)
            continue
        }
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Text -and -not [string]::IsNullOrWhiteSpace($node.Value)) {
            return 'UNSAFE_ELEMENTS'
        }
        if ($node.NodeType -notin @([System.Xml.XmlNodeType]::Whitespace, [System.Xml.XmlNodeType]::SignificantWhitespace, [System.Xml.XmlNodeType]::Text)) {
            return 'UNSAFE_ELEMENTS'
        }
    }
    if ($elements.Count -ne $expected.Count) { return 'MISSING_FIELD' }

    $index = 0
    foreach ($entry in $expected.GetEnumerator()) {
        $element = $elements[$index]
        if ($element.LocalName -cne $entry.Key) { return 'MISSING_FIELD' }
        if ($element.ChildNodes.Count -ne 1 -or $element.FirstChild.NodeType -ne [System.Xml.XmlNodeType]::Text -or $element.InnerText -cne $entry.Value) {
            return 'UNSAFE_ELEMENTS'
        }
        $index++
    }
    return 'NONE'
}

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$configPath = Join-Path $repositoryRoot 'DEV\config\ELSI_EMPTY_OFFLINE_SANDBOX.wsb'
try {
    $xmlText = [System.IO.File]::ReadAllText($configPath, [System.Text.Encoding]::UTF8)
    $category = Test-ELSIEmptySandboxXml -XmlText $xmlText
}
catch {
    $category = 'READ_ERROR'
}

if ($category -eq 'NONE') {
    'STATUS=PASS'
    'ERROR_CATEGORY=NONE'
}
else {
    'STATUS=FAIL'
    "ERROR_CATEGORY=$category"
}
