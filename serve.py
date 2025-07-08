#!/usr/bin/env python3
"""
Simple HTTP server for testing the WGSL Analysis Tool web example.
Serves files with proper MIME types and CORS headers for WebAssembly.
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class WGSLHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

        # Add proper MIME types for WebAssembly
        if self.path.endswith('.wasm'):
            self.send_header('Content-Type', 'application/wasm')
        elif self.path.endswith('.js'):
            self.send_header('Content-Type', 'application/javascript')
        elif self.path.endswith('.html'):
            self.send_header('Content-Type', 'text/html')
        elif self.path.endswith('.css'):
            self.send_header('Content-Type', 'text/css')

        super().end_headers()

    def do_OPTIONS(self):
        # Handle CORS preflight requests
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        # Custom log format
        print(f"[{self.log_date_time_string()}] {format % args}")

def main():
    port = 8000

    # Check if port is specified as command line argument
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("Invalid port number. Using default port 8000.")

    # Change to the directory containing this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    print(f"Starting HTTP server on port {port}")
    print(f"Serving files from: {script_dir}")
    print(f"Open your browser to: http://localhost:{port}/examples/web-example.html")
    print("Press Ctrl+C to stop the server")

    try:
        with socketserver.TCPServer(("", port), WGSLHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"Port {port} is already in use. Try a different port:")
            print(f"python3 serve.py {port + 1}")
        else:
            print(f"Error starting server: {e}")

if __name__ == "__main__":
    main()
