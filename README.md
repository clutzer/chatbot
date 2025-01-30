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
