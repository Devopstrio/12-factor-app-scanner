import os
import re
import json

class FactorScanner:
    """Enterprise 12-Factor Compliance Engine by Devopstrio."""
    
    def __init__(self, path):
        self.path = path
        self.score = 100
        self.results = []

    def check_config(self):
        """Factor III: Config - Env var vs hardcoded strings."""
        config_files = ['.env', 'config.json', 'settings.yaml']
        found_hardcoded = False
        
        for root, _, files in os.walk(self.path):
            for file in files:
                if file.endswith(('.py', '.js', '.cs')):
                    with open(os.path.join(root, file), 'r', errors='ignore') as f:
                        if 'api_key' in f.read().lower():
                            found_hardcoded = True
        
        if found_hardcoded:
            self.score -= 15
            self.results.append({
                "factor": "III. Config",
                "status": "FAIL",
                "issue": "Hardcoded credentials detected in source code.",
                "remediation": "Move all configuration to environment variables."
            })
        else:
            self.results.append({"factor": "III. Config", "status": "PASS"})

    def check_dependencies(self):
        """Factor II: Dependencies - Presence of manifest files."""
        manifests = ['package.json', 'requirements.txt', 'go.mod', 'Gemfile']
        found = any(os.path.exists(os.path.join(self.path, m)) for m in manifests)
        
        if not found:
            self.score -= 20
            self.results.append({
                "factor": "II. Dependencies",
                "status": "FAIL",
                "issue": "No dependency manifest detected.",
                "remediation": "Declare all dependencies explicitly in a manifest file."
            })
        else:
            self.results.append({"factor": "II. Dependencies", "status": "PASS"})

    def check_logs(self):
        """Factor XI: Logs - Detection of file-based logging."""
        for root, _, files in os.walk(self.path):
            for file in files:
                if '.log' in file:
                    self.score -= 10
                    self.results.append({
                        "factor": "XI. Logs",
                        "status": "WARNING",
                        "issue": "File-based logging detected.",
                        "remediation": "Treat logs as event streams. Output to STDOUT."
                    })
                    return
        self.results.append({"factor": "XI. Logs", "status": "PASS"})

    def run(self):
        self.check_dependencies()
        self.check_config()
        self.check_logs()
        
        report = {
            "organization": "Devopstrio",
            "compliance_score": max(0, self.score),
            "checks": self.results
        }
        return report

# Implementation for testing
if __name__ == "__main__":
    scanner = FactorScanner(".")
    print(json.dumps(scanner.run(), indent=4))
