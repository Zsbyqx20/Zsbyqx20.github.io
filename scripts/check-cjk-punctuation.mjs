import assert from 'node:assert/strict';

import {
  getSupplementalTrimIndexes,
  resolveCjkPunctuationProfile,
} from '../themes/zacharite/assets/js/cjk-punctuation.mjs';

const profile = resolveCjkPunctuationProfile('zh-CN', 'horizontal-tb');
assert.ok(profile, 'Expected a simplified Chinese horizontal punctuation profile');
assert.equal(resolveCjkPunctuationProfile('zh-TW', 'horizontal-tb'), null);
assert.equal(resolveCjkPunctuationProfile('zh-CN', 'vertical-rl'), null);

const cases = [
  ['\uff01\u201d', [0]],
  ['\uff1f\u201d', [0]],
  ['\u201d\uff01', [0]],
  ['\uff01\uff1f', [0]],
  ['\uff01\uff01\uff01', [0, 1]],
  ['\uff01\u201c', [1]],
  ['\u201c\uff01', []],
  ['\u201d\uff09', [0]],
  ['\uff09\uff0c', [0]],
  ['\uff09\u3002', [0]],
  ['\u3011\uff1b', [0]],
  ['\u300b\uff1f', [0]],
  ['\uff09\u201c', [1]],
  ['\uff09A', []],
  ['\uff01A', []],
];

cases.forEach(([text, expected]) => {
  assert.deepEqual(
    getSupplementalTrimIndexes(Array.from(text), profile),
    expected,
    `Unexpected trim indexes for ${JSON.stringify(text)}`
  );
});

assert.deepEqual(
  getSupplementalTrimIndexes(['\uff01', null, '\u201d'], profile),
  [],
  'A layout boundary must stop punctuation pairing'
);

console.log('CJK punctuation rule checks passed.');
