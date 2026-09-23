# Phone-portrait frame capture of the real web export in headless Chrome (CDP).
# usage: python3 qa/shot.py <url> <out.png> [wait_s] [w] [h] [dpr]
import json, subprocess, sys, time, urllib.request, websocket, base64, os, signal
url, out = sys.argv[1], sys.argv[2]
wait = float(sys.argv[3]) if len(sys.argv) > 3 else 25
w, h, dpr = (int(sys.argv[4]) if len(sys.argv) > 4 else 390), (int(sys.argv[5]) if len(sys.argv) > 5 else 844), (float(sys.argv[6]) if len(sys.argv) > 6 else 2)
port = 9333
p = subprocess.Popen(["google-chrome", "--headless=new", "--no-sandbox", f"--remote-debugging-port={port}", "--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist", "--disable-dev-shm-usage", "--remote-allow-origins=*", "about:blank"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(50):
        try:
            tabs = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json")); break
        except Exception: time.sleep(0.2)
    ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], timeout=120)
    n = [0]
    def cmd(m, **params):
        n[0] += 1; ws.send(json.dumps({"id": n[0], "method": m, "params": params}))
        while True:
            r = json.loads(ws.recv())
            if r.get("id") == n[0]: return r
    cmd("Runtime.enable")
    cmd("Emulation.setDeviceMetricsOverride", width=w, height=h, deviceScaleFactor=dpr, mobile=True)
    cmd("Emulation.setTouchEmulationEnabled", enabled=True, maxTouchPoints=5)
    cmd("Page.navigate", url=url)
    t0 = time.time()
    time.sleep(wait)
    r = cmd("Runtime.evaluate", expression="(document.querySelector('#status') && getComputedStyle(document.querySelector('#status')).display) + ' ' + (document.querySelector('canvas') ? document.querySelector('canvas').width + 'x' + document.querySelector('canvas').height : 'nocanvas')")
    print("status/canvas:", r["result"]["result"].get("value"))
    shot = cmd("Page.captureScreenshot", format="png")
    open(out, "wb").write(base64.b64decode(shot["result"]["data"]))
    print("saved", out)
finally:
    p.send_signal(signal.SIGTERM); p.wait()
