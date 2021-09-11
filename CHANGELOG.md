### Changelog

All notable changes to this project will be documented in this file. Dates are displayed in UTC.

#### [v1.2.0](https://github.com/Dandula/power-docker/compare/v1.1.5...v1.2.0)

> 5 Sep 2021

- feat(scripts): added scripts for linking to hosts file [`3e6e901`](https://github.com/Dandula/power-docker/commit/3e6e901e02ed1b466036dc6dc480a7773eb31162)
- feat: added functionality for configuring a set of services [`e7c2ced`](https://github.com/Dandula/power-docker/commit/e7c2ced277586b65d8d685702c65f56152798f38)
- feat: added mounting of external user folders [`03b3541`](https://github.com/Dandula/power-docker/commit/03b354153a1ce21896f06c10ea43e804912c96da)
- refactor(scripts): refactored scripts [`7f3adea`](https://github.com/Dandula/power-docker/commit/7f3adeaa98bef353429d07c50f3951274aba03df)
- feat(scripts): added yoda utility [`40493cc`](https://github.com/Dandula/power-docker/commit/40493cca46e271ab978d5b892f4651063970b0d9) 
- docs(readme): fixed docker compose files paths [`a7b1db3`](https://github.com/Dandula/power-docker/commit/a7b1db3ab8b099d722d5c04a65a116ff53b0d624)
- docs(changelog): added changelog

#### [v1.1.5](https://github.com/Dandula/power-docker/compare/v1.1.4...v1.1.5)

> 23 May 2021

- revert: back to common service for different php versions [`6893793`](https://github.com/Dandula/power-docker/commit/68937939a41f831dcc77edcc93e7dfd585d40598)
- docs(readme): added section about multiple versions of php [`5ec8a26`](https://github.com/Dandula/power-docker/commit/5ec8a26811345aab164cb41c64189ad8875bff39)

#### [v1.1.4](https://github.com/Dandula/power-docker/compare/v1.1.3...v1.1.4)

> 18 April 2021

- feat: removed the rebuild of images when user change the php version [`0b7e8d9`](https://github.com/Dandula/power-docker/commit/0b7e8d94c841e4bfb62bae936089e2ebca6e3f61)
- feat(pxp-ext): added php-intl [`bdc9c5b`](https://github.com/Dandula/power-docker/commit/bdc9c5b8fc21309b6736e2d61790c6ad093127e2)
- feat(certs): added a job to periodically update the ca root bundle [`6bd38dd`](https://github.com/Dandula/power-docker/commit/6bd38ddbae508a921c20947c08f437886ffed42b)
- docs(readme): added description for starting workspace after stopping [`f6bd60e`](https://github.com/Dandula/power-docker/commit/f6bd60e198d967eea80935e79aa09ba6d65b4852)

#### [v1.1.3](https://github.com/Dandula/power-docker/compare/v1.1.2...v1.1.3)

> 11 April 2021

- feat(certs): moved ssl certificates of hosts to ./data/certs/hosts [`01c84f5`](https://github.com/Dandula/power-docker/commit/01c84f57ce99bac43170286cf5c80915c7861747)
- feat(certs): added ca bundle [`bf837eb`](https://github.com/Dandula/power-docker/commit/bf837eb4c5e43a35a856cb3185ac8efe2f300639)
- fix(wsl): fixed script of making ssl certificate for wsl [`ed898fc`](https://github.com/Dandula/power-docker/commit/ed898fc79046f8e567dfbb44aa505d4543ff23ef)
- docs(readme): fixed newline and link to script at readme [`f4d0346`](https://github.com/Dandula/power-docker/commit/f4d03467c7991b0221211fccb352421bade3d7ef)
- feat(redis): added persistence redis storage [`f6dc0a6`](https://github.com/Dandula/power-docker/commit/f6dc0a663e349c7734a558af5fa9c600dd7ef8e5)

#### [v1.1.2](https://github.com/Dandula/power-docker/compare/v1.1.1...v1.1.2)

> 10 April 2021

- feat(scripts): improvement of init script [`e4f4f96`](https://github.com/Dandula/power-docker/commit/e4f4f9664384995723a4d8b945807a4e99922e7a)
- feat(packages): added ability to use cache by package managers [`9445430`](https://github.com/Dandula/power-docker/commit/9445430cf113b058ce307b5ecf186937d036ca7f)
- feat(pxp-ext): php extensions updated [`7aba615`](https://github.com/Dandula/power-docker/commit/7aba615ffc07f9782923ff07de01f89dbac02a64)
- docs(readme): added description of the cache directory [`19a7164`](https://github.com/Dandula/power-docker/commit/19a716442e2af846a7119d4da1314e0a916d4d26)

#### [v1.1.1](https://github.com/Dandula/power-docker/compare/v1.1.0...v1.1.1)

> 10 April 2021

- feat: added npm to php service [`c6afe8d`](https://github.com/Dandula/power-docker/commit/c6afe8d1e83d0cb63e70668d8f234ee8266d8459)
- docs: added a description of the php service programs [`fea6312`](https://github.com/Dandula/power-docker/commit/fea63124860acb4f6dd6e342679bd6924e27de5e)

#### [v1.1.0](https://github.com/Dandula/power-docker/compare/v1.0.0...v1.1.0)

> 28 March 2021

- feat(certs): added certificates support of ssh agent [`f7edac0`](https://github.com/Dandula/power-docker/commit/f7edac05f157bab29103e50122ce7de4f9aceec8)
- fix(schedule): fixed cron jobs [`345c3a5`](https://github.com/Dandula/power-docker/commit/345c3a569c9a6e5d0725c9e35168a513de150632)
- docs(certs): updated docs for ssh certificates functionality [`fd034e0`](https://github.com/Dandula/power-docker/commit/fd034e071e18d6b9f7497edb612b3b7f4f656e89)

#### v1.0.0

> 26 March 2021

- Initial commit [`e8edcb8`](https://github.com/Dandula/power-docker/commit/e8edcb86e4bdafe4a287dc8651603a3f533b90bb)