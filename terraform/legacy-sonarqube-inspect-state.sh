#!/usr/bin/env bash
set -euo pipefail
STATE_JSON="/tmp/sonarqube-old-state.json"
aws s3 cp "s3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate" "$STATE_JSON" --only-show-errors
node - "$STATE_JSON" <<'NODE'
const fs=require('fs');
const s=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
for (const r of s.resources||[]) {
  const mod=r.module||'root';
  for (const i of r.instances||[]) {
    const a=i.attributes||{};
    console.log(`${mod} :: ${r.type}.${r.name} :: id=${a.id||''} :: name=${a.name||''}`);
  }
}
NODE
