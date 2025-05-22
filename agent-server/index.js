const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();
const port = 3000;

// PostgreSQL 연결 설정
const pool = new Pool({
  user: 'goagent',
  host: 'localhost',
  database: 'goagent',
  password: '7637op2337!',
  port: 5432,
});

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

// 템플릿 항목 단건 저장
app.post('/api/template', async (req, res) => {
  const {
    templateid,
    templatename,
    vulnid,
    vulName,
    serverName,
    hostName,
    ip,
    result,
    assessYN,
    risk_grade = 3
  } = req.body;

  try {
    await pool.query(`
      INSERT INTO evaluation_results (
        templateid, templatename, item_id,
        host_name, result, risk_level, risk_score, vuln_score, risk_grade,
        checked_by_agent, last_checked_at, detail
      ) VALUES (
        $1, $2, $3,
        $4, $5, '중', 50, 10, $6,
        false, null, null
      )
    `, [
      templateid, templatename, vulnid,
      hostName, result || '미점검', risk_grade
    ]);
    res.sendStatus(200);
  } catch (err) {
    console.error('❌ 템플릿 항목 저장 실패:', err.message);
    res.status(500).send('템플릿 저장 실패');
  }
});

// 템플릿 항목 일괄 저장
app.post('/api/template/save', async (req, res) => {
  const { templateid, templatename, host_name, items } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of items) {
      await client.query(
        `INSERT INTO evaluation_results (
          templateid, templatename, host_name, item_id,
          result, risk_level, risk_score, vuln_score, risk_grade,
          checked_by_agent, last_checked_at
        ) VALUES ($1, $2, $3, $4, '미점검', $5, $6, $7, $8, false, null)`,
        [
          templateid,
          templatename,
          host_name,
          item.id,
          item.risk_level,
          item.risk_score,
          item.vuln_score,
          item.risk_grade || 3
        ]
      );
    }
    await client.query('COMMIT');
    res.json({ message: '✅ 템플릿 저장 완료' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ 템플릿 저장 실패:', err.message);
    res.status(500).send('템플릿 저장 실패');
  } finally {
    client.release();
  }
});

// 템플릿 항목 조회 (JOIN template_items for vulname, vul_info)
app.get('/api/template/by-id/:templateid', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
         r.id,
         r.templateid,
         r.templatename,
         r.host_name AS hostname,
         t.item_id AS vulnid,
         t.item_name AS vulname,
         t.vul_info,
         r.result,
         r.risk_level,
         r.risk_score,
         r.vuln_score,
         r.risk_grade,
         r.checked_by_agent,
         r.last_checked_at,
         r.detail,
         CASE WHEN r.result = '양호' THEN r.vuln_score ELSE 0 END AS vuln_last_score
       FROM evaluation_results r
       JOIN template_items t ON r.item_id = t.item_id
       WHERE r.templateid = $1
       ORDER BY r.id`,
      [req.params.templateid]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ 템플릿 조회 실패:', err.message);
    res.status(500).send('DB 조회 실패');
  }
});

// 점검 결과 저장
app.post('/api/result', async (req, res) => {
  const { host_name, item_id, result, detail } = req.body;
  try {
    const updateResult = await pool.query(
      `UPDATE evaluation_results
       SET result = $1,
           detail = $2,
           checked_by_agent = true,
           last_checked_at = NOW()
       WHERE host_name = $3 AND item_id = $4`,
      [result, detail, host_name, item_id]
    );
    if (updateResult.rowCount === 0) {
      console.warn(`⚠️ 업데이트 대상 없음: host=${host_name}, item_id=${item_id}`);
    }
    res.send('✅ 점검 결과 저장 완료');
  } catch (err) {
    console.error('❌ 점검 결과 저장 실패:', err.message);
    res.status(500).send('결과 저장 실패');
  }
});

// 점검 명령 전달
let latestCommand = null;
app.post('/api/send-command', async (req, res) => {
  const { id, vulnid, hostname } = req.body;
  try {
    latestCommand = { id, vulnid, hostname };
    await pool.query(
      `UPDATE evaluation_results
       SET result = '점검 중', last_checked_at = NOW(), checked_by_agent = false
       WHERE id = $1`, [id]
    );
    res.sendStatus(200);
  } catch (err) {
    console.error('❌ 점검 명령 전달 실패:', err.message);
    res.status(500).send('점검 처리 실패');
  }
});

app.get('/api/command', (req, res) => {
  if (latestCommand) {
    res.json(latestCommand);
    latestCommand = null;
  } else {
    res.status(204).send();
  }
});

// 템플릿 요약 저장
app.post('/api/template/summary', async (req, res) => {
  const { templateid, assess_score, assess_vuln, assess_pass, assess_date } = req.body;
  try {
    await pool.query(
      `INSERT INTO templatesum (
        templateid, assess_score, assess_vuln, assess_pass, assess_date
       ) VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (templateid) DO UPDATE SET
         assess_score = $2,
         assess_vuln = $3,
         assess_pass = $4,
         assess_date = $5`,
      [templateid, assess_score, assess_vuln, assess_pass, assess_date]
    );
    res.send('✅ 템플릿 요약 저장 완료');
  } catch (err) {
    console.error('❌ 템플릿 요약 저장 실패:', err.message);
    res.status(500).send('요약 저장 실패');
  }
});

// 템플릿 요약 전체 조회
app.get('/api/template/summary/all', async (req, res) => {
  try {
    const result = await pool.query(`SELECT * FROM templatesum ORDER BY assess_date DESC`);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ 템플릿 요약 조회 실패:', err.message);
    res.status(500).send('요약 조회 실패');
  }
});

// 템플릿 목록 조회
app.get('/api/template/list', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT DISTINCT templateid, templatename, host_name
       FROM evaluation_results
       ORDER BY templateid DESC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ 템플릿 목록 조회 실패:', err.message);
    res.status(500).send('템플릿 목록 조회 실패');
  }
});

// 헬스 체크
app.get('/health', (req, res) => {
  res.send('✅ Server is healthy');
});

app.listen(port, () => {
  console.log(`✅ 서버가 http://localhost:${port} 에서 실행 중입니다`);
});
