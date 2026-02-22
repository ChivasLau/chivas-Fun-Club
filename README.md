# 华仔趣玩社

iOS 工具箱应用，专为 iPad Air 1代 (iOS 12) 设计。

## 🚀 快速开始（无需 Mac）

### 方法：GitHub 云构建（推荐）

**完全免费** - 公开仓库无分钟限制

#### 步骤 1：创建 GitHub 仓库

```
1. 登录 github.com
2. 点击 New Repository
3. 仓库名: huazai-quwan
4. 选择 Public（公开）
5. 点击 Create repository
```

#### 步骤 2：上传代码

**方法 A - 网页上传（最简单）：**
```
1. 进入你的仓库页面
2. 点击 "Add file" → "Upload files"
3. 将整个 华仔趣玩社 文件夹拖入
4. 点击 "Commit changes"
```

**方法 B - Git 命令行：**
```bash
cd 华仔趣玩社
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/huazai-quwan.git
git push -u origin main
```

#### 步骤 3：等待自动构建

```
1. 进入仓库 → Actions 标签
2. 等待构建完成（约5-10分钟）
3. 点击完成的 workflow
4. 在 Artifacts 中下载 "华仔趣玩社-unsigned-IPA"
5. 解压得到 .ipa 文件
```

#### 步骤 4：安装到 iPad

使用 **Sideloadly**（Windows/Mac 均可）：
```
1. 下载安装 https://sideloadly.io
2. iPad 连接电脑
3. 拖入 .ipa 文件
4. 输入 Apple ID
5. 点击 Start 安装
```

---

## 📁 项目结构

```
华仔趣玩社/
├── .github/workflows/build.yml    # GitHub Actions 云构建配置
├── 华仔趣玩社/
│   ├── AppDelegate.swift          # 应用入口
│   ├── Controllers/
│   │   ├── MainTabBarController.swift
│   │   ├── QuKanViewController.swift   # 趣看（WebView）
│   │   ├── QuWanViewController.swift
│   │   ├── QuZuoViewController.swift
│   │   └── QuDuViewController.swift
│   ├── Views/
│   │   ├── CyberLoadingView.swift      # 霓虹加载动画
│   │   └── GradientBackgroundView.swift
│   ├── Utils/Theme.swift
│   ├── Extensions/UIColor+Theme.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── LaunchScreen.storyboard
│   │   └── Info.plist
│   └── 华仔趣玩社.entitlements
├── build_ipa.sh                   # Mac 打包脚本
└── README.md
```

## 🎨 设计风格

| 元素 | 规格 |
|------|------|
| 背景渐变 | #12122B → #3A2465 |
| 霓虹粉 | #FF88CC |
| 电光蓝 | #44AAFF |
| 卡片圆角 | 24px |
| 加载动画 | 脉冲圆环 |

## ✅ 功能状态

| Tab | 功能 | 状态 |
|-----|------|------|
| 趣看 | WebView 浏览 | ✅ 完成 |
| 趣玩 | 待开发 | 🚧 |
| 趣做 | 待开发 | 🚧 |
| 趣读 | 待开发 | 🚧 |

## 🔧 本地开发（需要 Mac）

```bash
# 安装 xcodegen
brew install xcodegen

# 生成 Xcode 项目
xcodegen generate

# 打开项目
open 华仔趣玩社.xcodeproj

# 或直接打包
./build_ipa.sh YOUR_TEAM_ID
```

## ⚠️ 注意事项

1. **未签名 IPA** - GitHub 构建的 IPA 未签名，需通过 Sideloadly/AltStore 签名后安装
2. **7天有效期** - 免费 Apple ID 签名的应用 7 天后需重新签名
3. **信任证书** - 首次安装需在 设置 → 通用 → 描述文件 中信任开发者

## License

MIT
