import json
import os

def read_log():
    log_path = r"C:\Users\ofici\.gemini\antigravity\brain\207b5548-f11c-4911-91dc-2d431e1a0add\.system_generated\logs\transcript.jsonl"
    if not os.path.exists(log_path):
        print("Log not found")
        return
        
    with open(log_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                data = json.loads(line)
                content = data.get("content", "")
                if "qcjwc" in content or "7_q7ato" in content:
                    print(f"--- Step {data.get('step_index')} ({data.get('type')}) ---")
                    print(content[:2000])
                    print("----------------------------------------------------\n")
            except Exception as e:
                pass

if __name__ == "__main__":
    read_log()
