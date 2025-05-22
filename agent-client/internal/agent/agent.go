package agent

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
	"regexp"
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
	default:
		return "미점검", "❓ 알 수 없는 항목", "N/A"
	}
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

	if len(running) == 0 {
		return "양호", "SMTP 관련 프로세스가 실행되고 있지 않음 → 양호", "미사용"
	}

	detail := fmt.Sprintf("다음 SMTP 관련 프로세스가 확인되었습니다: %s", strings.Join(running, ","))
	serviceStatus := strings.Join(running, ",")

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
