import os
import re
import json
import logging
from typing import List, Dict

class FactorCheck:
    """Base class for all 12-Factor checks."""
    def __init__(self, name: str, weight: int):
        self.name = name
        self.weight = weight

    def run(self, path: str) -> Dict:
        raise NotImplementedError

class DependencyCheck(FactorCheck):
    def run(self, path: str) -> Dict:
        manifests = ['package.json', 'requirements.txt', 'go.mod', 'Gemfile', 'pom.xml']
        found = any(os.path.exists(os.path.join(path, m)) for m in manifests)
        return {
            "factor": "II. Dependencies",
            "score_minus": 0 if found else self.weight,
            "status": "PASS" if found else "FAIL",
            "reason": "Manifest detected." if found else "No dependency manifest (e.g., package.json) found."
        }

class ConfigCheck(FactorCheck):
    def run(self, path: str) -> Dict:
        # Check for hardcoded secrets or .env files in source
        leaks = False
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(('.py', '.js', '.ts', '.cs', '.go')):
                    with open(os.path.join(root, file), 'r', errors='ignore') as f:
                        content = f.read()
                        if re.search(r'(api_key|secret|password|token)\s*=\s*["\'][a-zA-Z0-9]{5,}', content, re.I):
                            leaks = True
                            break
        return {
            "factor": "III. Config",
            "score_minus": self.weight if leaks else 0,
            "status": "FAIL" if leaks else "PASS",
            "reason": "Potential secret leakage detected in source." if leaks else "Config appears externalized."
        }

class ProcessCheck(FactorCheck):
    def run(self, path: str) -> Dict:
        # Check for local storage usage (Statelessness)
        storage_patterns = [r'open\s*\(.*["\']w["\']', r'fs\.writeFile', r'StreamWriter']
        found_local_io = False
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(('.py', '.js', '.ts', '.cs')):
                    with open(os.path.join(root, file), 'r', errors='ignore') as f:
                        content = f.read()
                        if any(re.search(p, content) for p in storage_patterns):
                            found_local_io = True
                            break
        return {
            "factor": "VI. Processes",
            "score_minus": self.weight if found_local_io else 0,
            "status": "WARNING" if found_local_io else "PASS",
            "reason": "Local file I/O detected. Ensure state is shared via backing services." if found_local_io else "Processes appear stateless."
        }

class ScannerEngine:
    def __init__(self, target_path: str):
        self.target_path = target_path
        self.checks = [
            DependencyCheck("Dependencies", 20),
            ConfigCheck("Config", 25),
            ProcessCheck("Processes", 15)
        ]

    def scan(self) -> Dict:
        total_score = 100
        detailed_results = []
        
        for check in self.checks:
            res = check.run(self.target_path)
            total_score -= res["score_minus"]
            detailed_results.append(res)
            
        return {
            "metadata": {
                "organization": "Devopstrio",
                "engine_version": "2.0.0-enterprise",
                "target": self.target_path
            },
            "compliance_score": max(0, total_score),
            "factors": detailed_results
        }

if __name__ == "__main__":
    import sys
    path = sys.argv[1] if len(sys.argv) > 1 else "."
    engine = ScannerEngine(path)
    print(json.dumps(engine.scan(), indent=4))
