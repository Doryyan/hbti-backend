const express = require('express');
const cors = require('cors');
const path = require('path');

// 初始化 Express 应用
const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// 请求日志
app.use((req, res, next) => {
  const start = Date.now();
  const timestamp = new Date().toISOString();
  res.on('finish', () => {
    const duration = Date.now() - start;
    const status = res.statusCode;
    const method = req.method;
    const url = req.originalUrl;
    if (!url.startsWith('/favicon')) {
      console.log(`[${timestamp}] ${method} ${url} ${status} ${duration}ms`);
    }
  });
  next();
});

// 数据库和路由 — 异步初始化后注册
async function startServer() {
  // 初始化数据库（sql.js 需要异步加载 WASM）
  const db = require('./db/init');
  await db.init();

  // 注册路由
  const analyticsRouter = require('./routes/analytics')(db);
  const adminRouter = require('./routes/admin')(db);

  app.use('/api', analyticsRouter);
  app.use('/api/admin', adminRouter);

  // 静态文件服务 — 托管管理看板
  const publicPath = path.join(__dirname, 'public');
  app.use(express.static(publicPath));

  // 根路径重定向到管理看板
  app.get('/', (req, res) => {
    res.redirect('/admin.html');
  });

  // 404 处理
  app.use((req, res) => {
    res.status(404).json({ error: '接口不存在' });
  });

  // 全局错误处理
  app.use((err, req, res, next) => {
    console.error('[ERROR]', err.message);
    res.status(500).json({ error: '服务器内部错误' });
  });

  // 启动服务器
  app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`  HBTI Backend Server`);
    console.log(`  地址: http://localhost:${PORT}`);
    console.log(`  管理看板: http://localhost:${PORT}/admin.html`);
    console.log(`  API: http://localhost:${PORT}/api/...`);
    console.log('='.repeat(50));
  });
}

startServer().catch((err) => {
  console.error('[FATAL] 服务器启动失败:', err);
  process.exit(1);
});

module.exports = app;
