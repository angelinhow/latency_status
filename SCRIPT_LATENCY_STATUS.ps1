<#
    Monitor de Latencia - Teste Manual (TCP Socket)
    Recurso: Tempo de execucao definivel pelo usuario
    Autor: Angelo Trentin / Gemini
#>

# --- CONFIGURACOES FIXAS ---
$arquivoLog = ".\log_tcp_socket.txt"
$intervaloMs = 500   # Intervalo entre testes

Clear-Host
Write-Host "--- MONITOR DE LATENCIA (TCP Socket) ---" -ForegroundColor Cyan

# --- INPUT DO USUARIO ---
$server = Read-Host "Digite o IP ou Host"
$port = Read-Host "Digite a Porta"

# Pergunta o tempo, mas define padrao 60s se deixar vazio
$inputTempo = Read-Host "Digite o tempo de teste em segundos (Padrao: 60)"
if ([string]::IsNullOrWhiteSpace($inputTempo)) {
    $tempoExecucao = 60
    Write-Host "-> Usando tempo padrao: 60 segundos" -ForegroundColor DarkGray
} else {
    try {
        $tempoExecucao = [int]$inputTempo
    } catch {
        $tempoExecucao = 60
        Write-Host "-> Valor invalido. Usando tempo padrao: 60 segundos" -ForegroundColor DarkGray
    }
}

if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($port)) {
    Write-Host "Dados invalidos (IP ou Porta vazios)." -ForegroundColor Red
}
else {
    $timestampInicio = Get-Date
    $tempoFim = $timestampInicio.AddSeconds($tempoExecucao)
    
    $latencias = @()
    $pacotesEnviados = 0
    $pacotesPerdidos = 0
    
    # --- CABECALHO NO ARQUIVO ---
    $headerArquivo = "`n-------------------------------------------------`n" +
                     "INICIO DO TESTE: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`n" +
                     "ALVO: $server : $port`n" +
                     "DURACAO PROGRAMADA: $tempoExecucao segundos`n" +
                     "-------------------------------------------------"
    $headerArquivo | Out-File -FilePath $arquivoLog -Append -Encoding ASCII

    Write-Host "`nIniciando monitoramento por $tempoExecucao segundos..." -ForegroundColor Cyan
    
    # --- LOOP DE TESTE ---
    while ((Get-Date) -lt $tempoFim) {
        $pacotesEnviados++
        $horaAtual = Get-Date -Format "HH:mm:ss"
        $start = Get-Date
        $msgLog = "" 
        $corLinha = "Green"

        try {
            # Conexao TCP Socket
            $client = New-Object System.Net.Sockets.TcpClient
            $connect = $client.BeginConnect($server, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne(2000, $false) # Timeout 2s
            
            if(!$wait) { throw "Timeout" }
            
            $client.EndConnect($connect)
            $end = Get-Date
            $client.Close()
            $client.Dispose()
            
            $ms = ($end - $start).TotalMilliseconds
            $latencias += $ms
            $msDisplay = $ms.ToString('000')

            # Define Status e Cor
            if ($ms -gt 300) {
                 $msgLog = "[$horaAtual] Tempo: ${msDisplay}ms | LENTIDAO CRITICA"
                 $corLinha = "Red"
            }
            elseif ($ms -gt 100) {
                 $msgLog = "[$horaAtual] Tempo: ${msDisplay}ms | ATENCAO"
                 $corLinha = "Yellow"
            }
            else {
                 $msgLog = "[$horaAtual] Tempo: ${msDisplay}ms | OK"
                 $corLinha = "Green"
            }

        } catch {
            $pacotesPerdidos++
            if ($client) { $client.Close(); $client.Dispose() }
            $msgLog = "[$horaAtual] FALHA DE CONEXAO (Perda de Pacote)"
            $corLinha = "Magenta"
        }
        
        # Mostra e Grava
        Write-Host $msgLog -ForegroundColor $corLinha
        $msgLog | Out-File -FilePath $arquivoLog -Append -Encoding ASCII
        
        Start-Sleep -Milliseconds $intervaloMs
    }

    # --- CALCULOS FINAIS ---
    $stats = $latencias | Measure-Object -Minimum -Maximum -Average
    
    $porcentagemPerda = 0
    if ($pacotesEnviados -gt 0) {
        $porcentagemPerda = ($pacotesPerdidos / $pacotesEnviados) * 100
    }

    $min = if ($stats.Minimum) { [Math]::Round($stats.Minimum, 0) } else { 0 }
    $max = if ($stats.Maximum) { [Math]::Round($stats.Maximum, 0) } else { 0 }
    $avg = if ($stats.Average) { [Math]::Round($stats.Average, 0) } else { 0 }

    # --- RESUMO FINAL ---
    $relatorio = @"
-------------------------------------------------
RESUMO ESTATISTICO
Duracao Real: $tempoExecucao segundos
Latencia (ms) -> Min: $min | Med: $avg | Max: $max
Perda: $pacotesPerdidos falhas ($porcentagemPerda%)
-------------------------------------------------
"@

    if ($porcentagemPerda -gt 0 -or $avg -gt 150) {
        Write-Host $relatorio -ForegroundColor Red
    } else {
        Write-Host $relatorio -ForegroundColor Green
    }

    $relatorio | Out-File -FilePath $arquivoLog -Append -Encoding ASCII
    
    Write-Host "`nHistorico salvo em $arquivoLog" -ForegroundColor Gray
    Read-Host "Pressione ENTER para sair"
}