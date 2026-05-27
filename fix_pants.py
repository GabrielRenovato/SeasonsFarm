import re

def main():
    tscn_path = "scenes/player/Player.tscn"
    with open(tscn_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Let's locate the definitions of Body, har, Clothe, and Lags
    # Body definition:
    # [node name="Body" type="Sprite2D" parent="." unique_id=563877287]
    # texture_filter = 1
    # position = Vector2(0, -16)
    # texture = ExtResource("2_ov1oi")
    # hframes = 8
    # vframes = 4
    # script = ExtResource("safe_sprite_script")

    # Let's extract the definitions of har, Clothe, and Lags from the file and remove them from their current places.
    # Node patterns:
    # [node name="har" ... ] ... up to the next [node or end of file
    
    nodes_to_reparent = ["har", "Clothe", "Lags"]
    extracted_nodes = {}
    
    for name in nodes_to_reparent:
        pattern = r'(\[node name="' + name + r'" type="Sprite2D" parent="\." unique_id=\d+\].*?)(?=\n\[node|\Z)'
        match = re.search(pattern, content, re.DOTALL)
        if match:
            node_def = match.group(1)
            # Replace parent="." with parent="Body" and position with Vector2(0, 0)
            node_def = re.sub(r'parent="\."', 'parent="Body"', node_def)
            node_def = re.sub(r'position = Vector2\([^\)]+\)', 'position = Vector2(0, 0)', node_def)
            extracted_nodes[name] = node_def
            # Remove from original content
            content = content.replace(match.group(0), "")
            print(f"Extracted and updated {name}")
        else:
            print(f"Could not find node {name}")

    # Now, find the end of the Body node definition to insert Lags, Clothe, and har right after it
    # This guarantees the scene tree order: Body -> Lags -> Clothe -> har
    body_pattern = r'(\[node name="Body" type="Sprite2D" parent="\." unique_id=\d+\].*?)(?=\n\[node)'
    body_match = re.search(body_pattern, content, re.DOTALL)
    if body_match:
        body_def = body_match.group(1)
        # We will insert Lags first, then Clothe, then har
        insert_content = body_def + "\n\n" + extracted_nodes["Lags"] + "\n\n" + extracted_nodes["Clothe"] + "\n\n" + extracted_nodes["har"]
        content = content.replace(body_def, insert_content)
        print("Inserted reparented nodes under Body in correct order (Lags, Clothe, har)")
    else:
        print("Could not find Body node to insert under!")

    # Update AnimationPlayer tracks paths:
    # e.g., NodePath("har:frame") -> NodePath("Body/har:frame")
    content = content.replace('NodePath("har:', 'NodePath("Body/har:')
    content = content.replace('NodePath("Clothe:', 'NodePath("Body/Clothe:')
    content = content.replace('NodePath("Lags:', 'NodePath("Body/Lags:')
    print("Updated NodePaths in AnimationPlayer")

    # Let's disable any position tracks for Body/har, Body/Clothe, and Body/Lags
    # Because they are children of Body, they automatically inherit the parent's position.
    # An animation track for position looks like:
    # tracks/X/type = "value"
    # tracks/X/imported = false
    # tracks/X/enabled = true
    # tracks/X/path = NodePath("Body/Lags:position")
    # We want to change tracks/X/enabled = true to false for these paths.
    
    def disable_position_tracks(match):
        track_header = match.group(1)
        enabled_line = match.group(2)
        track_path = match.group(3)
        # Disable track
        return f"{track_header}tracks/{track_path}/enabled = false"

    # Match: tracks/12/enabled = true followed by tracks/12/path = NodePath("Body/(har|Clothe|Lags):position")
    # We can use a regex to find these and set enabled = false
    track_pattern = r'(tracks/(\d+)/enabled = )true(\r?\n?tracks/\2/path = NodePath\("Body/(?:har|Clothe|Lags):position"\))'
    content, count = re.subn(track_pattern, r'\1false\3', content)
    print(f"Disabled {count} position tracks for reparented sprites")

    with open(tscn_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Saved Player.tscn successfully!")

if __name__ == "__main__":
    main()
