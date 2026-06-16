import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const repoRoot = resolve(process.cwd());
const indexPath = resolve(repoRoot, 'spill_flutter/web/index.html');
const shouldInject = process.argv.includes('--inject');
const placeholder = '__MAPS_API_KEY__';

const raw = readFileSync(indexPath, 'utf8');
const key = process.env.GOOGLE_API_KEY;

if (!key) {
  throw new Error(
    'Missing GOOGLE_API_KEY in .env. Cannot configure Maps JavaScript API key.'
  );
}

if (!shouldInject) {
  if (!raw.includes(placeholder)) {
    throw new Error(
      'Expected placeholder key in spill_flutter/web/index.html. Restore __MAPS_API_KEY__ before committing.'
    );
  }

  console.log('Validated GOOGLE_API_KEY and placeholder template in spill_flutter/web/index.html');
  process.exit(0);
}

const next = raw.replace(/key=[^&"']+/, `key=${key}`);

if (next === raw) {
  throw new Error('Could not inject Maps key into spill_flutter/web/index.html');
}

writeFileSync(indexPath, next, 'utf8');
console.log('Injected GOOGLE_API_KEY into spill_flutter/web/index.html for runtime');
