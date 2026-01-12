# 📡 TCP Socket Latency Monitor

## 📋 About
This PowerShell script is a network diagnostic tool designed to monitor **TCP latency** and connectivity to a specific **IP and Port**. 

Unlike standard ICMP Pings, this script uses `System.Net.Sockets.TcpClient` to test the availability of specific services (e.g., checking if an SQL Server on port 1433 or a Web Server on port 80 is reachable and responsive). It provides real-time feedback and generates a detailed log file.

## ✨ Key Features
* **TCP Port Testing:** Verifies connectivity to specific ports, not just the host IP.
* **Customizable Duration:** User-defined test execution time (default: 60 seconds).
* **Visual Feedback:** Color-coded console output for quick analysis:
    * 🟢 **Green:** Excellent (< 100ms)
    * 🟡 **Yellow:** Warning (> 100ms)
    * 🔴 **Red:** Critical Latency (> 300ms)
    * 🟣 **Magenta:** Connection Failed / Packet Loss
* **Automatic Logging:** Saves all events and a final summary to `log_tcp_socket.txt`.
* **Statistical Summary:** Calculates Minimum, Maximum, and Average latency, plus Packet Loss percentage at the end of the execution.

## 🛠️ Prerequisites
* Windows OS
* PowerShell 5.1 or newer

## 🚀 How to Run

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/angelinhow/latency_status.git](https://github.com/angelinhow/latency_status.git)
    ```

2.  **Navigate to the directory:**
    ```bash
    cd latency_status
    ```

3.  **Run the script:**
    ```powershell
    .\SCRIPT_LATENCY_STATUS.ps1
    ```
    *(Note: You may need to allow script execution depending on your policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`)*

4.  **Follow the prompts:**
    * Enter the **Target IP or Hostname**.
    * Enter the **Target Port**.
    * Enter the **Duration** in seconds (Press Enter for default 60s).

## 📊 Output Example

```text
--- MONITOR DE LATENCIA (TCP Socket) ---
Iniciando monitoramento por 60 segundos...
 Tempo: 025ms | OK Tempo: 110ms | ATENCAO Tempo: 022ms | OK
...

-------------------------------------------------
RESUMO ESTATISTICO
Duracao Real: 60 segundos
Latencia (ms) -> Min: 22 | Med: 45 | Max: 110
Perda: 0 falhas (0%)
-------------------------------------------------
