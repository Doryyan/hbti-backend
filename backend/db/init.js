const initSqlJs = require('sql.js');
const fs = require('fs');
const path = require('path');

const DB_DIR = path.join(__dirname, '..', 'data');
const DB_PATH = path.join(DB_DIR, 'hbti.db');

if (!fs.existsSync(DB_DIR)) {
  fs.mkdirSync(DB_DIR, { recursive: true });
}

class SQLiteDatabase {
  constructor() {
    this.db = null;
    this._lastInsertRowid = 0;
  }

  async init() {
    const SQL = await initSqlJs();

    if (fs.existsSync(DB_PATH)) {
      const fileBuffer = fs.readFileSync(DB_PATH);
      this.db = new SQL.Database(fileBuffer);
    } else {
      this.db = new SQL.Database();
    }

    // 逐条建表
    const tables = [
      `CREATE TABLE IF NOT EXISTS test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anonymous_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        test_version TEXT NOT NULL,
        type_code TEXT NOT NULL,
        question_count INTEGER,
        device_model TEXT,
        system_version TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_id INTEGER NOT NULL,
        anonymous_id TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        dimension TEXT NOT NULL,
        direction TEXT NOT NULL,
        score REAL NOT NULL,
        category TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anonymous_id TEXT NOT NULL,
        event TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        app_version TEXT,
        build_version TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS dimension_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_id INTEGER NOT NULL,
        anonymous_id TEXT NOT NULL,
        dimension TEXT NOT NULL,
        left_percentage REAL,
        right_percentage REAL,
        dominant_side TEXT
      )`
    ];

    for (const sql of tables) {
      this.db.run(sql);
    }

    this._save();
    console.log('[DB] 数据库初始化完成:', DB_PATH);
  }

  _save() {
    const data = this.db.export();
    const buffer = Buffer.from(data);
    fs.writeFileSync(DB_PATH, buffer);
  }

  run(sql, ...bindParams) {
    const params = bindParams.length > 0 ? bindParams[0] : [];
    this.db.run(sql, params);
    const rowidResult = this.db.exec('SELECT last_insert_rowid()');
    if (rowidResult.length > 0 && rowidResult[0].values.length > 0) {
      this._lastInsertRowid = rowidResult[0].values[0][0];
    }
    return {
      changes: this.db.getRowsModified(),
      lastInsertRowid: this._lastInsertRowid
    };
  }

  get(sql, params = []) {
    const stmt = this.db.prepare(sql);
    if (params.length > 0) stmt.bind(params);
    if (stmt.step()) {
      const row = stmt.getAsObject();
      stmt.free();
      return row;
    }
    stmt.free();
    return null;
  }

  all(sql, params = []) {
    const stmt = this.db.prepare(sql);
    if (params.length > 0) stmt.bind(params);
    const results = [];
    while (stmt.step()) {
      results.push(stmt.getAsObject());
    }
    stmt.free();
    return results;
  }

  exec(sql) {
    this.db.run(sql);
    this._save();
  }

  transaction(fn) {
    const self = this;
    return function (...args) {
      try {
        self.db.exec('BEGIN TRANSACTION');
        const result = fn.apply(this, args);
        self.db.exec('COMMIT');
        self._save();
        return result;
      } catch (err) {
        try { self.db.exec('ROLLBACK'); } catch (e) {}
        throw err;
      }
    };
  }

  prepare(sql) {
    const stmt = this.db.prepare(sql);
    const dbInst = this;

    return {
      run(...params) {
        stmt.bind(params);
        stmt.step();
        stmt.reset();
        const rowidResult = dbInst.db.exec('SELECT last_insert_rowid()');
        if (rowidResult.length > 0 && rowidResult[0].values.length > 0) {
          dbInst._lastInsertRowid = rowidResult[0].values[0][0];
        }
        return {
          changes: dbInst.db.getRowsModified(),
          lastInsertRowid: dbInst._lastInsertRowid
        };
      },
      free() {
        stmt.free();
      }
    };
  }
}

const database = new SQLiteDatabase();
module.exports = database;
