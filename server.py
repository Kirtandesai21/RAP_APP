#!/usr/bin/env python3
"""
Local Dev Server for SAP RAP & Fiori Elements UI5 Application
"""
import http.server
import socketserver
import os
import json

DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class RAPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Redirect root to preview.html
        if self.path in ('/', '/index.html'):
            self.send_response(302)
            self.send_header('Location', '/webapp/preview.html')
            self.end_headers()
            return

        # Remap /localService to /webapp/localService if needed
        if self.path.startswith('/localService/'):
            remapped = os.path.join(DIRECTORY, 'webapp', self.path.lstrip('/'))
            if os.path.exists(remapped):
                self.send_response(200)
                if remapped.endswith('.json'):
                    self.send_header('Content-Type', 'application/json')
                elif remapped.endswith('.xml'):
                    self.send_header('Content-Type', 'application/xml')
                self.end_headers()
                with open(remapped, 'rb') as f:
                    self.wfile.write(f.read())
                return

        return super().do_GET()

def run():
    socketserver.TCPServer.allow_reuse_address = True
    ports_to_try = [8080, 8085, 8088, 3000, 5000]
    
    for port in ports_to_try:
        try:
            httpd = socketserver.TCPServer(("", port), RAPRequestHandler)
            print(f"================================================================")
            print(f" SAP ABAP RAP & Fiori Elements Application Server")
            print(f" Server running at: http://localhost:{port}")
            print(f" Direct Preview:   http://localhost:{port}/webapp/preview.html")
            print(f"================================================================")
            httpd.serve_forever()
            return
        except OSError as e:
            if "Address already in use" in str(e):
                continue
            else:
                raise e

    print("Could not bind to any tested port. You can open webapp/preview.html directly in any browser.")

if __name__ == '__main__':
    run()
