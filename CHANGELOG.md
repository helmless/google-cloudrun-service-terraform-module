# Changelog

## [0.1.2](https://github.com/helmless/google-cloudrun-service-terraform-module/compare/v0.1.1...v0.1.2) (2025-03-26)


### Bug Fixes

* **deps:** update Google provider from 6.12.0 to 6.27.0 ([#5](https://github.com/helmless/google-cloudrun-service-terraform-module/issues/5)) ([9cda275](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/9cda275c50df246789264a5b3f432943d27bf419))
* ignore terraform lock ([#6](https://github.com/helmless/google-cloudrun-service-terraform-module/issues/6)) ([d54081e](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/d54081e792e028d42d12d68e90a4b3cce5d623c3))
* service account and iam permission handling ([#3](https://github.com/helmless/google-cloudrun-service-terraform-module/issues/3)) ([d51299d](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/d51299d7a479f24ce54d619618b94daaddec77d1))

## [0.1.1](https://github.com/helmless/google-cloudrun-service-terraform-module/compare/v0.1.0...v0.1.1) (2024-12-04)


### Bug Fixes

* **example:** use local module ref in example ([65f4755](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/65f475506bf5b4f651c7c82e63bd9bdf24c8fd90))
* **iam:** use correct serviceAccountUser role with actAs for deployments ([5728e30](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/5728e30f0999d26dacf6997af3a0bf81fc50e65f))

## 0.1.0 (2024-11-19)


### Features

* add deployment_accounts input to give correct deployment permissions ([3011275](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/3011275795620249c960640f32f2dcff9799ef9f))
* initial commit of cloud run service tf module ([84d1410](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/84d14103c89a1bfed1e09afdcf239c4cef8e503b))


### Bug Fixes

* add deletion protection flag ([68b44f4](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/68b44f42a4981c902b49768d243a6f726a1bff3b))
* **iam:** actually use the flat lists ([ff06293](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/ff062937b45b9b1d10f00062f8685e2c2c8359d4))
* **iam:** set region when binding iam policies to service ([e9e1925](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/e9e19251e7217e6ed8570a426fde75d4ba8f60f2))
* **iam:** use index for role map ([f0d78e2](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/f0d78e202d7f83efe845b6c9721a0bd6645ee31e))
* **iam:** use local deployment account map instead of var ([6740bbf](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/6740bbf8c180441629840064bbf114e10b303adf))
* linting and formatting ([13ba35d](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/13ba35df3b3ecd99af92e30e50826771fcd1a12d))
* use correct iam map for bindings ([26304ae](https://github.com/helmless/google-cloudrun-service-terraform-module/commit/26304ae79a9866385cfc20df51d626056b1d9c1e))
