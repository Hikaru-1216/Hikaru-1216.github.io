# Hexo + Butterfly GitHub Pages Starter

这是一个按 **Hexo + Butterfly** 思路整理的个人博客起步模板，风格和 `xw-soleil.github.io` 这一类 GitHub Pages 博客比较接近：有首页卡片流、关于页、标签页、分类页、友链页和侧边栏信息卡。

## 你需要先改的 6 处内容

1. `_config.yml` 里的 `title`、`subtitle`、`author`、`url`
2. `_config.butterfly.yml` 里的 GitHub、邮箱、公告文案
3. `source/about/index.md` 里的自我介绍
4. `source/_data/link.yml` 里的友链
5. `source/_posts/` 里的示例文章
6. `source/img/avatar.svg` 如果你有自己的头像，直接替换掉

## 本地预览

```bash
npm install
npx hexo clean
npx hexo g
npx hexo s
```

浏览器打开：

```text
http://localhost:4000
```

## 新建文章

```bash
npx hexo new post "文章标题"
```

文章会生成到 `source/_posts/`。

## 发布到 GitHub Pages

### 1. 创建仓库

创建一个仓库，名字必须是：

```text
your-github-username.github.io
```

### 2. 把这个模板上传到仓库根目录

把当前目录下所有文件推送到 `main` 分支。

### 3. 打开 Pages 设置

进入：

```text
Settings -> Pages
```

然后把部署来源设为 **GitHub Actions**。

### 4. 等待 Actions 自动部署

本模板已经带了 `.github/workflows/pages.yml`，推送后会自动构建并部署。

## 常用命令

```bash
npx hexo clean     # 清缓存
npx hexo g         # 生成静态文件
npx hexo s         # 本地启动
npx hexo new page about
npx hexo new post "新文章"
```

## 文件结构

```text
.
├── _config.yml
├── _config.butterfly.yml
├── package.json
├── .github/workflows/pages.yml
├── source
│   ├── _posts
│   ├── _data
│   ├── about
│   ├── categories
│   ├── tags
│   ├── link
│   └── img
└── scaffolds
```

## 小建议

- 先把示例文章删掉，再换成你自己的内容。
- 如果你想做成“学习笔记风”“项目展示风”或“简历风”，主要改 `about` 页和首页文章结构就够了。
- 如果你后面想绑自定义域名，可以再加 `CNAME` 文件。
