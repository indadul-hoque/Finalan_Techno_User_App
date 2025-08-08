import os

def find_files_with_text(root_folder, search_text):
    matching_files = []

    for root, _, files in os.walk(root_folder):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    if search_text in f.read():
                        matching_files.append(file_path)
            except Exception as e:
                pass  # Ignore unreadable files

    return matching_files

# === CONFIGURATION ===
root_directory = "/root/flutter-app/lib"   # ← Change this to your folder
text_to_search = "showToast"

# === EXECUTION ===
results = find_files_with_text(root_directory, text_to_search)

print(f"\nFiles containing '{text_to_search}':\n")
for file in results:
    print(file)

print(f"\nTotal files found: {len(results)}")
