## Fixes

Sometimes some fixes are needed for some system errors

### runlevel command not found

```bash
sudo nano /usr/local/bin/runlevel
```

```bash
#!/bin/bash
if systemctl get-default | grep -q graphical; then
  echo "N 5"
else
  echo "N 3"
fi
```


### Fix for kde-open crash when opened through sandboxed apps 

```bash
sudo mv /usr/bin/kde-open /usr/bin/kde-open.real
```

```bash
sudo tee /usr/bin/kde-open <<'EOF'
  #!/bin/bash

  QT_QPA_PLATFORM=wayland /usr/bin/kde-open.real "$@"
EOF
```
```bash
sudo chmod +x /usr/bin/kde-open
``` 

### Deadkeys not being recognized in apps

Run apps with `--ozone-platform=x11`