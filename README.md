# chatbot
Yet another chat bot installer

## System Architecture

This ChatBot runs ollama on bare metal in the host, and `open-webui` as a docker
container.  The rationale is that the downloaded models (which can be quite
large) can then be leverage to both the host running ollama from the command
line, as well as clients using `open-webui`.

This approach requires that ollama
bind to 0.0.0.0:11434 instead of its typical 127.0.0.1:11434.  This is achieved
by setting the `OLLAMA_HOST=0.0.0.0` environment variable, typically in
/etc/systemd/system/ollama.service:

```
Environment="OLLAMA_HOST=0.0.0.0"
```

And, reloading systemd and restarting the ollama service.

## Models

### Deepseek

https://ollama.com/library/deepseek-r1

## Windows WSL

If you are running Windows on your bare metal host (probable if it's a gaming
rig), then you are going to need to both manage your Windows Firewall as well as
your proxies between Windows and WSL.

### Windows Defender Firewall

This is a GUI application that can be used to add rules to the "Inbound Rules"
table.  You will need to allow ports 22 (SSH) and 3000 (open-webui).

### Proxies

```
PS C:\WINDOWS\system32> netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=0.0.0.0

PS C:\WINDOWS\system32> netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=172.26.225.175

PS C:\WINDOWS\system32> netsh interface portproxy show all

Listen on ipv4:             Connect to ipv4:

Address         Port        Address         Port
--------------- ----------  --------------- ----------
0.0.0.0         3000        172.26.225.175  3000
0.0.0.0         22          172.26.225.175  22

PS C:\WINDOWS\system32>
```
