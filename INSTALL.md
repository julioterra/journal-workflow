# 🍎 macOS Installation Checklist

Follow these steps in order to set up your journal workflow.

## ✅ Step 1: Install Homebrew (if needed)

Check if you have Homebrew:
```bash
brew --version
```

If not installed, install it:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## ✅ Step 2: Install MacTeX

**Option A: Using Homebrew (Recommended)**
```bash
brew install --cask mactex
```

**Option B: Download directly**
- Visit: https://www.tug.org/mactex/
- Download and install MacTeX.pkg (~4.5 GB)

⏱️ **Time:** 10-20 minutes (it's a large download)

## ✅ Step 3: Install Pandoc

```bash
brew install pandoc
```

⏱️ **Time:** 2-3 minutes

## ✅ Step 4: Install VS Code

1. Open the VS Code installer you downloaded
2. Drag to Applications folder
3. Launch VS Code

## ✅ Step 5: Install VS Code Command Line Tool

1. Open VS Code
2. Press `Cmd+Shift+P`
3. Type: `shell command`
4. Select: "Shell Command: Install 'code' command in PATH"
5. Restart Terminal

## ✅ Step 6: Install VS Code Extensions

In VS Code, press `Cmd+Shift+X` and install:
- **LaTeX Workshop** (by James Yu) - Essential!
- **Markdown All in One** (by Yu Zhang) - Helpful
- **Code Spell Checker** (by Street Side Software) - Optional

## ✅ Step 7: Set Up Project

```bash
# Create project directory
mkdir -p ~/Documents/journal-workflow
cd ~/Documents/journal-workflow

# Download the workflow files
# (You'll get these from Claude)

# Open in VS Code
code .
```

## ✅ Step 8: Verify Everything Works

```bash
# Check LaTeX
pdflatex --version

# Check Pandoc  
pandoc --version

# Check VS Code command
code --version
```

All should show version numbers!

## ✅ Step 9: First Build Test

```bash
cd ~/Documents/journal-workflow
./build.sh source/2025-10-21.md
```

This should:
1. Process your markdown file
2. Create a PDF in the `output/` folder
3. Automatically open the PDF

## 🎉 Success!

If you see a beautifully formatted PDF with:
- Colored tags in blue
- People's names in red
- Proper page numbers and headers
- An index at the back

**You're ready to go!** 🚀

## 🆘 Troubleshooting

### "command not found: brew"
Install Homebrew (see Step 1)

### "command not found: pandoc"
Run: `brew install pandoc`

### "command not found: xelatex" or "command not found: pdflatex"
- MacTeX installation may not be complete
- Try: `eval "$(/usr/libexec/path_helper)"`
- Restart Terminal
- If still fails, reinstall MacTeX

### VS Code can't find 'code' command
- Reinstall the shell command (Step 5)
- Make sure to restart Terminal after installation

### Build script fails
- Check that all files are in the right directories
- Make sure scripts are executable: `chmod +x build.sh preprocess.sh`
- Look at the error message for specific issues

## 📞 Getting Help

If you're stuck:
1. Check the error message carefully
2. Verify all installations completed successfully
3. Make sure you're in the right directory
4. Try restarting Terminal/VS Code

---

**Total Setup Time:** ~30-45 minutes (mostly waiting for downloads)

**Next:** Read the main README.md for usage instructions!
