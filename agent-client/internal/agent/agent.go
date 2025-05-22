package agent

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
	"time"
)

type Command struct {
	ID     int    `json:"id"`
	VulnID string `json:"vulnid"`
	Host   string `json:"hostname"`
}

type Result struct {
	HostName string `json:"host_name"`
	ItemID   string `json:"item_id"`
	Result   string `json:"result"`
	Detail   string `json:"detail"`
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

		resultText, detail := performCheck(cmd.VulnID)
		sendResult(Result{
			HostName: cmd.Host,
			ItemID:   cmd.VulnID,
			Result:   resultText,
			Detail:   detail,
		})

		time.Sleep(2 * time.Second)
	}
}

func performCheck(vulnid string) (string, string) {
	switch vulnid {
	case "SRV-001":
		return checkSNMP()
	default:
		return "❓ 알 수 없는 항목", ""
	}
}

func checkSNMP() (string, string) {
	out, err := exec.Command("sh", "-c", "ps -ef | grep -i snmpd | grep -v grep").Output()
	if err != nil {
		return "❌ SNMP 점검 실패", err.Error()
	}
	if len(out) > 0 {
		return "✅ SNMPv3 설정 양호", string(out)
	}
	return "❌ SNMP 서비스 미실행", string(out)
}

func sendResult(res Result) {
	data, _ := json.Marshal(res)
	resp, err := http.Post(serverURL+"/api/result", "application/json", bytes.NewBuffer(data))
	if err != nil {
		fmt.Println("❌ 결과 전송 실패:", err)
	} else {
		fmt.Println("📤 결과 전송 완료:", res)
		resp.Body.Close()
	}
}
