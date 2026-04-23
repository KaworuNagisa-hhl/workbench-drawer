# OpenHarmony 三方库发布检查清单

## 必备文件

- `oh-package.json5`
- `Index.ets`
- `README.md`
- `USAGE_GUIDE.md`
- `CHANGELOG.md`
- `LICENSE`
- `src/main/module.json5`

## 元数据检查

- `name` 使用唯一包名，发布前请确认不会与 ohpm 现有包重名。
- `version` 遵循 SemVer，例如 `1.0.1`。
- README 兼容性说明与 HAR 发布元数据一致，当前为 HarmonyOS API 12。
- `main` 指向 `Index.ets`。
- `license` 与根目录 `LICENSE` 保持一致。
- `description`、`keywords` 清晰说明组件用途。

## 代码检查

- 不引用宿主工程业务接口。
- 不引用宿主工程私有资源 `$r('app.xxx')`。
- 不包含调试日志、账号、密钥、业务域名。
- 对外 API 统一从 `Index.ets` 导出。

## 发布建议

- 发布前在独立 Demo 工程中通过 `file:../drawer` 安装验证。
- 执行平台要求的 ohpm 本地校验或 dry-run。
- README 中保持安装、导入、默认用法、自定义用法、API 表完整。
