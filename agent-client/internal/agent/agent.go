package agent

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type Command struct {
	ID     int    `json:"id"`
	VulnID string `json:"vulnid"`
	Host   string `json:"hostname"`
}

type Result struct {
	HostName      string `json:"host_name"`
	ItemID        string `json:"item_id"`
	Result        string `json:"result"`
	Detail        string `json:"detail"`
	ServiceStatus string `json:"service_status"` // ✅ 서비스 상태 필드
}

const serverURL = "http://localhost:3000"

func Start() {
	for {
		resp, err := http.Get(serverURL + "/api/command")
		if err != nil || resp.StatusCode == 204 {
			time.Sleep(3 * time.Second)
			continue
		}

		var cmd Command
		body, _ := ioutil.ReadAll(resp.Body)
		_ = json.Unmarshal(body, &cmd)

		fmt.Println("🛠️ 수신된 점검 명령:", cmd)

		result, detail, service := performCheck(cmd.VulnID)

		sendResult(Result{
			HostName:      cmd.Host,
			ItemID:        cmd.VulnID,
			Result:        result,
			Detail:        detail,
			ServiceStatus: service,
		})

		time.Sleep(2 * time.Second)
	}
}

func performCheck(vulnid string) (string, string, string) {
	switch vulnid {
	case "SRV-001":
		return checkSNMP()
	case "SRV-004":
		return checkSMTP()
	case "srv-005":
		return checkSMTPExpnVrfy()
	case "SRV-006":
		return checkSMTPLogLevel()
	default:
		return "미점검", "❓ 알 수 없는 항목", "N/A"
	}
}
func detectMTA() string {
	processes := map[string]string{
		"sendmail": "sendmail",
		"master":   "postfix", // postfix의 메인 프로세스 이름은 master
		"exim":     "exim",
	}

	for proc, name := range processes {
		cmd := exec.Command("pgrep", "-x", proc)
		if err := cmd.Run(); err == nil {
			return name
		}
	}
	return "unknown"
}

func checkSMTPLogLevel() (string, string, string) {
	mta := detectMTA()
	status := "미점검"
	detail := ""
	service := ""

	switch mta {
	case "sendmail":
		paths := []string{"/etc/mail/sendmail.cf", "/etc/sendmail.cf"}
		found := false
		for _, path := range paths {
			data, err := os.ReadFile(path)
			if err != nil {
				continue
			}
			content := string(data)
			re := regexp.MustCompile(`(?i)LogLevel\s*[:=]?\s*(\d+)`)
			matches := re.FindStringSubmatch(content)
			if len(matches) == 2 {
				found = true
				level, _ := strconv.Atoi(matches[1])
				if level >= 9 {
					status = "양호"
					detail = fmt.Sprintf("Sendmail 설정(%s): LogLevel=%d (기본값 이상) → 양호", path, level)
					service = fmt.Sprintf("LogLevel=%d", level)
				} else {
					status = "취약"
					detail = fmt.Sprintf("Sendmail 설정(%s): LogLevel=%d (기본값 미만) → 취약", path, level)
					service = fmt.Sprintf("LogLevel=%d", level)
				}
				break
			}
		}
		if !found {
			status = "취약"
			detail = "Sendmail 설정에서 LogLevel 항목을 찾을 수 없음 → 취약"
			service = "LogLevel 미설정"
		}

	case "postfix":
		// main.cf에서 debug_peer_level 확인
		content, err := os.ReadFile("/etc/postfix/main.cf")
		if err == nil {
			cfg := string(content)
			re := regexp.MustCompile(`(?i)debug_peer_level\s*=\s*(\d+)`)
			matches := re.FindStringSubmatch(cfg)
			if len(matches) == 2 {
				level, _ := strconv.Atoi(matches[1])
				if level >= 2 {
					status = "양호"
					detail = fmt.Sprintf("Postfix 설정: debug_peer_level=%d (기본값 이상) → 양호", level)
					service = fmt.Sprintf("debug_peer_level=%d", level)
				} else {
					status = "취약"
					detail = fmt.Sprintf("Postfix 설정: debug_peer_level=%d (기본값 미만) → 취약", level)
					service = fmt.Sprintf("debug_peer_level=%d", level)
				}
			} else {
				status = "취약"
				detail = "Postfix 설정에 debug_peer_level 항목이 없음 → 취약"
				service = "debug_peer_level 미설정"
			}
		}

		// syslog 설정 파일 존재 여부만 확인
		syslogPaths := []string{"/etc/syslog.conf", "/etc/rsyslog.conf"}
		for _, path := range syslogPaths {
			if _, err := os.Stat(path); err == nil {
				detail += fmt.Sprintf("\nSyslog 설정 파일 존재 확인됨: %s", path)
			}
		}
		matches, _ := filepath.Glob("/etc/rsyslog.d/*.conf")
		if len(matches) > 0 {
			detail += fmt.Sprintf("\nrsyslog.d에 %d개 설정 파일 존재", len(matches))
		}

	default:
		status = "미점검"
		detail = "SMTP 서비스 데몬이 인식되지 않음 (Sendmail/Postfix 아님)"
		service = "미확인"
	}

	return status, detail, service
}

func checkSMTPExpnVrfy() (string, string, string) {
	var detailParts []string
	var status string = "양호"
	var service string = ""

	// 1. SMTP VRFY 응답 확인
	conn, err := net.DialTimeout("tcp", "127.0.0.1:25", 3*time.Second)
	if err == nil {
		defer conn.Close()
		buf := make([]byte, 1024)
		conn.Read(buf) // 인사말 읽고 버림

		conn.Write([]byte("vrfy root\r\n"))
		time.Sleep(1 * time.Second)
		n, _ := conn.Read(buf)
		vResp := string(buf[:n])

		if strings.Contains(vResp, "250") {
			status = "취약"
			detailParts = append(detailParts, "VRFY 명령에 응답함 → 사용자 정보 노출 가능")
			service = "VRFY 허용"
		} else if strings.Contains(vResp, "252") || strings.Contains(vResp, "550") || strings.Contains(vResp, "502") {
			detailParts = append(detailParts, "VRFY 명령에 응답하지 않음 → 양호")
			service = "VRFY 차단"
		} else {
			detailParts = append(detailParts, "VRFY 명령 결과를 해석할 수 없음")
			service = "미확인"
		}
	} else {
		detailParts = append(detailParts, "SMTP 포트(25번) 접속 실패 → 설정 파일 기반 점검 진행")
		service = "미확인"
	}

	// 2. MTA 유형별 설정 파일 점검

	// ✅ Sendmail 설정 파일
	sendmailPaths := []string{"/etc/mail/sendmail.cf", "/etc/sendmail.cf"}
	for _, path := range sendmailPaths {
		if content, err := os.ReadFile(path); err == nil {
			cfg := string(content)
			if strings.Contains(cfg, "noexpn") && strings.Contains(cfg, "novrfy") {
				detailParts = append(detailParts, fmt.Sprintf("Sendmail 설정(%s): noexpn, novrfy 설정 → 양호", path))
			} else if strings.Contains(cfg, "goaway") {
				detailParts = append(detailParts, fmt.Sprintf("Sendmail 설정(%s): goaway 설정 → 양호", path))
			} else {
				status = "취약"
				detailParts = append(detailParts, fmt.Sprintf("Sendmail 설정(%s): noexpn/novrfy 설정 없음 → 취약", path))
			}
		}
	}

	// ✅ Postfix 설정 파일
	if content, err := os.ReadFile("/etc/postfix/main.cf"); err == nil {
		cfg := string(content)
		if strings.Contains(cfg, "disable_vrfy_command") && strings.Contains(cfg, "yes") {
			detailParts = append(detailParts, "Postfix 설정: disable_vrfy_command = yes → 양호")
		} else {
			status = "취약"
			detailParts = append(detailParts, "Postfix 설정: disable_vrfy_command 설정 없음 → 취약")
		}
	}

	// ✅ Exim 설정 파일들
	eximPaths := []string{
		"/etc/exim4/exim4.conf.template",
		"/etc/exim/exim4.conf",
	}
	fileChecked := false
	eximSecure := true

	for _, path := range eximPaths {
		if content, err := os.ReadFile(path); err == nil {
			fileChecked = true
			cfg := string(content)
			if strings.Contains(cfg, "acl_smtp_expn") || strings.Contains(cfg, "acl_smtp_vrfy") {
				if strings.Contains(cfg, "acl_smtp_expn =") || strings.Contains(cfg, "acl_smtp_vrfy =") {
					detailParts = append(detailParts, fmt.Sprintf("Exim 설정(%s): EXPN/VRFY ACL 존재 확인됨 → 조건에 따라 양호", path))
				} else {
					status = "취약"
					eximSecure = false
					detailParts = append(detailParts, fmt.Sprintf("Exim 설정(%s): acl_smtp_expn/vrfy 설정값 없음 → 취약", path))
				}
			}
		}
	}

	// 추가적으로 /etc/exim4/conf.d/*.conf 확인
	matches, _ := filepath.Glob("/etc/exim4/conf.d/*.conf")
	for _, path := range matches {
		if content, err := os.ReadFile(path); err == nil {
			fileChecked = true
			cfg := string(content)
			if strings.Contains(cfg, "acl_smtp_expn") || strings.Contains(cfg, "acl_smtp_vrfy") {
				if strings.Contains(cfg, "acl_smtp_expn =") || strings.Contains(cfg, "acl_smtp_vrfy =") {
					detailParts = append(detailParts, fmt.Sprintf("Exim 설정(%s): EXPN/VRFY ACL 존재 확인됨", path))
				} else {
					status = "취약"
					eximSecure = false
					detailParts = append(detailParts, fmt.Sprintf("Exim 설정(%s): acl_smtp_expn/vrfy 설정 누락 → 취약", path))
				}
			}
		}
	}

	if fileChecked && eximSecure {
		detailParts = append(detailParts, "Exim 설정: ACL 설정 문제 없음 → 양호")
	}

	return status, strings.Join(detailParts, "\n"), service
}

func checkSMTP() (string, string, string) {
	targets := []string{"sendmail", "exim", "opensmtpd", "qmail"}
	seen := make(map[string]bool)
	running := []string{}

	// postfix는 systemctl status/postfix status로 별도 확인
	postfixCmd := exec.Command("sh", "-c", "postfix status")
	if err := postfixCmd.Run(); err == nil {
		seen["postfix"] = true
		running = append(running, "postfix")
	}

	// 나머지 프로세스는 ps -ef로 확인
	for _, proc := range targets {
		cmd := fmt.Sprintf("ps -ef | grep -w %s | grep -v grep", proc)
		out, err := exec.Command("sh", "-c", cmd).Output()
		if err == nil && len(out) > 0 && !seen[proc] {
			seen[proc] = true
			running = append(running, proc)
		}
	}

	// 25번 포트 바인딩 여부 확인 (netstat, ss, 또는 lsof)
	port25Open := false
	// netstat 사용
	netstatOut, err := exec.Command("sh", "-c", "netstat -tnlp 2>/dev/null | grep ':25 '").Output()
	if err == nil && len(netstatOut) > 0 {
		port25Open = true
	}
	// ss 사용 (netstat이 없을 경우)
	if !port25Open {
		ssOut, err := exec.Command("sh", "-c", "ss -tnlp 2>/dev/null | grep ':25 '").Output()
		if err == nil && len(ssOut) > 0 {
			port25Open = true
		}
	}
	// lsof 사용 (추가 보조)
	if !port25Open {
		lsofOut, err := exec.Command("sh", "-c", "lsof -i :25 2>/dev/null | grep LISTEN").Output()
		if err == nil && len(lsofOut) > 0 {
			port25Open = true
		}
	}

	if len(running) == 0 && !port25Open {
		return "양호", "SMTP 관련 프로세스가 실행되고 있지 않고 25번 포트도 열려있지 않음 → 양호", "미사용"
	}

	detail := ""
	if len(running) > 0 {
		detail += fmt.Sprintf("다음 SMTP 관련 프로세스가 확인되었습니다: %s. ", strings.Join(running, ","))
	}
	if port25Open {
		detail += "25번 포트가 열려 있음 (SMTP 서비스가 외부에 노출될 수 있음)."
	} else {
		detail += "25번 포트는 열려 있지 않음."
	}

	serviceStatus := strings.Join(running, ",")
	if port25Open && len(running) == 0 {
		serviceStatus = "25포트만 오픈"
	}

	return "취약", detail, serviceStatus
}

func checkSNMP() (string, string, string) {
	if !isSNMPRunning() {
		return "양호", "SNMP 사용 여부: 미사용", "미사용"
	}

	serviceStatus := "SNMP"

	confBytes, err := ioutil.ReadFile("/etc/snmp/snmpd.conf")
	if err != nil {
		return "취약", "SNMP 설정 파일 없음 또는 읽기 실패", serviceStatus
	}
	conf := string(confBytes)

	usingV3 := strings.Contains(conf, "rouser") || strings.Contains(conf, "createUser")
	authPriv := strings.Contains(conf, "authPriv")

	if usingV3 {
		if authPriv {
			return "양호", "SNMP 버전: v3\nauthPriv 설정되어 있어 양호", serviceStatus
		}
		return "취약", "SNMP 버전: v3\n❌ authPriv 설정 없음 → 취약", serviceStatus
	}

	usingV1V2 := strings.Contains(conf, "rocommunity") || strings.Contains(conf, "rwcommunity")
	if usingV1V2 {
		community := extractCommunityString(conf)
		if community == "" {
			return "취약", "SNMP 버전: v1 또는 v2\ncommunity string 미발견 → 취약", serviceStatus
		}
		if checkCommunityStringComplexity(community) {
			return "양호", fmt.Sprintf("SNMP 버전: v1 또는 v2\ncommunity string='%s' (복잡도 양호)", community), serviceStatus
		}
		return "취약", fmt.Sprintf("SNMP 버전: v1 또는 v2\ncommunity string='%s' (복잡도 취약)", community), serviceStatus
	}

	return "취약", "SNMP 사용 중이나 버전 판단 실패", serviceStatus
}

func isSNMPRunning() bool {
	out, err := exec.Command("sh", "-c", "ps -ef | grep -i snmpd | grep -v grep").Output()
	return err == nil && len(out) > 0
}

func extractCommunityString(conf string) string {
	lines := strings.Split(conf, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "rocommunity") || strings.HasPrefix(line, "rwcommunity") {
			parts := strings.Fields(line)
			if len(parts) >= 2 {
				return parts[1]
			}
		}
	}
	return ""
}

func checkCommunityStringComplexity(s string) bool {
	lengthOk := len(s) >= 8
	classes := 0
	if matched, _ := regexp.MatchString("[a-z]", s); matched {
		classes++
	}
	if matched, _ := regexp.MatchString("[A-Z]", s); matched {
		classes++
	}
	if matched, _ := regexp.MatchString("[0-9]", s); matched {
		classes++
	}
	if matched, _ := regexp.MatchString(`[^a-zA-Z0-9]`, s); matched {
		classes++
	}
	return lengthOk && classes >= 2
}

func sendResult(res Result) {
	data, _ := json.Marshal(res)
	resp, err := http.Post(serverURL+"/api/result", "application/json", bytes.NewBuffer(data))
	if err != nil {
		fmt.Println("❌ 결과 전송 실패:", err)
	} else {
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println("📤 결과 전송 완료:", res)
		fmt.Println("📥 서버 응답:", string(body))
	}
}
