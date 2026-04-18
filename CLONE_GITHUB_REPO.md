# Clone GitHub Repository Locally

## Current Situation:
- Local folder: `E:\const_proj\essential\construction_flutter`
- GitHub repo: `Essentials_construction_project`
- They are connected but names are different

## Option 1: Clone Fresh Copy (Recommended)

### Steps:

1. **Open new terminal/command prompt**

2. **Navigate to where you want the repo:**
   ```bash
   cd E:\
   ```

3. **Clone the repository:**
   ```bash
   git clone https://github.com/siva-dataworker/Essentials_construction_project.git
   ```

4. **This creates:**
   ```
   E:\Essentials_construction_project\
   ```

5. **Open in VS Code:**
   ```bash
   cd Essentials_construction_project
   code .
   ```

Now you have a clean copy with matching names!

## Option 2: Rename Current Folder

If you want to keep your current work:

1. **Commit all changes first:**
   ```bash
   cd E:\const_proj\essential\construction_flutter
   git add -A
   git commit -m "Save current work"
   git push
   ```

2. **Close VS Code**

3. **Rename the folder:**
   - Rename `E:\const_proj` to `E:\Essentials_construction_project`

4. **Open in VS Code:**
   ```bash
   cd E:\Essentials_construction_project\essential\construction_flutter
   code .
   ```

## Option 3: Keep Both

Keep current folder for work, clone for reference:

```bash
cd E:\
git clone https://github.com/siva-dataworker/Essentials_construction_project.git GitHub_Repo
```

This creates `E:\GitHub_Repo\` as a separate copy.

## Which Option Should You Choose?

- **Option 1 (Clone Fresh):** If you want clean start with matching names
- **Option 2 (Rename):** If you want to keep current setup
- **Option 3 (Keep Both):** If you want both versions

Your current folder is already connected and working fine. The name difference doesn't affect functionality!
