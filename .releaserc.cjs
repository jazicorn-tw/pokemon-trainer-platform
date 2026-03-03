/**
 * semantic-release config (JS so we can use functions + comments)
 *
 * Notes strategy:
 * - Generate "changelog notes" first (rich, hash + nice headers)
 * - Update CHANGELOG.md with those notes
 * - Generate "GitHub notes" second (cleaner / shorter)
 * - Publish GitHub Release using the GitHub notes
 *
 * This lets CHANGELOG.md be dev-traceable while GitHub Releases stay reader-friendly.
 */
'use strict';

const isCI = Boolean(process.env.CI);

const OTHER_SECTION = '🧩 Other';

const SECTION_TITLES = {
  feat: '✨ Features',
  fix: '🐛 Fixes',
  perf: '⚡ Performance',
  test: '✅ Tests',
  build: '📦 Build',
  ci: '🤖 CI / CD',
  chore: '🧹 Chores',
  style: '💄 Style',
  refactor: '♻️ Refactors',  
  docs: '📝 Docs',
  post: '✉️ Posts',
};

// Order groups exactly as declared above, and always render "Other" last.
const GROUP_ORDER = Object.values(SECTION_TITLES);

const ALLOWED_TYPES_FOR_NOTES = new Set(Object.keys(SECTION_TITLES));

/**
 * Notes transform policy
 * - Skips merge commits entirely
 * - Skips commits with no subject (prevents empty bullets)
 * - Routes unknown/missing types into the "Other" group
 * - Returns a NEW object (immutable-safe)
 */
function baseTransform(commit) {
  // conventional-commits-parser sets commit.merge for merge commits
  if (commit.merge || /^Merge\b/i.test(commit.subject || '')) return;

  const subject = (commit.subject || '').trim();
  if (!subject) return;

  const rawType = (commit.type || '').trim();
  const normalizedType =
    rawType && ALLOWED_TYPES_FOR_NOTES.has(rawType) ? rawType : 'other';

  return {
    ...commit,
    subject,
    type:
      normalizedType === 'other'
        ? OTHER_SECTION
        : SECTION_TITLES[normalizedType],
    shortHash: commit.hash?.slice(0, 7),
  };
}

function commitGroupsSort(a, b) {
  // Always last
  if (a.title === OTHER_SECTION && b.title !== OTHER_SECTION) return 1;
  if (a.title !== OTHER_SECTION && b.title === OTHER_SECTION) return -1;

  // Order by SECTION_TITLES placement
  const ai = GROUP_ORDER.indexOf(a.title);
  const bi = GROUP_ORDER.indexOf(b.title);

  // Known groups first, in declared order
  if (ai !== -1 && bi !== -1) return ai - bi;

  // If one is known and the other isn't, known wins
  if (ai !== -1 && bi === -1) return -1;
  if (ai === -1 && bi !== -1) return 1;

  // Fallback
  return a.title.localeCompare(b.title);
}

/**
 * We set mainTemplate explicitly because the preset defaults sometimes flatten output.
 * This forces section headers and deterministic ordering.
 */
const changelogMainTemplate = [
  '## 📦 Release {{version}}',
  '',
  '{{#each commitGroups}}',
  '### {{title}}',
  '',
  '{{#each commits}}',
  '{{> commit}}',
  '{{/each}}',
  '',
  '{{/each}}',
].join('\n');

const githubMainTemplate = [
  '## {{version}}',
  '',
  '{{#each commitGroups}}',
  '### {{title}}',
  '',
  '{{#each commits}}',
  '{{> commit}}',
  '{{/each}}',
  '',
  '{{/each}}',
].join('\n');

/** Rich notes used for CHANGELOG.md */
const changelogWriterOpts = {
  groupBy: 'type',
  commitGroupsSort,
  commitsSort: ['scope', 'subject'],
  transform: baseTransform,

  mainTemplate: changelogMainTemplate,

  // IMPORTANT: include newline so bullets don't run together
  commitPartial:
    '- {{#if scope}}**{{scope}}:** {{/if}}{{subject}} ({{shortHash}})\n',
};

/** Cleaner notes used for GitHub Releases */
const githubWriterOpts = {
  groupBy: 'type',
  commitGroupsSort,
  commitsSort: ['scope', 'subject'],

  transform: (commit) => {
    const c = baseTransform(commit);
    if (!c) return;

    // Remove hash-related fields so commitPartial can't accidentally use them
    const { shortHash, ...rest } = c;
    return rest;
  },

  mainTemplate: githubMainTemplate,

  // IMPORTANT: include newline so bullets don't run together
  commitPartial: '- {{#if scope}}**{{scope}}:** {{/if}}{{subject}}\n',
};

module.exports = {
  branches: ['main'],
  tagFormat: 'v${version}',
  plugins: [
    // 1) Decide version bump based on commits
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { breaking: true, release: 'major' },
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'perf', release: 'patch' },

          // Everything else: no release bump
          { type: 'refactor', release: false },
          { type: 'docs', release: false },
          { type: 'chore', release: false },
          { type: 'test', release: false },
          { type: 'ci', release: false },
          { type: 'style', release: false },
          { type: 'build', release: false },
        ],
      },
    ],

    // 2a) Generate CHANGELOG-oriented notes
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        writerOpts: changelogWriterOpts,
      },
    ],

    // 3) Update CHANGELOG.md (uses the notes generated immediately above)
    [
      '@semantic-release/changelog',
      {
        changelogFile: 'CHANGELOG.md',
        changelogTitle: '# 📦 Release History',
      },
    ],

    // 2b) Re-generate notes for GitHub Releases (cleaner)
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        writerOpts: githubWriterOpts,
      },
    ],

    // 4) Build artifacts (bootJar)
    [
      '@semantic-release/exec',
      {
        prepareCmd:
          "./gradlew --no-daemon --gradle-user-home $GRADLE_USER_HOME -PreleaseVersion=${nextRelease.version} clean bootJar",
      },
    ],

    // 5) Publish GitHub Release + upload assets (CI only)
    ...(isCI
      ? [
          [
            '@semantic-release/github',
            {
              assets: [
                {
                  path: 'build/libs/*.jar',
                  label: 'Spring Boot JAR (bootJar)',
                },
              ],
            },
          ],
        ]
      : []),

    // 6) Commit CHANGELOG.md back to the repo
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md'],
        message: 'chore(release): ${nextRelease.version} [skip ci]',
      },
    ],
  ],
};
