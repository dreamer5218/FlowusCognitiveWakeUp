import os
from collections import defaultdict
from datetime import datetime

base = r'E:\PublicSpaceGit\FlowusCognitiveWakeUp\认知觉醒'
exts = ['.pdf', '.mp3', '.md']

results = {}
for ext in exts:
    files = []
    for root, dirs, filenames in os.walk(base):
        for fn in filenames:
            if fn.lower().endswith(ext):
                files.append(os.path.join(root, fn))
    
    groups = defaultdict(list)
    for f in files:
        key = os.path.basename(f).lower()
        groups[key].append(f)
    
    duplicates = {k: v for k, v in groups.items() if len(v) > 1}
    results[ext] = (len(files), duplicates)

# Build markdown
lines = []
lines.append('# 文件名重复检查报告')
lines.append('')
lines.append(f'扫描目录：`{base}`')
lines.append(f'扫描时间：{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
lines.append('检查类型：.pdf / .mp3 / .md（后缀名不分大小写）')
lines.append('')
lines.append('---')
lines.append('')

total_dup_groups = 0

for ext in exts:
    total_files, duplicates = results[ext]
    lines.append(f'## {ext} 文件（共 {total_files} 个）')
    lines.append('')
    
    if not duplicates:
        lines.append('无重复文件名。')
    else:
        lines.append(f'发现 **{len(duplicates)}** 组重复文件名：')
        lines.append('')
        
        i = 1
        for name, paths in sorted(duplicates.items()):
            lines.append(f'### 第 {i} 组：{name}')
            lines.append('')
            lines.append('| 序号 | 完整路径 |')
            lines.append('|------|----------|')
            for j, p in enumerate(paths, 1):
                lines.append(f'| {j} | `{p}` |')
            lines.append('')
            i += 1
        total_dup_groups += len(duplicates)
    
    lines.append('---')
    lines.append('')

lines.append('## 汇总')
lines.append('')
lines.append(f'- 共发现 **{total_dup_groups}** 组重复文件名')
lines.append('')

output_path = os.path.join(base, '文件名重复检查报告.md')
with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print(f'Done. Output: {output_path}')
print(f'Total duplicate groups: {total_dup_groups}')

# Also print summary to console
for ext in exts:
    total_files, duplicates = results[ext]
    print(f'{ext}: {total_files} files, {len(duplicates)} duplicate groups')
    for name, paths in sorted(duplicates.items()):
        print(f'  [{name}]')
        for p in paths:
            print(f'    {p}')
