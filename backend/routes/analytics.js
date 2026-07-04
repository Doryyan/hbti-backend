const express = require('express');
const router = express.Router();

module.exports = function (db) {

  // POST /api/test-results — 接收匿名测试数据
  router.post('/test-results', (req, res) => {
    try {
      const {
        anonymousID,
        timestamp,
        testVersion,
        typeCode,
        dimensionScores,
        answers,
        questionCount,
        deviceInfo
      } = req.body;

      if (!anonymousID || !timestamp || !testVersion || !typeCode) {
        return res.status(400).json({ error: '缺少必要字段' });
      }

      const deviceModel = (deviceInfo && (deviceInfo.deviceModel || deviceInfo.model)) || null;
      const systemVersion = (deviceInfo && deviceInfo.systemVersion) || null;

      // 插入 test_results
      db.run(
        `INSERT INTO test_results (anonymous_id, timestamp, test_version, type_code, question_count, device_model, system_version)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [anonymousID, timestamp, testVersion, typeCode, questionCount || null, deviceModel, systemVersion]
      );

      // 获取刚插入的ID
      const row = db.get('SELECT last_insert_rowid() as id');
      const testId = row ? row.id : 1;

      // 插入 answers
      if (Array.isArray(answers) && answers.length > 0) {
        for (const item of answers) {
          db.run(
            `INSERT INTO answers (test_id, anonymous_id, question_id, dimension, direction, score, category)
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [testId, anonymousID, item.questionID, item.dimension, item.direction, item.score, item.category || null]
          );
        }
      }

      // 插入 dimension_scores
      if (Array.isArray(dimensionScores) && dimensionScores.length > 0) {
        for (const item of dimensionScores) {
          db.run(
            `INSERT INTO dimension_scores (test_id, anonymous_id, dimension, left_percentage, right_percentage, dominant_side)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [testId, anonymousID, item.dimension, item.leftPercentage, item.rightPercentage, item.dominantSide]
          );
        }
      }

      db._save();

      console.log(`[API] 测试结果已保存: anonymousID=${anonymousID}, typeCode=${typeCode}, testId=${testId}`);
      res.json({ success: true, testId });

    } catch (err) {
      console.error('[API] 保存测试结果失败:', err);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // POST /api/events — 接收用户行为事件
  router.post('/events', (req, res) => {
    try {
      const { anonymousID, event, timestamp, appVersion, buildVersion } = req.body;

      if (!anonymousID || !event || !timestamp) {
        return res.status(400).json({ error: '缺少必要字段' });
      }

      db.run(
        `INSERT INTO events (anonymous_id, event, timestamp, app_version, build_version)
         VALUES (?, ?, ?, ?, ?)`,
        [anonymousID, event, timestamp, appVersion || null, buildVersion || null]
      );

      db._save();
      console.log(`[API] 事件已记录: ${event}`);
      res.json({ success: true });

    } catch (err) {
      console.error('[API] 保存事件失败:', err);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  // POST /api/delete-data — 删除指定匿名ID的所有数据
  router.post('/delete-data', (req, res) => {
    try {
      const { anonymousID } = req.body;

      if (!anonymousID) {
        return res.status(400).json({ error: '缺少 anonymousID' });
      }

      db.run('DELETE FROM answers WHERE anonymous_id = ?', [anonymousID]);
      db.run('DELETE FROM dimension_scores WHERE anonymous_id = ?', [anonymousID]);
      db.run('DELETE FROM events WHERE anonymous_id = ?', [anonymousID]);
      const testDel = db.run('DELETE FROM test_results WHERE anonymous_id = ?', [anonymousID]);

      db._save();

      console.log(`[API] 数据已删除: anonymousID=${anonymousID}`);
      res.json({ success: true, deleted: testDel.changes });

    } catch (err) {
      console.error('[API] 删除数据失败:', err);
      res.status(500).json({ error: '服务器内部错误' });
    }
  });

  return router;
};
