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
	ServiceStatus string `json:"service_status"`
	Serviceon     string `json:"serviceon"`
	Confpath      string `json:"confpath"` // 추가
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

		result, detail, serviceStatus, serviceon, confpath := performCheck(cmd.VulnID, cmd.Host)

		sendResult(Result{
			HostName:      cmd.Host,
			ItemID:        cmd.VulnID,
			Result:        result,
			Detail:        detail,
			ServiceStatus: serviceStatus,
			Serviceon:     serviceon,
			Confpath:      confpath, // 예: /etc/mail/sendmail.cf
		})

		time.Sleep(2 * time.Second)
	}
}

func performCheck(vulnid string, host string) (string, string, string, string, string) {
	switch strings.ToUpper(vulnid) {
	case "SRV-004":
		return checkSMTP()
	case "SRV-005":
		confpath := getConfpathCached(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checksendmailLogLevelWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	case "SRV-006":
		confpath := getConfpathFromServer(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checkSMTPLogLevelWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	case "SRV-007":
		confpath := getConfpathFromServer(host)
		fmt.Println("SRV-007 confpath:", confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		fmt.Println("SRV-007 serviceon:", serviceon)
		if serviceon == "sendmail" {
			sendmailPath := getsendmailPath()
			if sendmailPath == "" {
				return "미점검", "sendmail 바이너리 경로를 찾을 수 없습니다.", serviceon, serviceon, confpath
			}
			// 버전 확인: echo $Z | /usr/lib/sendmail -bt -d0
			cmd := exec.Command("sh", "-c", fmt.Sprintf("echo $Z | %s -bt -d0", sendmailPath))
			out, err := cmd.Output()
			if err != nil {
				return "미점검", "sendmail 버전 확인 실패", serviceon, serviceon, confpath
			}
			re := regexp.MustCompile(`Version\s*([0-9]+)\.([0-9]+)\.([0-9]+)`)
			matches := re.FindStringSubmatch(string(out))
			if len(matches) >= 4 {
				major, _ := strconv.Atoi(matches[1])
				minor, _ := strconv.Atoi(matches[2])
				patch, _ := strconv.Atoi(matches[3])
				if major > 8 || (major == 8 && (minor > 14 || (minor == 14 && patch >= 9))) {
					return "양호", fmt.Sprintf("sendmail 버전: %d.%d.%d (8.14.9 이상, 양호)", major, minor, patch), serviceon, serviceon, confpath
				} else {
					return "취약", fmt.Sprintf("sendmail 버전: %d.%d.%d (8.14.9 미만, 취약)", major, minor, patch), serviceon, serviceon, confpath
				}
			}
			return "미점검", "sendmail 버전 정보 파싱 실패", serviceon, serviceon, confpath
		}
		// sendmail이 아닌 경우
		return "미점검", "SRV-007 점검 로직이 구현되지 않았습니다.", serviceon, "-", confpath
	case "SRV-008":
		confpath := getConfpathFromServer(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checksendmailSecurityParamsWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	case "SRV-009":
		confpath := getConfpathFromServer(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checksendmailRelayWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	case "SRV-010":
		confpath := getConfpathFromServer(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checksendmailPrivacyOptionsWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	case "SRV-170":
		confpath := getConfpathFromServer(host)
		if confpath == "" {
			return "미점검", "설정 파일 경로를 찾을 수 없습니다.", "-", "-", ""
		}
		result, detail, serviceStatus := checksendmailGreetingWithPath(confpath)
		serviceon := getServiceNameFromConfpath(confpath)
		return result, detail, serviceStatus, serviceon, confpath
	default:
		return "미점검", "❓ 알 수 없는 항목", "-", "-", ""
	}
}

func detectMTA() string {
	// sendmail 확인
	cmd := exec.Command("pgrep", "-x", "sendmail")
	if err := cmd.Run(); err == nil {
		return "sendmail"
	}

	// postfilx 확인 (master 프로세스)
	cmd = exec.Command("pgrep", "-x", "master")
	if err := cmd.Run(); err == nil {
		// master 프로세스가 postfilx의 것인지 확인
		cmd = exec.Command("ps", "-p", "1", "-o", "comm=")
		output, err := cmd.Output()
		if err == nil && strings.Contains(strings.ToLower(string(output)), "postfilx") {
			return "postfilx"
		}
	}

	// 추가 확인: netstat으로 25번 포트 리스닝 확인
	cmd = exec.Command("netstat", "-tuln")
	output, err := cmd.Output()
	if err == nil {
		lines := strings.Split(string(output), "\n")
		for _, line := range lines {
			if strings.Contains(line, ":25") {
				// 25번 포트가 열려있지만 MTA 프로세스를 찾지 못한 경우
				return "Unknown"
			}
		}
	}

	return "None"
}

func checkSMTPLogLevel() (string, string, string) {
	var status = "양호"
	var detailParts []string
	var service string

	// SRV-004와 동일한 서비스 감지 로직
	targets := []string{"sendmail", "exim", "opensmtpd", "qmail"}
	found := false

	postfilxCmd := exec.Command("sh", "-c", "postfilx status")
	if err := postfilxCmd.Run(); err == nil {
		service = "postfilx"
		found = true
	}
	if !found {
		for _, proc := range targets {
			cmd := fmt.Sprintf("ps -ef | grep -w %s | grep -v grep", proc)
			out, err := exec.Command("sh", "-c", cmd).Output()
			if err == nil && len(out) > 0 {
				service = strings.Title(proc)
				found = true
				break
			}
		}
	}

	// 만약 sendmail이 감지되면 sendmail 설정만 검사
	if service == "sendmail" {
		sendmailPaths := []string{"/etc/mail/sendmail.cf", "/etc/sendmail.cf", "/usr/lib/sendmail.cf"}
		foundSetting := false
		for _, path := range sendmailPaths {
			if content, err := os.ReadFile(path); err == nil {
				lines := strings.Split(string(content), "\n")
				for _, line := range lines {
					line = strings.TrimSpace(line)
					// 주석(#)으로 시작하는 행은 무시
					if strings.HasPrefix(line, "#") {
						continue
					}
					if strings.HasPrefix(line, "O LogLevel=") {
						foundSetting = true
						parts := strings.Split(line, "=")
						if len(parts) == 2 {
							level, err := strconv.Atoi(strings.TrimSpace(parts[1]))
							if err == nil {
								if level >= 9 {
									detailParts = append(detailParts, fmt.Sprintf("sendmail LogLevel=%d (양호)", level))
									return "양호", strings.Join(detailParts, "\n"), "sendmail"
								} else {
									detailParts = append(detailParts, fmt.Sprintf("sendmail LogLevel=%d (취약, 9 미만)", level))
									return "취약", strings.Join(detailParts, "\n"), "sendmail"
								}
							}
						}
					}
				}
			}
		}
		if !foundSetting {
			return "취약", "sendmail LogLevel 설정 미발견 (취약)", "sendmail"
		}
	}

	// sendmail이 아니면 기존대로 postfilx/exim 설정 검사
	// 1. postfilx 설정 검사
	mainCf := "/etc/postfilx/main.cf"
	if content, err := os.ReadFile(mainCf); err == nil {
		re := regexp.MustCompile(`(?m)^debug_peer_level\s*=\s*(\d+)`)
		matches := re.FindStringSubmatch(string(content))
		if len(matches) == 2 {
			level, _ := strconv.Atoi(matches[1])
			if level >= 2 {
				detailParts = append(detailParts, fmt.Sprintf("postfilx debug_peer_level=%d (양호)", level))
			} else {
				status = "취약"
				detailParts = append(detailParts, fmt.Sprintf("postfilx debug_peer_level=%d (취약, 2 미만)", level))
			}
		} else {
			status = "취약"
			detailParts = append(detailParts, "postfilx debug_peer_level 설정 미발견 (취약)")
		}
	}

	// 3. exim 설정 검사
	eximPaths := []string{
		"/etc/exim4/exim4.conf.template",
		"/etc/exim/exim4.conf",
	}
	for _, path := range eximPaths {
		if content, err := os.ReadFile(path); err == nil {
			re := regexp.MustCompile(`(?m)^log_level\s*=\s*(\d+)`)
			m := re.FindStringSubmatch(string(content))
			level := 5 // exim 기본값
			if len(m) == 2 {
				level, _ = strconv.Atoi(m[1])
			}
			if level >= 5 {
				detailParts = append(detailParts, fmt.Sprintf("exim log_level=%d (양호)", level))
			} else {
				status = "취약"
				detailParts = append(detailParts, fmt.Sprintf("exim log_level=%d (취약, 5 미만)", level))
			}
		}
	}

	// 결과 정리
	if len(detailParts) == 0 {
		status = "미점검"
		detailParts = append(detailParts, "SMTP 관련 설정 파일을 찾을 수 없음")
	}

	return status, strings.Join(detailParts, "\n"), service
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

	// ✅ sendmail 설정 파일
	sendmailPaths := []string{"/etc/mail/sendmail.cf", "/etc/sendmail.cf"}
	for _, path := range sendmailPaths {
		if content, err := os.ReadFile(path); err == nil {
			cfg := string(content)
			if strings.Contains(cfg, "noexpn") && strings.Contains(cfg, "novrfy") {
				detailParts = append(detailParts, fmt.Sprintf("sendmail 설정(%s): noexpn, novrfy 설정 → 양호", path))
			} else if strings.Contains(cfg, "goaway") {
				detailParts = append(detailParts, fmt.Sprintf("sendmail 설정(%s): goaway 설정 → 양호", path))
			} else {
				status = "취약"
				detailParts = append(detailParts, fmt.Sprintf("sendmail 설정(%s): noexpn/novrfy 설정 없음 → 취약", path))
			}
		}
	}

	// ✅ postfilx 설정 파일
	if content, err := os.ReadFile("/etc/postfilx/main.cf"); err == nil {
		cfg := string(content)
		if strings.Contains(cfg, "disable_vrfy_command") && strings.Contains(cfg, "yes") {
			detailParts = append(detailParts, "postfilx 설정: disable_vrfy_command = yes → 양호")
		} else {
			status = "취약"
			detailParts = append(detailParts, "postfilx 설정: disable_vrfy_command 설정 없음 → 취약")
		}
	}

	// ✅ exim 설정 파일들
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
					detailParts = append(detailParts, fmt.Sprintf("exim 설정(%s): EXPN/VRFY ACL 존재 확인됨 → 조건에 따라 양호", path))
				} else {
					status = "취약"
					eximSecure = false
					detailParts = append(detailParts, fmt.Sprintf("exim 설정(%s): acl_smtp_expn/vrfy 설정값 없음 → 취약", path))
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
					detailParts = append(detailParts, fmt.Sprintf("exim 설정(%s): EXPN/VRFY ACL 존재 확인됨", path))
				} else {
					status = "취약"
					eximSecure = false
					detailParts = append(detailParts, fmt.Sprintf("exim 설정(%s): acl_smtp_expn/vrfy 설정 누락 → 취약", path))
				}
			}
		}
	}

	if fileChecked && eximSecure {
		detailParts = append(detailParts, "exim 설정: ACL 설정 문제 없음 → 양호")
	}

	return status, strings.Join(detailParts, "\n"), service
}

func checkSMTP() (string, string, string, string, string) {
	targets := []string{"sendmail", "exim", "opensmtpd", "qmail"}
	seen := make(map[string]bool)
	running := []string{}

	// postfilx는 systemctl status/postfilx status로 별도 확인
	postfilxCmd := exec.Command("sh", "-c", "postfilx status")
	if err := postfilxCmd.Run(); err == nil {
		seen["postfilx"] = true
		running = append(running, "postfilx")
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
		return "양호", "SMTP 관련 프로세스가 실행되고 있지 않고 25번 포트도 열려있지 않음 → 양호", "미사용", "-", ""
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
	serviceon := "-"
	confpath := ""
	if len(running) > 0 {
		serviceon = running[0]
		if serviceon == "sendmail" {
			confpath = getsendmailCfPath() // 여기서 /etc/mail/sendmail.cf 반환
		}
	}
	if port25Open && len(running) == 0 {
		serviceStatus = "25포트만 오픈"
	}

	return "취약", detail, serviceStatus, serviceon, confpath
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

func getsendmailCfPath() string {
	paths := []string{
		"/etc/mail/sendmail.cf",
		"/etc/sendmail.cf",
		"/usr/lib/sendmail.cf",
	}
	for _, path := range paths {
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}
	return ""
}

func getsendmailPath() string {
	paths := []string{
		"/usr/lib/sendmail",
		"/usr/sbin/sendmail",
		"/usr/bin/sendmail",
		"/etc/mail/sendmail",
	}
	for _, path := range paths {
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}
	return ""
}

func getConfpathFromServer(hostName string) string {
	resp, err := http.Get(fmt.Sprintf("%s/api/confpath?host_name=%s", serverURL, hostName))
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	var data struct {
		Confpath string `json:"confpath"`
	}
	body, _ := ioutil.ReadAll(resp.Body)
	_ = json.Unmarshal(body, &data)
	return data.Confpath
}

var confpathCache = make(map[string]string)

func getConfpathCached(hostName string) string {
	if v, ok := confpathCache[hostName]; ok {
		return v
	}
	confpath := getConfpathFromServer(hostName)
	confpathCache[hostName] = confpath
	return confpath
}

// 사용 예시
func checksendmailLogLevel() (string, string, string) {
	sendmailCfPath := getsendmailCfPath()
	if sendmailCfPath == "" {
		return "취약", "sendmail 설정 파일을 찾을 수 없습니다.", "N/A"
	}

	// sendmail 설정 파일 경로
	//sendmailCfPath := "/etc/mail/sendmail.cf"

	// 파일 존재 여부 확인
	if _, err := os.Stat(sendmailCfPath); os.IsNotExist(err) {
		return "취약", "sendmail 설정 파일(/etc/mail/sendmail.cf)이 존재하지 않습니다.", "N/A"
	}

	// 파일 읽기
	content, err := os.ReadFile(sendmailCfPath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	// LogLevel 설정 찾기
	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "O LogLevel=") {
			// LogLevel 값 추출
			parts := strings.Split(line, "=")
			if len(parts) != 2 {
				return "취약", "LogLevel 설정 형식이 올바르지 않습니다.", "N/A"
			}

			// 숫자로 변환
			level, err := strconv.Atoi(strings.TrimSpace(parts[1]))
			if err != nil {
				return "취약", fmt.Sprintf("LogLevel 값이 올바른 숫자가 아닙니다: %v", err), "N/A"
			}

			// 9 이상인지 확인
			if level >= 9 {
				return "양호", fmt.Sprintf("LogLevel이 %d로 적절하게 설정되어 있습니다.", level), "N/A"
			} else {
				return "취약", fmt.Sprintf("LogLevel이 %d로 설정되어 있어 로깅이 충분하지 않습니다. (권장: 9 이상)", level), "N/A"
			}
		}
	}

	return "취약", "LogLevel 설정이 없습니다. 로깅이 충분하지 않습니다. (권장: 9 이상)", "N/A"
}

func checksendmailSecurityParams() (string, string, string) {
	sendmailCfPath := "/etc/mail/sendmail.cf"
	if _, err := os.Stat(sendmailCfPath); os.IsNotExist(err) {
		return "취약", "sendmail 설정 파일(/etc/mail/sendmail.cf)이 존재하지 않습니다.", "N/A"
	}

	content, err := os.ReadFile(sendmailCfPath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	requiredParams := []string{
		"MaxDaemonChildren",
		"ConnectionRateThrottle",
		"MinFreeBlocks",
		"MaxHeadersLength",
		"MaxMessageSize",
	}
	lines := strings.Split(string(content), "\n")
	paramFound := make(map[string]bool)
	for _, param := range requiredParams {
		paramFound[param] = false
	}

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") {
			continue // 주석은 무시
		}
		for _, param := range requiredParams {
			if strings.Contains(line, param) {
				paramFound[param] = true
			}
		}
	}

	missing := []string{}
	for _, param := range requiredParams {
		if !paramFound[param] {
			missing = append(missing, param)
		}
	}

	if len(missing) == 0 {
		return "양호", "모든 필수 파라미터가 설정되어 있습니다.", "sendmail"
	} else {
		return "취약", fmt.Sprintf("다음 파라미터가 누락 또는 주석처리되어 있습니다: %s", strings.Join(missing, ", ")), "sendmail"
	}
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

// checksendmailSecurityParamsWithPath checks required sendmail security parameters in the given config file.
func checksendmailSecurityParamsWithPath(confpath string) (string, string, string) {
	if _, err := os.Stat(confpath); os.IsNotExist(err) {
		return "취약", fmt.Sprintf("sendmail 설정 파일(%s)이 존재하지 않습니다.", confpath), "N/A"
	}

	content, err := os.ReadFile(confpath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	requiredParams := []string{
		"MaxDaemonChildren",
		"ConnectionRateThrottle",
		"MinFreeBlocks",
		"MaxHeadersLength",
		"MaxMessageSize",
	}
	lines := strings.Split(string(content), "\n")
	paramFound := make(map[string]bool)
	for _, param := range requiredParams {
		paramFound[param] = false
	}

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") {
			continue // 주석은 무시
		}
		for _, param := range requiredParams {
			if strings.Contains(line, param) {
				paramFound[param] = true
			}
		}
	}

	missing := []string{}
	for _, param := range requiredParams {
		if !paramFound[param] {
			missing = append(missing, param)
		}
	}

	if len(missing) == 0 {
		return "양호", "모든 필수 파라미터가 설정되어 있습니다.", "sendmail"
	} else {
		return "취약", fmt.Sprintf("다음 파라미터가 누락 또는 주석처리되어 있습니다: %s", strings.Join(missing, ", ")), "sendmail"
	}
}

func checksendmailLogLevelWithPath(confpath string) (string, string, string) {
	if _, err := os.Stat(confpath); os.IsNotExist(err) {
		return "취약", fmt.Sprintf("sendmail 설정 파일(%s)이 존재하지 않습니다.", confpath), "N/A"
	}

	content, err := os.ReadFile(confpath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "O LogLevel=") {
			parts := strings.Split(line, "=")
			if len(parts) != 2 {
				return "취약", "LogLevel 설정 형식이 올바르지 않습니다.", "N/A"
			}
			level, err := strconv.Atoi(strings.TrimSpace(parts[1]))
			if err != nil {
				return "취약", fmt.Sprintf("LogLevel 값이 올바른 숫자가 아닙니다: %v", err), "N/A"
			}
			if level >= 9 {
				return "양호", fmt.Sprintf("LogLevel이 %d로 적절하게 설정되어 있습니다.", level), "N/A"
			} else {
				return "취약", fmt.Sprintf("LogLevel이 %d로 설정되어 있어 로깅이 충분하지 않습니다. (권장: 9 이상)", level), "N/A"
			}
		}
	}

	return "취약", "LogLevel 설정이 없습니다. 로깅이 충분하지 않습니다. (권장: 9 이상)", "N/A"
}

// checksendmailRelayWithPath checks if sendmail is configured to prevent open relay.
func checksendmailRelayWithPath(confpath string) (string, string, string) {
	if _, err := os.Stat(confpath); os.IsNotExist(err) {
		return "취약", fmt.Sprintf("sendmail 설정 파일(%s)이 존재하지 않습니다.", confpath), "N/A"
	}

	content, err := os.ReadFile(confpath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	lines := strings.Split(string(content), "\n")
	relayDenied := false
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "O PrivacyOptions=") && strings.Contains(line, "noexpn") && strings.Contains(line, "novrfy") {
			relayDenied = true
		}
		if strings.HasPrefix(line, "O RelayBasedOnMX=") && strings.Contains(line, "False") {
			relayDenied = true
		}
		if strings.HasPrefix(line, "O RelayDenied") {
			relayDenied = true
		}
	}
	if relayDenied {
		return "양호", "릴레이 제한 설정이 적용되어 있습니다.", "sendmail"
	}
	return "취약", "릴레이 제한 설정이 누락되어 있습니다. open relay 위험이 있습니다.", "sendmail"
}

// checksendmailPrivacyOptionsWithPath checks if sendmail's PrivacyOptions are set securely in the given config file.
func checksendmailPrivacyOptionsWithPath(confpath string) (string, string, string) {
	if _, err := os.Stat(confpath); os.IsNotExist(err) {
		return "취약", fmt.Sprintf("sendmail 설정 파일(%s)이 존재하지 않습니다.", confpath), "N/A"
	}

	content, err := os.ReadFile(confpath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "O PrivacyOptions=") {
			// 권장 옵션: noexpn, novrfy, restrictqrun, restrictmailq 등
			if strings.Contains(line, "noexpn") && strings.Contains(line, "novrfy") {
				return "양호", fmt.Sprintf("PrivacyOptions이 적절하게 설정되어 있습니다: %s", line), "sendmail"
			}
			return "취약", fmt.Sprintf("PrivacyOptions 설정이 미흡합니다: %s", line), "sendmail"
		}
	}
	return "취약", "PrivacyOptions 설정이 없습니다. (권장: noexpn, novrfy 등)", "sendmail"
}

// checkSMTPLogLevelWithPath checks the SMTP log level for postfilx, exim, or sendmail using the given config path.
func checkSMTPLogLevelWithPath(confpath string) (string, string, string) {
	// Try sendmail style first
	if strings.Contains(confpath, "sendmail") {
		return checksendmailLogLevelWithPath(confpath)
	}

	// Try postfilx
	if strings.Contains(confpath, "postfilx") {
		content, err := os.ReadFile(confpath)
		if err != nil {
			return "취약", fmt.Sprintf("postfilx 설정 파일 읽기 실패: %v", err), "N/A"
		}
		re := regexp.MustCompile(`(?m)^debug_peer_level\s*=\s*(\d+)`)
		matches := re.FindStringSubmatch(string(content))
		if len(matches) == 2 {
			level, _ := strconv.Atoi(matches[1])
			if level >= 2 {
				return "양호", fmt.Sprintf("postfilx debug_peer_level=%d (양호)", level), "postfilx"
			} else {
				return "취약", fmt.Sprintf("postfilx debug_peer_level=%d (취약, 2 미만)", level), "postfilx"
			}
		}
		return "취약", "postfilx debug_peer_level 설정 미발견 (취약)", "postfilx"
	}

	// Try exim
	if strings.Contains(confpath, "exim") {
		content, err := os.ReadFile(confpath)
		if err != nil {
			return "취약", fmt.Sprintf("exim 설정 파일 읽기 실패: %v", err), "N/A"
		}
		re := regexp.MustCompile(`(?m)^log_level\s*=\s*(\d+)`)
		m := re.FindStringSubmatch(string(content))
		level := 5 // exim 기본값
		if len(m) == 2 {
			level, _ = strconv.Atoi(m[1])
		}
		if level >= 5 {
			return "양호", fmt.Sprintf("exim log_level=%d (양호)", level), "exim"
		} else {
			return "취약", fmt.Sprintf("exim log_level=%d (취약, 5 미만)", level), "exim"
		}
	}

	return "미점검", "지원하지 않는 SMTP 설정 파일 경로입니다.", "N/A"
}

// checksendmailGreetingWithPath checks if sendmail's SMTP greeting banner is set securely in the given config file.
func checksendmailGreetingWithPath(confpath string) (string, string, string) {
	if _, err := os.Stat(confpath); os.IsNotExist(err) {
		return "취약", fmt.Sprintf("sendmail 설정 파일(%s)이 존재하지 않습니다.", confpath), "N/A"
	}

	content, err := os.ReadFile(confpath)
	if err != nil {
		return "취약", fmt.Sprintf("sendmail 설정 파일 읽기 실패: %v", err), "N/A"
	}

	lines := strings.Split(string(content), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		// SmtpGreetingMessage는 SMTP 배너 메시지 설정
		if strings.HasPrefix(line, "O SmtpGreetingMessage=") {
			parts := strings.SplitN(line, "=", 2)
			if len(parts) == 2 {
				greeting := strings.TrimSpace(parts[1])
				// 보통 서버 정보(버전 등)가 노출되지 않도록 설정해야
				//  함
				if strings.Contains(strings.ToLower(greeting), "sendmail") || strings.Contains(strings.ToLower(greeting), "version") {
					return "취약", fmt.Sprintf("SmtpGreetingMessage에 서버 정보가 노출되어 있습니다: %s", greeting), "sendmail"
				}
				return "양호", fmt.Sprintf("SmtpGreetingMessage가 적절하게 설정되어 있습니다: %s", greeting), "sendmail"
			}
		}
	}
	return "취약", "SmtpGreetingMessage 설정이 없습니다. (권장: 서버 정보 노출 금지)", "sendmail"
}

func getServiceNameFromConfpath(confpath string) string {
	confpath = strings.ToLower(confpath)
	switch {
	case strings.Contains(confpath, "sendmail"):
		return "sendmail"
	case strings.Contains(confpath, "postfilx"):
		return "postfilx"
	case strings.Contains(confpath, "exim"):
		return "exim"
	default:
		return "-SSS"
	}
}
