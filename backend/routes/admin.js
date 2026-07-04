const express = require('express');
const router = express.Router();

/**
 * 计算标准差
 * @param {number[]} values
 * @returns {number}
 */
function stddev(values) {
  if (!values || values.length === 0) return 0;
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const squaredDiffs = values.map((v) => Math.pow(v - mean, 2));
  const variance = squaredDiffs.reduce((a, b) => a + b, 0) / values.length;
  return Math.sqrt(variance);
}

/**
 * 获取最近 N 天的日期字符串列表（YYYY-MM-DD）
 * @param {number} days
 * @returns {string[]}
 */
function getRecentDays(days) {
  const result = [];
  const now = new Date();
  for (let i = days - 1; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    result.push(`${yyyy}-${mm}-${dd}`);
  }
  return result;
}

/**
 * 从 ISO 时间戳提取日期部分（YYYY-MM-DD）
 * @param {string} timestamp
 * @returns {string}
 */
function toDatePart(timestamp) {
  if (!timestamp) return '';
  return timestamp.substring(0, 10);
}

module.exports = function (db) {

  // GET /api/admin/stats — 管理后台统计数据
  router.get('/stats', (req, res) => {
    try {
      const totalTests = db.get('SELECT COUNT(*) as count FROM test_results').count;

      const today = toDatePart(new Date().toISOString());
      const todayTests = db.get(
        'SELECT COUNT(*) as count FROM test_results WHERE substr(timestamp, 1, 10) = ?', [today]
      ).count;

      // 付费转化：有付费事件的独立用户数 / 总测试独立用户数
      const totalUsers = db.get('SELECT COUNT(DISTINCT anonymous_id) as count FROM test_results').count;
      const paidUsers = db.get(
        "SELECT COUNT(DISTINCT anonymous_id) as count FROM events WHERE event IN ('purchase_unlocked', 'pay_success', 'paid', 'purchase')"
      ).count;

      const conversionRate = totalUsers > 0 ? (paidUsers / totalUsers * 100) : 0;

      // 完成率：有 test_results 的用户数 / 有 start_test 事件的用户数
      const startTestUsers = db.get(
        "SELECT COUNT(DISTINCT anonymous_id) as count FROM events WHERE event IN ('start_test', 'test_started', 'begin_test')"
      ).count;

      const completionRate = startTestUsers > 0 ? (totalUsers / startTestUsers * 100) : 0;

      res.json({
        totalTests,
        todayTests,
        conversionRate: Math.round(conversionRate * 100) / 100,
        completionRate: Math.round(completionRate * 100) / 100
      });
    } catch (err) {
      console.error('[Admin] 获取统计数据失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/type-distribution — 人格类型分布
  router.get('/type-distribution', (req, res) => {
    try {
      const rows = db.all(`
        SELECT type_code, COUNT(*) as count
        FROM test_results
        GROUP BY type_code
        ORDER BY count DESC
      `);

      res.json(rows);
    } catch (err) {
      console.error('[Admin] 获取类型分布失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/version-distribution — 版本使用分布
  router.get('/version-distribution', (req, res) => {
    try {
      const rows = db.all(`
        SELECT test_version, COUNT(*) as count
        FROM test_results
        GROUP BY test_version
        ORDER BY count DESC
      `);

      const total = rows.reduce((sum, r) => sum + r.count, 0);
      const result = rows.map((r) => ({
        version: r.test_version,
        count: r.count,
        percentage: total > 0 ? Math.round(r.count / total * 10000) / 100 : 0
      }));

      res.json(result);
    } catch (err) {
      console.error('[Admin] 获取版本分布失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/trend — 近7日趋势
  router.get('/trend', (req, res) => {
    try {
      const days = getRecentDays(7);

      // 每日开始测试数（通过 events 表中 test_started 事件）
      const startEvents = db.all(`
        SELECT substr(timestamp, 1, 10) as day, COUNT(DISTINCT anonymous_id) as count
        FROM events
        WHERE event IN ('start_test', 'test_started', 'begin_test')
          AND substr(timestamp, 1, 10) >= ?
          AND substr(timestamp, 1, 10) <= ?
        GROUP BY substr(timestamp, 1, 10)
      `, [days[0], days[days.length - 1]]);

      // 每日完成测试数（通过 test_results 表）
      const completedTests = db.all(`
        SELECT substr(timestamp, 1, 10) as day, COUNT(*) as count
        FROM test_results
        WHERE substr(timestamp, 1, 10) >= ?
          AND substr(timestamp, 1, 10) <= ?
        GROUP BY substr(timestamp, 1, 10)
      `, [days[0], days[days.length - 1]]);

      const startMap = {};
      startEvents.forEach((r) => { startMap[r.day] = r.count; });

      const completeMap = {};
      completedTests.forEach((r) => { completeMap[r.day] = r.count; });

      const trend = days.map((day) => ({
        date: day,
        startedTests: startMap[day] || 0,
        completedTests: completeMap[day] || 0
      }));

      res.json(trend);
    } catch (err) {
      console.error('[Admin] 获取趋势数据失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/questions — 题目质量分析
  router.get('/questions', (req, res) => {
    try {
      const rows = db.all(`
        SELECT question_id, AVG(score) as avg_score
        FROM answers
        GROUP BY question_id
        ORDER BY question_id ASC
      `);

      // 获取每道题所有分数用于计算标准差
      const allScores = db.all('SELECT question_id, score FROM answers');

      const scoreMap = {};
      allScores.forEach((r) => {
        if (!scoreMap[r.question_id]) scoreMap[r.question_id] = [];
        scoreMap[r.question_id].push(r.score);
      });

      const result = rows.map((r) => ({
        questionId: r.question_id,
        avgScore: Math.round(r.avg_score * 100) / 100,
        stddev: Math.round(stddev(scoreMap[r.question_id]) * 100) / 100,
        answerCount: scoreMap[r.question_id] ? scoreMap[r.question_id].length : 0
      }));

      res.json(result);
    } catch (err) {
      console.error('[Admin] 获取题目分析失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/dimensions — 维度统计
  router.get('/dimensions', (req, res) => {
    try {
      const rows = db.all(`
        SELECT dimension, dominant_side, COUNT(*) as count
        FROM dimension_scores
        GROUP BY dimension, dominant_side
        ORDER BY dimension, dominant_side
      `);

      // 按维度分组
      const dimensionMap = {};
      rows.forEach((r) => {
        if (!dimensionMap[r.dimension]) {
          dimensionMap[r.dimension] = {};
        }
        dimensionMap[r.dimension][r.dominant_side] = r.count;
      });

      // 构建结构化输出
      const dimensionNames = {
        EI: { left: 'E', right: 'I' },
        SN: { left: 'S', right: 'N' },
        TF: { left: 'T', right: 'F' },
        JP: { left: 'J', right: 'P' }
      };

      const result = Object.entries(dimensionNames).map(([dim, sides]) => {
        const data = dimensionMap[dim] || {};
        const leftCount = data[sides.left] || 0;
        const rightCount = data[sides.right] || 0;
        const total = leftCount + rightCount;

        return {
          dimension: dim,
          left: {
            side: sides.left,
            count: leftCount,
            percentage: total > 0 ? Math.round(leftCount / total * 10000) / 100 : 0
          },
          right: {
            side: sides.right,
            count: rightCount,
            percentage: total > 0 ? Math.round(rightCount / total * 10000) / 100 : 0
          },
          total
        };
      });

      res.json(result);
    } catch (err) {
      console.error('[Admin] 获取维度统计失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/funnel — 转化漏斗
  router.get('/funnel', (req, res) => {
    try {
      const totalUniqueUsers = db.get('SELECT COUNT(DISTINCT anonymous_id) as count FROM events').count;

      const startTest = db.get(
        "SELECT COUNT(DISTINCT anonymous_id) as count FROM events WHERE event IN ('start_test', 'test_started', 'begin_test')"
      ).count;

      const completedTest = db.get('SELECT COUNT(DISTINCT anonymous_id) as count FROM test_results').count;

      const viewResult = db.get(
        "SELECT COUNT(DISTINCT anonymous_id) as count FROM events WHERE event IN ('view_result', 'result_viewed', 'see_result')"
      ).count;

      const paidUnlock = db.get(
        "SELECT COUNT(DISTINCT anonymous_id) as count FROM events WHERE event IN ('purchase_unlocked', 'pay_success', 'paid', 'purchase')"
      ).count;

      res.json([
        { step: '打开App', count: totalUniqueUsers },
        { step: '开始测试', count: startTest },
        { step: '完成答题', count: completedTest },
        { step: '查看结果', count: viewResult },
        { step: '付费解锁', count: paidUnlock }
      ]);
    } catch (err) {
      console.error('[Admin] 获取漏斗数据失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // GET /api/admin/users — 用户列表（最近50条）
  router.get('/users', (req, res) => {
    try {
      const rows = db.all(`
        SELECT
          tr.id,
          tr.anonymous_id as anonymousID,
          tr.timestamp,
          tr.type_code as typeCode,
          tr.test_version as testVersion,
          tr.question_count as questionCount,
          tr.device_model as deviceModel,
          tr.system_version as systemVersion
        FROM test_results tr
        ORDER BY tr.id DESC
        LIMIT 50
      `);

      res.json(rows);
    } catch (err) {
      console.error('[Admin] 获取用户列表失败:', err.message);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  return router;
};
