import type { UserConfig } from '@commitlint/types';

// Headers in this repo carry an emoji before the conventional type, as in
// `✨ feat(zsh): add mfeserve`. The default parser reads the emoji as the type
// and leaves both the real type and the subject empty, so the header needs its
// own pattern. The emoji is optional: a plain `refactor: ...` header is valid.
const emoji = String.raw`(?:[\p{Extended_Pictographic}\u{FE0F}\u{200D}]+\s*)?`;

const Configuration: UserConfig = {
  extends: ['@commitlint/config-conventional'],
  parserPreset: {
    parserOpts: {
      headerPattern: new RegExp(`^${emoji}(\\w+)(?:\\(([^)]*)\\))?!?: (.+)$`, 'u'),
      breakingHeaderPattern: new RegExp(`^${emoji}(\\w+)(?:\\(([^)]*)\\))?!: (.+)$`, 'u'),
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },
  rules: {
    'header-max-length': [2, 'always', 72],
  },
};

export default Configuration;
