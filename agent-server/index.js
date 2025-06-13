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

// agent.go 서버 URL 설정
const AGENT_SERVER_URL = 'http://localhost:3000';

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
app.post('/api/template', async (req, res) => {
  const { template_name, target_type, basis_type, vulns, asset_id } = req.body;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // template_id를 문자열로 생성
    const newTemplateId = `tmpl_${Date.now()}`;
    await client.query(
      `INSERT INTO template (template_id, template_name, target_type, basis_type, asset_id, vuln_id)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [newTemplateId, template_name, target_type, basis_type, asset_id, vulns.map(v => v.vulnid).join(',')]
    );

    // 선택된 취약점들을 template_vuln 테이블에 저장
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



app.get('/api/template/list', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.template_id, t.template_name, t.target_type, t.basis_type, COUNT(v.id) AS vuln_count
      FROM template t
      LEFT JOIN template_vuln v ON t.template_id::text = v.template_id
      GROUP BY t.template_id, t.template_name, t.target_type, t.basis_type
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




// 템플릿 항목 일괄 저장
// Node.js + Express 예시
app.post('/api/template', async (req, res) => {
  const { templatename, targetType, basisType } = req.body;

  try {
    await pool.query(
      `INSERT INTO template (template_id, template_name, target_type, basis_type)
       VALUES ($1, $2, $3, $4)`,
      [
        `tmpl_${Date.now()}`,  // 간단한 ID 생성 예시
        templatename,
        targetType,
        basisType.join(',')    // 배열을 문자열로 변환
      ]
    );
    res.status(200).send('✅ 등록 완료');
  } catch (err) {
    console.error('❌ 템플릿 등록 실패:', err.message);
    res.status(500).send('등록 중 오류 발생');
  }
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
         a.ip AS ip,
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
         r.check_start_time,
         r.check_end_time,
         r.serviceon,  -- serviceon,
         r.confpath,  -- confpath 

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
  const { host_name, item_id, result, detail, service_status, serviceon, confpath } = req.body;
  console.log('점검 결과 저장 요청:', { host_name, item_id, result, serviceon }); // 로그 추가
  try {
    const updateResult = await pool.query(
      `UPDATE evaluation_results
       SET result = $1,
           detail = $2,
           service_status = $3,
           serviceon = $4,
           confpath = $5,
           checked_by_agent = true,
           last_checked_at = NOW(),
           check_end_time = NOW()
       WHERE host_name = $6 AND item_id = $7`,
      [result, detail, service_status, serviceon, confpath, host_name, item_id]
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
       SET result = '점검 중', 
           last_checked_at = NOW(), 
           checked_by_agent = false,
           check_start_time = NOW(),
           check_end_time = NULL
       WHERE id = $1`,
      [id]
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

if (basisFilter) {
  const filters = basisFilter.split(',').map(f => f.trim()).filter(f => f !== '');

  if (filters.length === 0) {
    basisMatch = false; // ✅ 둘 다 체크 해제되었을 때는 아무것도 매칭 안 됨
  } else if (filters.includes('전자금융') && !filters.includes('주요정보')) {
    basisMatch = row.basis_financial === 'o';
  } else if (!filters.includes('전자금융') && filters.includes('주요정보')) {
    basisMatch = row.basis_critical_info === 'o';
  } else if (filters.includes('전자금융') && filters.includes('주요정보')) {
    basisMatch = row.basis_financial === 'o' || row.basis_critical_info === 'o';
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

// 템플릿별 점검 항목 목록 조회
app.get('/api/template/:id/items', async (req, res) => {
  const templateId = req.params.id;
  try {
    const result = await pool.query(
      `SELECT tv.vul_id, tv.vul_name AS item_name, v.risk_level, v.details AS description
       FROM template_vuln tv
       LEFT JOIN vulnerability v ON tv.vul_id = v.vul_id
       WHERE tv.template_id = $1
       ORDER BY tv.template_id`,
      [templateId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('템플릿 항목 불러오기 오류:', err);
    res.status(500).json({ error: 'DB 오류' });
  }
});
// PATCH /api/asset/:id
app.patch('/api/asset/:id', async (req, res) => {
  const { id } = req.params;
  const { category, name, hostname, ip, manager } = req.body;

  try {
    await pool.query(
      `UPDATE asset
       SET target_type = $1, server_name = $2, host_name = $3, ip = $4, manager = $5
       WHERE id = $6`,
      [category, name, hostname, ip, manager, id]
    );
    res.send('✅ 수정 완료');
  } catch (err) {
    console.error('❌ 자산 수정 실패:', err.message);
    res.status(500).send('DB 오류');
  }
});

/*
// 점검 시작 시 evaluation_results 미리 생성 API
app.post('/api/evaluation/init', async (req, res) => {
  const { assetId, templateId } = req.body;
  if (!assetId || !templateId) {
    return res.status(400).json({ error: 'assetId와 templateId가 필요합니다.' });
  }

  const client = await pool.connect();
  try {
    // 자산 정보 가져오기
    const assetRes = await client.query(
      'SELECT host_name FROM asset WHERE id = $1',
      [assetId]
    );
    if (assetRes.rowCount === 0) {
      return res.status(404).json({ error: '자산을 찾을 수 없습니다.' });
    }
    const asset = assetRes.rows[0];

    // 템플릿명 가져오기 (필요시)
    const tmplRes = await client.query(
      'SELECT template_name FROM template WHERE template_id = $1',
      [templateId]
    );
    const templatename = tmplRes.rows[0]?.template_name || '';

    // 템플릿 항목 가져오기
    const itemsRes = await client.query(
      'SELECT vul_id, vul_name FROM template_vuln WHERE template_id = $1',
      [templateId]
    );
    if (itemsRes.rowCount === 0) {
      return res.status(404).json({ error: '템플릿 항목이 없습니다.' });
    }

    await client.query('BEGIN');
    for (const item of itemsRes.rows) {
      // 이미 존재하는지 확인 (중복 방지)
      const existsRes = await client.query(
        `SELECT 1 FROM evaluation_results 
         WHERE templateid = $1 AND item_id = $2 AND host_name = $3`,
        [templateId, item.vul_id, asset.host_name]
      );
      if (existsRes.rowCount === 0) {
        await client.query(
          `INSERT INTO evaluation_results (
            templateid, templatename, item_id, host_name, result, risk_level, checked_by_agent
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            templateId,
            templatename,
            item.vul_id,
            asset.host_name,
            '미점검',
            '중',
            false
          ]
        );
      }
    }
    await client.query('COMMIT');
    res.json({ success: true });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ evaluation_results 미리 생성 실패:', err.message);
    res.status(500).json({ error: 'DB 오류' });
  } finally {
    client.release();
  }
});
*/
app.post('/api/evaluation/init', async (req, res) => {
  const { template_id, vul_id, evaluation_name } = req.body;

  if (!template_id || !vul_id || !evaluation_name) {
    return res.status(400).json({ error: '필수 값이 누락되었습니다.' });
  }

  try {
    // 1. 템플릿 정보 가져오기
    const templateRes = await pool.query('SELECT * FROM template WHERE template_id = $1', [template_id]);
    if (templateRes.rows.length === 0) {
      return res.status(404).json({ error: '템플릿을 찾을 수 없습니다.' });
    }
    const template = templateRes.rows[0];

    // 2. 자산 정보 가져오기
    const assetRes = await pool.query('SELECT * FROM asset WHERE id = $1', [template.asset_id]);
    if (assetRes.rows.length === 0) {
      return res.status(404).json({ error: '자산을 찾을 수 없습니다.' });
    }
    const asset = assetRes.rows[0];

    // 3. 취약점 정보 가져오기
    const vulnRes = await pool.query('SELECT * FROM template_vuln WHERE template_id = $1 AND vul_id = $2', 
      [template_id, vul_id]);
    if (vulnRes.rows.length === 0) {
      return res.status(404).json({ error: '취약점 항목을 찾을 수 없습니다.' });
    }
    const vuln = vulnRes.rows[0];

    // 4. evaluation_results에 항목 INSERT
    const insertQuery = `
      INSERT INTO evaluation_results (
        templateid, templatename, host_name, item_id, item_name, result,
        checked_by_agent, evaluation_name, risk_grade
      )
      VALUES ($1, $2, $3, $4, $5, '미점검', false, $6, 3)
      ON CONFLICT (templateid, host_name, item_id) DO NOTHING
      RETURNING id
    `;
    
    const result = await pool.query(insertQuery, [
      template_id,
      template.template_name,
      asset.host_name,
      vul_id,
      vuln.vul_name,
      evaluation_name
    ]);

    res.status(200).json({ 
      message: '점검 항목이 성공적으로 생성되었습니다.',
      id: result.rows[0]?.id
    });
  } catch (err) {
    console.error('점검 항목 생성 오류:', err);
    res.status(500).json({ error: '서버 오류 발생' });
  }
});



// 로그인 API
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    // users 테이블에서 사용자 조회
    const userRes = await pool.query(
      'SELECT username, password_hash, role FROM users WHERE username = $1',
      [username]
    );
    if (userRes.rowCount === 0) {
      return res.status(401).json({ success: false, error: '존재하지 않는 사용자입니다.' });
    }
    const user = userRes.rows[0];

    // 비밀번호 비교 (bcrypt)
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ success: false, error: '비밀번호가 일치하지 않습니다.' });
    }

    // 로그인 성공
    res.json({
      success: true,
      username: user.username,
      role: user.role // 'admin' 또는 'user'
    });
  } catch (err) {
    console.error('❌ 로그인 오류:', err.message);
    res.status(500).json({ success: false, error: '서버 오류' });
  }
});

// 사용자 등록 API
app.post('/api/register', async (req, res) => {
  const { username, password, name, email, role } = req.body;
  if (!username || !password || !name || !email || !role) {
    return res.status(400).json({ success: false, error: '모든 항목을 입력하세요.' });
  }
  try {
    // 중복 체크
    const exists = await pool.query('SELECT 1 FROM users WHERE username = $1', [username]);
    if (exists.rowCount > 0) {
      return res.status(409).json({ success: false, error: '이미 존재하는 아이디입니다.' });
    }
    const hash = await bcrypt.hash(password, 10);
    await pool.query(
      `INSERT INTO users (username, password_hash, name, email, role, is_active, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, true, NOW(), NOW())`,
      [username, hash, name, email, role]
    );
    res.json({ success: true });
  } catch (err) {
    console.error('❌ 사용자 등록 오류:', err.message);
    res.status(500).json({ success: false, error: '서버 오류' });
  }
});

// 전체 점검 리스트 조회
app.get('/api/evaluations', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
         er.id,
         er.templateid,
         er.templatename,
         er.host_name,
         er.item_id,
         er.item_name,
         er.result,
         er.risk_grade,
         er.checked_by_agent,
         er.last_checked_at,
         er.detail,
         er.service_status
       FROM evaluation_results er
       ORDER BY er.templateid, er.host_name, er.item_id`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('❌ 점검 리스트 조회 실패:', err.message);
    res.status(500).send('DB 조회 실패');
  }
});

// 템플릿 상세 정보 + 자산 정보
app.get('/api/template/:templateid/detail', async (req, res) => {
  const { templateid } = req.params;
  try {
    // 템플릿 정보
    const tmplRes = await pool.query(
      'SELECT * FROM template WHERE template_id = $1',
      [templateid]
    );
    if (tmplRes.rows.length === 0) return res.status(404).json({ error: '템플릿 없음' });
    const template = tmplRes.rows[0];

    // 자산 정보
    let asset = null;
    if (template.asset_id) {
      const assetRes = await pool.query('SELECT * FROM asset WHERE id = $1', [template.asset_id]);
      asset = assetRes.rows[0] || null;
    }

    res.json({ template, asset });
  } catch (err) {
    res.status(500).json({ error: 'DB 오류' });
  }
});

// 점검 시작 API
app.post('/api/check/start', async (req, res) => {
  const { template_id, vul_id } = req.body;
  try {
    console.log('📝 점검 요청:', { template_id, vul_id });
    
    // 템플릿 정보 가져오기
    const templateRes = await pool.query(
      'SELECT * FROM template WHERE template_id = $1',
      [template_id]
    );
    
    if (templateRes.rows.length === 0) {
      throw new Error('템플릿을 찾을 수 없습니다.');
    }
    
    const template = templateRes.rows[0];
    
    // 자산 정보 가져오기
    const assetRes = await pool.query(
      'SELECT * FROM asset WHERE id = $1',
      [template.asset_id]
    );
    
    if (assetRes.rows.length === 0) {
      throw new Error('자산을 찾을 수 없습니다.');
    }
    
    const asset = assetRes.rows[0];
    
    // evaluation_results에서 해당 항목 찾기
    const evalRes = await pool.query(
      `SELECT id FROM evaluation_results 
       WHERE templateid = $1 AND item_id = $2`,
      [template_id, vul_id]
    );
    
    if (evalRes.rows.length === 0) {
      throw new Error('점검 항목을 찾을 수 없습니다.');
    }
    
    const evalId = evalRes.rows[0].id;
    
    // 명령 저장
    latestCommand = {
      id: evalId,
      vulnid: vul_id,
      hostname: asset.host_name
    };
    
    // 점검 상태 업데이트
    await pool.query(
      `UPDATE evaluation_results 
       SET result = '점검 중', 
           last_checked_at = NOW(), 
           checked_by_agent = false,
           check_start_time = NOW(),
           check_end_time = NULL
       WHERE id = $1`,
      [evalId]
    );

    // 30초 후에 결과가 없으면 미점검으로 변경
    setTimeout(async () => {
      const checkRes = await pool.query(
        `SELECT result FROM evaluation_results WHERE id = $1`,
        [evalId]
      );
      
      if (checkRes.rows[0]?.result === '점검 중') {
        await pool.query(
          `UPDATE evaluation_results 
           SET result = '미점검',
               check_end_time = NOW()
           WHERE id = $1`,
          [evalId]
        );
      }
    }, 30000);
    
    res.json({ 
      success: true,
      message: '점검이 시작되었습니다.',
      command: latestCommand
    });
  } catch (err) {
    console.error('❌ 점검 시작 실패:', err);
    res.status(500).json({ 
      error: '점검 처리 실패',
      message: err.message || '알 수 없는 오류가 발생했습니다.'
    });
  }
});

// 점검 결과 저장 API
app.post('/api/check/results', async (req, res) => {
  const { template_id, results } = req.body;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    for (const result of results) {
      await client.query(
        `UPDATE evaluation_results 
         SET result = $1, 
             detail = $2,
             serviceon = $3 WHERE ...`,
        [result.status, result.detail, result.serviceon, template_id, result.vul_id]
      );
    }

    await client.query('COMMIT');
    res.json({ success: true });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ 결과 저장 실패:', err);
    res.status(500).json({ error: '결과 저장 실패' });
  } finally {
    client.release();
  }
});

// 점검 상태 리셋 API
app.post('/api/evaluation/reset', async (req, res) => {
  const { template_id, vul_id } = req.body;
  try {
    await pool.query(
      `UPDATE evaluation_results
       SET result = '미점검'
       WHERE templateid = $1 AND item_id = $2 AND result = '점검 중'`,
      [template_id, vul_id]
    );
    res.json({ success: true });
  } catch (err) {
    console.error('점검 상태 리셋 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

// 2분 이상 점검 중인 항목 미점검으로 변경 (주기적 작업)
setInterval(async () => {
  await pool.query(`
    UPDATE evaluation_results
    SET result = '미점검'
    WHERE result = '점검 중'
      AND check_start_time < NOW() - INTERVAL '2 minutes'
  `);
}, 60 * 1000);

// confpath 조회 API
app.get('/api/confpath', async (req, res) => {
  const { host_name } = req.query;
  const result = await pool.query(
    `SELECT confpath FROM evaluation_results WHERE host_name = $1 AND item_id = 'SRV-004' LIMIT 1`,
    [host_name]
  );
  if (result.rows.length > 0) {
    res.json({ confpath: result.rows[0].confpath });
  } else {
    res.json({ confpath: '' });
  }
});
