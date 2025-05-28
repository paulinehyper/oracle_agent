const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;
const multer = require('multer');
const csv = require('csv-parser');
const fs = require('fs');
const { Pool } = require('pg');
const upload = multer({ dest: 'uploads/' });


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

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. 자산 정보 먼저 저장 (중복 IP 무시)
    await client.query(`
      INSERT INTO assets (server_name, host_name, ip)
      VALUES ($1, $2, $3)
      ON CONFLICT (ip) DO NOTHING
    `, [serverName, hostName, ip]);

    // 2. 템플릿 점검 항목 저장
    await client.query(`
      INSERT INTO evaluation_results (
        templateid, templatename, item_id,
        host_name, ip, result, risk_level, risk_score, vuln_score, risk_grade,
        checked_by_agent, last_checked_at, detail, service_status
      ) VALUES (
        $1, $2, $3,
        $4, $5, $6, '중', 50, 10, $7,
        false, null, null, null
      )
    `, [
      templateid, templatename, vulnid,
      hostName, ip, result || '미점검', risk_grade
    ]);

    await client.query('COMMIT');
    res.sendStatus(200);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ 템플릿 항목 저장 실패:', err.message);
    res.status(500).send('템플릿 저장 실패');
  } finally {
    client.release();
  }
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
          checked_by_agent, last_checked_at, service_status
        ) VALUES ($1, $2, $3, $4, '미점검', $5, $6, $7, $8, false, null, null)`,
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
         r.service_status,
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



app.get('/api/vulnerability', async (req, res) => {
  const { targetType, basisFilter, subTargets } = req.query;

  try {
    const result = await pool.query(`
      SELECT 
        vul_id, vul_name, category, control_area,
        control_type_large, control_type_medium,
        risk_level, details,
        basis_financial, basis_critical_info,
        target_aix, target_hp_ux, target_linux,
        target_solaris, target_win, target_webservice,
        target_apache, target_webtob, target_iis,
        target_tomcat, target_jeus,
        target_type
      FROM vulnerability
      ORDER BY vul_id
    `);

    const filtered = result.rows.filter(row => {
      let targetMatch = true;
      let basisMatch = true;
      let subTargetMatch = true;

      // 평가대상 상위 필터
      if (targetType) {
        targetMatch = row.target_type?.toLowerCase() === targetType.toLowerCase();
      }

      // 평가기반 필터
      if (basisFilter) {
        const filters = basisFilter.split(',').map(f => f.trim());
        if (filters.includes('전자금융') && !filters.includes('주요정보')) {
          basisMatch = row.basis_financial === 'o';
        } else if (!filters.includes('전자금융') && filters.includes('주요정보')) {
          basisMatch = row.basis_critical_info === 'o';
        } else if (filters.includes('전자금융') && filters.includes('주요정보')) {
          basisMatch = row.basis_financial === 'o' || row.basis_critical_info === 'o';
        } else {
          basisMatch = false;
        }
      }

      // 하위 대상 필터
      if (subTargets) {
        const targetFields = {
          'AIX': row.target_aix,
          'HP-UX': row.target_hp_ux,
          'LINUX': row.target_linux,
          'SOLARIS': row.target_solaris,
          'WIN': row.target_win,
          '웹서비스': row.target_webservice,
          'Apache': row.target_apache,
          'WebtoB': row.target_webtob,
          'IIS': row.target_iis,
          'Tomcat': row.target_tomcat,
          'JEUS': row.target_jeus
        };
        const subTargetList = subTargets.split(',').map(s => s.trim());
        subTargetMatch = subTargetList.some(key => targetFields[key] === 'o');
      }

      return targetMatch && basisMatch && subTargetMatch;
    });

    const response = filtered.map(row => {
      const targets = [];
      if (row.target_aix === 'o') targets.push('AIX');
      if (row.target_hp_ux === 'o') targets.push('HP-UX');
      if (row.target_linux === 'o') targets.push('LINUX');
      if (row.target_solaris === 'o') targets.push('SOLARIS');
      if (row.target_win === 'o') targets.push('WIN');
      if (row.target_webservice === 'o') targets.push('웹서비스');
      if (row.target_apache === 'o') targets.push('Apache');
      if (row.target_webtob === 'o') targets.push('WebtoB');
      if (row.target_iis === 'o') targets.push('IIS');
      if (row.target_tomcat === 'o') targets.push('Tomcat');
      if (row.target_jeus === 'o') targets.push('JEUS');

      const basisArr = [];
      if (row.basis_financial === 'o') basisArr.push('전자금융');
      if (row.basis_critical_info === 'o') basisArr.push('주요정보');

      return {
        vulnid: row.vul_id,
        vulname: row.vul_name,
        category: row.category,
        control_area: row.control_area,
        control_type_large: row.control_type_large,
        control_type_medium: row.control_type_medium,
        risk_level: row.risk_level,
        details: row.details,
        targetSystem: targets.join(', '),
        basis: basisArr.join(', ')
      };
    });

    res.json(response);
  } catch (err) {
    console.error('❌ vulnerability 조회 실패:', err.message);
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
