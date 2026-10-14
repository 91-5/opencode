#!/usr/bin/env node
// verify-hash.js — 独立复现 agent-os 协议 hash（供任何 agent 校验版本一致性）
//
// 口径（权威定义，与 version.json.hash_scope 一致）：
//   1. 读 AGENTS.md / TEAM_PROTOCOL.md / BOOTSTRAP-PROMPTS.md 三个文件
//   2. 每个文件内容按 UTF-8 解码后，剥离开头的 BOM（U+FEFF）——若有
//   3. 用分隔符 SEP = "\n---\n"（LF, 0x0A 0x2D 0x2D 0x2D 0x0A）依次拼接
//   4. 对拼接结果取 UTF-8 字节的 SHA-256，取十六进制前 16 位
//
// 用法：node verify-hash.js [包根目录，默认脚本所在目录]

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const base = process.argv[2] || __dirname;
const FILES = ['AGENTS.md', 'TEAM_PROTOCOL.md', 'BOOTSTRAP-PROMPTS.md'];
const SEP = String.fromCharCode(10) + '---' + String.fromCharCode(10); // LF + "---" + LF

const normalize = (p) => fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, '');

const material = FILES
  .map((f) => normalize(path.join(base, f)))
  .join(SEP);

const hash = 'sha256:' + crypto.createHash('sha256').update(material, 'utf8').digest('hex').slice(0, 16);

let declared = '(missing)';
try {
  declared = JSON.parse(normalize(path.join(base, 'version.json'))).hash;
} catch (e) {
  console.error('无法读取 version.json：' + e.message);
  process.exit(2);
}

console.log('计算值 hash : ' + hash);
console.log('声明值 hash : ' + declared);
if (hash === declared) {
  console.log('结果        : MATCH ✅  协议内容与版本声明一致');
  process.exit(0);
}
console.log('结果        : MISMATCH ❌  包内容已变更但未 bump version.json（或口径不符）');
process.exit(1);
