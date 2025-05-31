const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;
const multer = require('multer');
const csv = require('csv-parser');
const fs = require('fs');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const upload = multer({ dest: 'uploads/' });

// 여기에 추가!
let latestCommand = null;
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
/*
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
        checked_by_agent, last_checked_at, detail, service_status
      ) VALUES (
        $1, $2, $3,
        $4, $5, '중', 50, 10, $6,
        false, null, null, null
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
*/
// 템플릿 항목 단건 저장 및 자산 등록

// POST /api/template
// 템플릿 저장 (자동 생성된 template_id 사용)
/*
app.post('/api/template', async (req, res) => {
  const { template_name, target_type, basis_type, vulns } = req.body;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // template_id는 SERIAL로 자동 생성됨
    const result = await client.query(
      `INSERT INTO template (template_name, target_type, basis_type)
       VALUES ($1, $2, $3)
       RETURNING template_id`,
      [template_name, target_type, basis_type]
    );

    const newTemplateId = result.rows[0].template_id;

    for (const vuln of vulns) {
      await client.query(
        `INSERT INTO template_vuln (template_id, vul_id, vul_name)
         VALUES ($1, $2, $3)`,
        [newTemplateId, vuln.vulnid, vuln.vulname]
      );
    }

    await client.query('COMMIT');
    res.status(201).send('✅ 템플릿 저장 성공');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ 템플릿 저장 실패:', err);
    res.status(500).send('❌ 서버 오류');
  } finally {
    client.release();
  }
});

*/

app.get('/api/template/list', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        t.template_id, 
        t.template_name, 
        t.target_type, 
        t.basis_type, 
        t.asset_name,         -- 반드시 포함!
        t.asset_ip,           -- 반드시 포함!
        t.asset_manager,      -- 반드시 포함!
        COUNT(v.id) AS vuln_count
      FROM template t
      LEFT JOIN template_vuln v ON t.template_id::text = v.template_id
      GROUP BY t.template_id, t.template_name, t.target_type, t.basis_type, t.asset_name, t.asset_ip, t.asset_manager
      ORDER BY t.created_at DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error('❌ 템플릿 목록 조회 실패:', err);
    res.status(500).send('DB 조회 실패');
  }
});

// unique-name API
app.get('/api/template/unique-name', async (req, res) => {
  const baseName = req.query.name;
  if (!baseName) return res.status(400).json({ error: "name is required" });

  const regex = new RegExp(`^${baseName}(\\((\\d+)\\))?$`);
  const templates = await db.collection('templates').find({ template_name: { $regex: regex } }).toArray();

  const suffixes = templates
    .map(t => {
      const match = t.template_name.match(/\((\d+)\)$/);
      return match ? parseInt(match[1]) : 0;
    });

  const nextSuffix = suffixes.length > 0 ? Math.max(...suffixes) + 1 : 0;
  const uniqueName = nextSuffix === 0 ? baseName : `${baseName}(${nextSuffix})`;

  res.json({ uniqueName });
});


app.post('/upload', upload.single('csvfile'), (req, res) => {
  const filePath = req.file.path;
  const results = [];

  // 한글 ➜ vulnerability 테이블 컬럼명 매핑
  const fieldMapping = {
    "평가항목ID": "vul_id",
    "구분": "category",
    "통제분야": "control_area",
    "통제구분(대)": "control_type_large",
    "통제구분(중)": "control_type_medium",
    "평가항목": "vul_name",
    "위험도": "risk_level",
    "상세설명": "details",
    "평가기반(전자금융)": "basis_financial",
    "평가기반(주요정보)": "basis_critical_info",
    "평가대상(AIX)": "target_aix",
    "평가대상(HP-UX)": "target_hp_ux",
    "평가대상(LINUX)": "target_linux",
    "평가대상(SOLARIS)": "target_solaris",
    "평가대상(WIN)": "target_win",
    "평가대상(웹서비스)": "target_webservice",
    "평가대상(Apache)": "target_apache",
    "평가대상(WebtoB)": "target_webtob",
    "평가대상(IIS)": "target_iis",
    "평가대상(Tomcat)": "target_tomcat",
    "평가대상(JEUS)": "target_jeus"
  };

  fs.createReadStream(filePath)
    .pipe(csv())
    .on('data', (data) => {
      const mappedRow = {};
      for (const [key, value] of Object.entries(data)) {
        const engKey = fieldMapping[key.trim()];
        if (engKey) {
          mappedRow[engKey] = value;
        }
      }

      // 위험도(risk_level)를 정수로 변환
      if (mappedRow.risk_level) {
        const intValue = parseInt(mappedRow.risk_level);
        mappedRow.risk_level = isNaN(intValue) ? null : intValue;
      }

      results.push(mappedRow);
    })
    .on('end', async () => {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        for (const row of results) {
          await client.query(`
            INSERT INTO vulnerability (
              vul_id, category, control_area, control_type_large, control_type_medium,
              vul_name, risk_level, details,
              basis_financial, basis_critical_info,
              target_aix, target_hp_ux, target_linux,
              target_solaris, target_win, target_webservice,
              target_apache, target_webtob, target_iis, target_tomcat, target_jeus
            ) VALUES (
              $1, $2, $3, $4, $5,
              $6, $7::integer, $8,
              $9, $10,
              $11, $12, $13,
              $14, $15, $16,
              $17, $18, $19, $20, $21
            )
            ON CONFLICT (vul_id) DO NOTHING
          `, [
            row.vul_id, row.category, row.control_area, row.control_type_large, row.control_type_medium,
            row.vul_name, row.risk_level, row.details,
            row.basis_financial, row.basis_critical_info,
            row.target_aix, row.target_hp_ux, row.target_linux,
            row.target_solaris, row.target_win, row.target_webservice,
            row.target_apache, row.target_webtob, row.target_iis, row.target_tomcat, row.target_jeus
          ]);
        }
        await client.query('COMMIT');
        res.send('✅ 취약점 CSV 업로드 및 저장 완료');
      } catch (err) {
        await client.query('ROLLBACK');
        console.error('❌ 취약점 CSV 저장 실패:', err.message);
        res.status(500).send('❌ 저장 실패');
      } finally {
        client.release();
        fs.unlinkSync(filePath); // 임시파일 삭제
      }
    });
});






// 템플릿 항목 조회 (JOIN template_vuln for vulname)
app.get('/api/template/by-id/:templateid', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
         r.id,
         r.templateid,
         r.templatename,
         r.host_name AS hostname,
         a.ip AS ip, -- asset 테이블에서 IP 가져오기
         t.vul_id AS vulnid,
         t.vul_name AS vulname,
         r.result,
         r.risk_level,
         r.risk_score,
         r.vuln_score,
         r.risk_grade,
         r.checked_by_agent,
         r.last_checked_at,
         r.detail,
         r.service_status,
         CASE WHEN r.result = '양호' THEN r.vuln_score ELSE 0 END AS vuln_last_score
       FROM evaluation_results r
       JOIN template_vuln t 
         ON r.item_id = t.vul_id AND r.templateid::text = t.template_id::text
       LEFT JOIN asset a
         ON r.host_name = a.host_name
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
  const { host_name, item_id, result, detail, service_status } = req.body;
  try {
    const updateResult = await pool.query(
      `UPDATE evaluation_results
       SET result = $1,
           detail = $2,
           service_status = $3,
           checked_by_agent = true,
           last_checked_at = NOW()
       WHERE host_name = $4 AND item_id = $5`,
      [result, detail, service_status, host_name, item_id]
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

// 점검 명령 전달 (IP 포함)
app.post('/api/send-command', async (req, res) => {
  const { id, vulnid, hostname } = req.body;

  try {
    // IP 가져오기
    const assetRes = await pool.query(
      `SELECT ip FROM asset WHERE host_name = $1 LIMIT 1`,
      [hostname]
    );

    if (assetRes.rowCount === 0) {
      return res.status(404).json({ error: '자산 IP를 찾을 수 없습니다.' });
    }

    const ip = assetRes.rows[0].ip;

    latestCommand = { id, vulnid, hostname, ip };

    await pool.query(
      `UPDATE evaluation_results
       SET result = '점검 중', last_checked_at = NOW(), checked_by_agent = false
       WHERE id = $1`, [id]
    );

    res.status(200).json({ message: '✅ 명령 저장 완료', ip });
  } catch (err) {
    console.error('❌ 점검 명령 전달 실패:', err.message);
    res.status(500).send('점검 처리 실패');
  }
});

// 점검 명령 조회 (IP 포함)
app.get('/api/command', (req, res) => {
  if (latestCommand) {
    res.json(latestCommand); // 여기에는 ip가 포함되어 있음
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



// 취약점 목록 조회 API
app.get('/vulnerability', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        vul_id, 
        category, 
        vul_name, 
        CASE
          WHEN basis_financial = 'Y' AND basis_critical_info = 'Y' THEN '전자금융, 주요정보'
          WHEN basis_financial = 'Y' THEN '전자금융'
          WHEN basis_critical_info = 'Y' THEN '주요정보'
          ELSE ''
        END AS basis
      FROM vulnerability
      ORDER BY vul_id`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ 취약점 목록 조회 오류:', err.message);
    res.status(500).send('DB 오류');
  }
});

// 자산 등록
app.post('/api/asset', async (req, res) => {
  const { category, name, hostname, ip, manager } = req.body;
  try {
    await pool.query(
      `INSERT INTO asset (target_type, server_name, host_name, ip, manager)
       VALUES ($1, $2, $3, $4, $5)`,
      [category, name, hostname, ip, manager]
    );
    res.status(200).send('ok');
  } catch (err) {
    console.error('❌ 자산 등록 실패:', err.message);
    res.status(500).send('error');
  }
});

// 자산 일괄 등록
app.post('/api/asset/bulk', async (req, res) => {
  try {
    const { assets } = req.body;
    if (!Array.isArray(assets)) return res.status(400).json({ error: '자산 배열이 필요합니다.' });

    const values = [];
    const placeholders = [];
    assets.forEach((a, i) => {
      placeholders.push(`($${i*5+1}, $${i*5+2}, $${i*5+3}, $${i*5+4}, $${i*5+5})`);
      values.push(a.target_type, a.name, a.hostname, a.ip, a.manager);
    });
    await pool.query(
      `INSERT INTO asset (target_type, server_name, host_name, ip, manager) VALUES ${placeholders.join(',')}`,
      values
    );
    res.json({ success: true });
  } catch (err) {
    console.error('❌ 자산 일괄 등록 실패:', err.message);
    res.status(500).json({ error: 'DB 오류' });
  }
});

// 자산 목록 조회
app.get('/api/asset/list', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        id, 
        target_type AS category, 
        server_name AS name, 
        host_name AS hostname, 
        ip, 
        manager 
      FROM asset 
      ORDER BY id DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('DB 조회 실패');
  }
});

// 헬스 체크
app.get('/health', (req, res) => {
  res.send('✅ Server is healthy');
});

app.listen(port, () => {
  console.log(`✅ 서버가 http://localhost:${port} 에서 실행 중입니다`);
});

//console.log("🔥 받아온 vulnData:", vulnData);
//vulnData.forEach((item, index) => {
 // console.log(`🧪 item[${index}]:`, item);
//});
app.post('/api/asset/check-duplicate', async (req, res) => {
  const { ip } = req.body;
  try {
    const result = await pool.query(
      `SELECT 1 FROM asset WHERE ip=$1 LIMIT 1`,
      [ip]
    );
    res.json({ exists: result.rowCount > 0 });
  } catch (err) {
    res.status(500).json({ error: 'DB 오류' });
  }
});

// 자산 삭제
app.delete('/api/asset/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM asset WHERE id = $1', [id]);
    res.status(200).send('deleted');
  } catch (err) {
    console.error('❌ 자산 삭제 실패:', err.message);
    res.status(500).send('error');
  }
});

// 자산 상세 조회
app.get('/api/asset/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM asset WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).send('Not found');
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ 자산 상세 조회 실패:', err.message);
    res.status(500).send('DB 오류');
  }
});

// template 등록
app.post('/api/template', async (req, res) => {
  const {
    template_name, asset_id, target_type, basis_type, vulns,
    asset_name, asset_type, asset_ip, asset_hostname, asset_manager, description = ''
  } = req.body;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 템플릿 저장 (asset 정보 포함)
    const result = await client.query(
      `INSERT INTO template 
        (template_name, asset_name, asset_type, asset_ip, asset_hostname, asset_manager, target_type, basis_type, description)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING template_id`,
      [
        template_name,
        asset_name,
        asset_type,
        asset_ip,
        asset_hostname,
        asset_manager,
        target_type,
        basis_type,
        description
      ]
    );
    const newTemplateId = result.rows[0].template_id;

    // 취약점 연결
    if (Array.isArray(vulns)) {
      for (const vuln of vulns) {
        await client.query(
          `INSERT INTO template_vuln (template_id, vul_id, vul_name)
           VALUES ($1, $2, $3)`,
          [newTemplateId, vuln.vulnid, vuln.vulname]
        );
      }
    }

    await client.query('COMMIT');
    res.status(201).send('✅ 템플릿 저장 성공');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ 템플릿 저장 실패:', err);
    res.status(500).send('❌ 서버 오류');
  } finally {
    client.release();
  }
});
