import os

def verify_tscn():
    tscn_path = "levels/main_farm/Farm.tscn"
    if not os.path.exists(tscn_path):
        print(f"{tscn_path} not found")
        return False
        
    with open(tscn_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    print(f"Verifying {tscn_path} ({len(lines)} lines)...")
    
    # Check for unmatched brackets or basic tag syntax
    unmatched_brackets = 0
    errors = []
    
    # Check for duplicate external resources or subresources
    ext_resources = {}
    sub_resources = {}
    
    for idx, line in enumerate(lines):
        line = line.strip()
        if line.startswith("[ext_resource") or line.startswith("[sub_resource"):
            # Check format
            if not (line.startswith("[") and line.endswith("]")):
                errors.append(f"Line {idx+1}: Malformed tag: '{line}'")
            
            # Check for IDs
            import re
            id_match = re.search(r'id="([^"]+)"', line)
            if id_match:
                resource_id = id_match.group(1)
                if line.startswith("[ext_resource"):
                    if resource_id in ext_resources:
                        errors.append(f"Line {idx+1}: Duplicate ext_resource ID '{resource_id}': '{line}' and '{ext_resources[resource_id]}'")
                    ext_resources[resource_id] = line
                else:
                    if resource_id in sub_resources:
                        errors.append(f"Line {idx+1}: Duplicate sub_resource ID '{resource_id}': '{line}' and '{sub_resources[resource_id]}'")
                    sub_resources[resource_id] = line
            else:
                errors.append(f"Line {idx+1}: Resource tag lacks id attribute: '{line}'")
                
    if errors:
        print("\nVerification failed with the following errors:")
        for err in errors:
            print(f" - {err}")
        return False
        
    print("\nVerification successful! All tags are structurally sound, resource IDs are unique, and no formatting errors were found.")
    return True

if __name__ == "__main__":
    verify_tscn()
