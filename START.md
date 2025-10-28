# 🚀 Getting Started - Your First PDF

Welcome! Let's get you from zero to your first beautiful journal PDF in under an hour.

## 📋 What You'll Need

- ☐ macOS computer
- ☐ 30-45 minutes for installation
- ☐ 4-5 GB free disk space (for MacTeX)
- ☐ Internet connection (for downloads)

## 🎯 The Big Picture

Here's what we're building:

**Your Goal**: Convert markdown journal entries → Beautiful print-ready PDF

**The Journey**:
1. Install software (30 min)
2. Set up the workflow (5 min)
3. Build your first PDF (2 min)
4. Customize to your taste (ongoing)

## 📚 Your Reading List

These files are your guides:

1. **START HERE** → This file (START.md)
2. **Installation** → `INSTALL.md` - Follow step-by-step
3. **Daily Use** → `README.md` - Main documentation
4. **Quick Reference** → `QUICKREF.md` - Commands cheat sheet
5. **Deep Dive** → `PROJECT.md` - How everything works

## ⚡ Quick Start (If You're Impatient)

Already have everything installed? Jump right in:

```bash
cd journal-workflow
./build-clean.sh source/2025-10-21.md
```

The PDF will open automatically! 🎉

---

## 🛠️ Installation (First Time Only)

### Step 1: Check What You Have

Open Terminal and check:

```bash
# Do you have Homebrew?
brew --version

# Do you have Pandoc?
pandoc --version

# Do you have LaTeX?
pdflatex --version
```

If any are missing, continue to Step 2.

### Step 2: Install Homebrew (if needed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 3: Install MacTeX

```bash
brew install --cask mactex
```

⏱️ This is the big one - about 4.5 GB. Go get coffee! ☕

### Step 4: Install Pandoc

```bash
brew install pandoc
```

⏱️ Quick - just a few minutes.

### Step 5: Set Up VS Code

1. Open VS Code (drag to Applications if you haven't)
2. Press `Cmd+Shift+P`
3. Type: `shell command`
4. Select: "Shell Command: Install 'code' command in PATH"

### Step 6: Install VS Code Extensions

Press `Cmd+Shift+X` in VS Code and install:
- **LaTeX Workshop** (essential!)
- **Markdown All in One** (helpful)

### Step 7: Place Your Workflow

Put the `journal-workflow` folder somewhere handy:

```bash
# Recommended location:
mv journal-workflow ~/Documents/
cd ~/Documents/journal-workflow
```

Or anywhere else you prefer!

---

## ✅ Verify Installation

```bash
# All of these should show version numbers:
brew --version
pandoc --version
pdflatex --version
xelatex --version
code --version
```

If anything fails, see `INSTALL.md` troubleshooting section.

---

## 🎉 Your First Build

Time to see the magic!

### Option 1: Command Line (Easiest)

```bash
cd ~/Documents/journal-workflow
./build-clean.sh source/2025-10-21.md
```

**What happens:**
1. Script fixes any character encoding issues
2. Pandoc converts markdown → LaTeX
3. Filters add color to tags and names
4. XeLaTeX generates the PDF
5. PDF opens automatically!

### Option 2: VS Code (Visual)

1. Open the workflow folder in VS Code:
   ```bash
   code ~/Documents/journal-workflow
   ```

2. Open `source/2025-10-21.md`

3. In Terminal (inside VS Code): `Ctrl+` `
   ```bash
   ./build-clean.sh source/2025-10-21.md
   ```

---

## 🔍 What to Look For

Open your PDF and check:

### ✅ Success Indicators

- **Tags are blue**: Look for #PersonalJournal, #parenting, etc.
- **Names are red**: Andrea, Rose, Luca, Mila should be highlighted
- **Professional layout**: Clean margins, headers, page numbers
- **Indexes at back**: Two indexes - one for names, one for tags
- **Readable font**: Palatino is elegant and readable

### 📏 Check the Size

- Physical dimensions: Should feel like a normal book
- On screen: Zoom to 100% - is text readable?
- Print test: Print one page to verify size

---

## 🎨 Quick Customizations

Want to make it yours right away?

### Change Tag Color

Edit `templates/journal-template.tex`:

```latex
\definecolor{tagcolor}{RGB}{100,149,237}  % Change these numbers!
```

Try:
- `{220,20,60}` - Crimson red
- `{50,205,50}` - Lime green
- `{255,140,0}` - Dark orange

### Change Name Color

```latex
\definecolor{namecolor}{RGB}{220,20,60}  % Change these numbers!
```

### Add Your Friends/Family

Edit `filters/name-filter.lua`:

```lua
local common_names = {
  Andrea = true,
  Rose = true,
  Luca = true,
  Mila = true,
  -- Add your people here:
  YourName = true,
  BestFriend = true,
}
```

Save, rebuild, and see the changes!

---

## 📖 Next Steps

Now that you have a working PDF:

### Step 1: Review the Output (5 min)
- Look at every page
- Check if formatting looks good
- Note what you'd like to change

### Step 2: Read the Docs (15 min)
- Skim through `README.md`
- Bookmark `QUICKREF.md`
- Understand the basics from `PROJECT.md`

### Step 3: Add Your Content (10 min)
- Copy one of your journal entries to `source/`
- Build it: `./build-clean.sh source/your-file.md`
- See how your content looks

### Step 4: Customize (Ongoing)
- Experiment with colors
- Try different fonts
- Adjust layout
- Add names to the filter

### Step 5: Plan Your Book (Thinking time)
- How do you want to organize entries?
- By day? By month? By year?
- What additional features do you need?

---

## 🆘 Common First-Time Issues

### "command not found: pandoc"
**Fix**: Make sure installation completed
```bash
brew install pandoc
```

### "command not found: xelatex"
**Fix**: MacTeX needs to be in PATH
```bash
eval "$(/usr/libexec/path_helper)"
# Then restart Terminal
```

### "Permission denied: ./build.sh"
**Fix**: Make scripts executable
```bash
chmod +x build.sh build-clean.sh preprocess.sh
```

### PDF looks weird
**Fix**: Character encoding issues
```bash
./preprocess.sh source/your-file.md
# Then rebuild
```

### Tags aren't colored
**Check**:
- Are tags formatted as `#tag` (no space)?
- Did the build complete without errors?
- Look at the `.log` file in output/

### Names aren't colored
**Check**:
- Is the name in the `common_names` list?
- Add it to `filters/name-filter.lua`
- Rebuild after adding

---

## 💡 Pro Tips for Beginners

1. **Always test with small files first** - Don't try your entire journal on the first run!

2. **Keep a backup** - The preprocess script creates .bak files automatically

3. **Make one change at a time** - Easier to debug if something breaks

4. **Check the logs** - When builds fail, the .log file tells you why

5. **Start simple** - Get the basic workflow working before heavy customization

6. **Use version control** - Consider `git init` to track your template changes

7. **Print a test page** - Before printing a whole book, print one page at actual size

---

## 🎯 Your First Hour Checklist

- [ ] Install all required software
- [ ] Verify installations work
- [ ] Build the sample PDF successfully
- [ ] Open and review the PDF
- [ ] Try one color customization
- [ ] Add one person's name to the filter
- [ ] Rebuild and see the changes
- [ ] Read through README.md
- [ ] Add one of your own journal entries
- [ ] Build your own content successfully

---

## 🎊 You're Ready!

If you've made it here and have a working PDF, **congratulations!** 🎉

You now have:
- ✅ A complete, working workflow
- ✅ Your first journal PDF
- ✅ The knowledge to customize it
- ✅ All the tools you need

**What's Next?**
- Read `README.md` for detailed usage
- Explore `PROJECT.md` to understand the system
- Use `QUICKREF.md` as your command reference
- Start building your actual journal!

---

## 📞 Need Help?

**First:**
1. Check the error message carefully
2. Look in `INSTALL.md` troubleshooting
3. Review `QUICKREF.md` for commands
4. Check the `.log` files in output/

**Remember:**
- Installation is the hardest part - once it's working, it's smooth sailing!
- Most issues are simple fixes (permissions, PATH, missing packages)
- The sample file is your testing ground - use it to experiment!

---

**Ready to create beautiful journals?** 📚✨

Start with: `./build-clean.sh source/2025-10-21.md`
