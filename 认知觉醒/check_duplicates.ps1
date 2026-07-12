$base = 'E:\PublicSpaceGit\FlowusCognitiveWakeUp\认知觉醒'
$exts = @('.pdf','.mp3','.md')
$results = @{}

foreach ($ext in $exts) {
    $files = Get-ChildItem -Path $base -Recurse -File | Where-Object { $_.Extension.ToLower() -eq $ext }
    $groups = $files | Group-Object { $_.Name.ToLower() } | Where-Object { $_.Count -gt 1 }
    $results[$ext] = $groups
}

# Build markdown content
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# 文件名重复检查报告")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("扫描目录：`E:\PublicSpaceGit\FlowusCognitiveWakeUp\认知觉醒`")
[void]$sb.AppendLine("扫描时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("检查类型：.pdf / .mp3 / .md（后缀名不分大小写）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

$totalDupGroups = 0

foreach ($ext in $exts) {
    $groups = $results[$ext]
    $allFiles = Get-ChildItem -Path $base -Recurse -File | Where-Object { $_.Extension.ToLower() -eq $ext }
    $totalFiles = $allFiles.Count
    
    [void]$sb.AppendLine("## $ext 文件（共 $totalFiles 个）")
    [void]$sb.AppendLine("")
    
    if ($groups.Count -eq 0) {
        [void]$sb.AppendLine("无重复文件名。")
    } else {
        [void]$sb.AppendLine("发现 **$($groups.Count)** 组重复文件名：")
        [void]$sb.AppendLine("")
        
        $i = 1
        foreach ($g in $groups) {
            [void]$sb.AppendLine("### 第 $i 组：$($g.Name)")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("| 序号 | 完整路径 |")
            [void]$sb.AppendLine("|------|----------|")
            $j = 1
            foreach ($f in $g.Group) {
                [void]$sb.AppendLine("| $j | ``$($f.FullName)`` |")
                $j++
            }
            [void]$sb.AppendLine("")
            $i++
        }
        $totalDupGroups += $groups.Count
    }
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
}

# Summary
[void]$sb.AppendLine("## 汇总")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- 共发现 **$totalDupGroups** 组重复文件名")
[void]$sb.AppendLine("")

$outputPath = Join-Path $base "文件名重复检查报告.md"
$sb.ToString() | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Done. Output: $outputPath"
Write-Host "Total duplicate groups: $totalDupGroups"
