# 🚀 Getting Started - Your First PDF

Welcome! Let's get you from zero to your first beautiful journal PDF in under an hour.

## 📋 What You'll Need

- ☐ macOS computer
- ☐ 30-45 minutes for installation
- ☐ 4-5 GB free disk space (for MacTeX)
- ☐ Internet connection (for downloads)

## 🎯 The Big Picture

Here's what we're building:

**Your Goal**: Convert Capacities journal exports OR markdown files → Beautiful print-ready PDF

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

Already have everything installed? Choose your path:

### Option A: Build from Existing Markdown
```bash
cd journal-workflow
./build.sh source/journal.md
```

### Option B: Process Capacities Export
```bash
cd journal-workflow
# Place your Capacities export .zip in source/
./process-capacities-export.sh
./preprocess-capacities.sh "My Journal" "Your Name" source/journal.md
./build.sh source/journal.md
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

### Step 5: Set Up VS Code (Optional)

1. Open VS Code (drag to Applications if you haven't)
2. Press `Cmd+Shift+P`
3. Type: `shell command`
4. Select: "Shell Command: Install 'code' command in PATH"

### Step 6: Install VS Code Extensions (Optional)

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
```

If anything fails, see `INSTALL.md` troubleshooting section.

### Test Your Installation

Once everything is installed, test the workflow with the included test file:

```bash
cd ~/Documents/journal-workflow
./build.sh source/test.md
```

**What to look for in the test PDF:**
- **Tags in blue**: #testing, #workflow, #setup, #success, #installation, #verification
- **Object references indexed**: Check the 6 indexes at the back
  - Books: "Thinking Fast and Slow"
  - Definitions: "Cognitive Bias"
  - Organizations: "Stanford University"
  - People: "Sarah Johnson"
  - Projects: "Journal Workflow"
  - Tags: All hashtags from the document
- **Professional layout**: Margins, headers, page numbers
- **PDF opens automatically** after build

If the test PDF looks good, your installation is working correctly!

---

## 🎉 Your First Build

Time to see the magic!

### Option 1: Build from Markdown (Simplest)

If you already have a journal.md file:

```bash
cd ~/Documents/journal-workflow
./build.sh source/journal.md
```

**What happens:**
1. Output directory is cleaned (prevents stale files)
2. Pandoc converts markdown → LaTeX using 5 filters
3. First XeLaTeX pass creates index files
4. makeindex processes all 6 indexes
5. Final XeLaTeX pass includes formatted indexes
6. PDF opens automatically!

### Option 2: Process Capacities Export (Full Workflow)

If you're importing from Capacities:

1. **Export from Capacities** and save the .zip file to `source/`

2. **Process the export:**
   ```bash
   cd ~/Documents/journal-workflow
   ./process-capacities-export.sh
   ```

3. **Preprocess for LaTeX:**
   ```bash
   ./preprocess-capacities.sh "My 2023 Journal" "Your Name" source/journal.md
   ```

4. **Build the PDF:**
   ```bash
   ./build.sh source/journal.md
   ```

5. **Review your PDF:**
   ```bash
   open output/journal.pdf
   ```

### Option 3: VS Code (Visual)

1. Open the workflow folder in VS Code:
   ```bash
   code ~/Documents/journal-workflow
   ```

2. Open `source/journal.md` (or your file)

3. In Terminal (inside VS Code): `Ctrl+` ` then:
   ```bash
   ./build.sh source/journal.md
   ```

---

## 🔍 What to Look For

Open your PDF and check:

### ✅ Success Indicators

- **Tags are blue**: Look for #PersonalJournal, #parenting, etc.
- **Names are red**: People's names should be highlighted
- **Professional layout**: Clean margins, headers, page numbers
- **Six indexes at back**: Books, Definitions, Organizations, People, Projects, Tags
- **Readable font**: Corundum Text Book (or substitute if you changed it)

### 📏 Check the Size

- Physical dimensions: 6" × 9" (standard trade paperback)
- On screen: Zoom to 100% - is text readable?
- Print test: Print one page to verify size

---

## 🎨 Quick Customizations

Want to make it yours right away?

### Change Tag Color

Edit `templates/journal-template.tex` (line ~65):

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

### Change Font

Edit `templates/journal-template.tex` (line ~14):

```latex
\setmainfont{Corundum Text Book}[
  BoldFont={Corundum Text Bold}
]
```

**Don't have Corundum Text Book?** Try these alternatives:

```latex
\setmainfont{Palatino}      % Classic serif
\setmainfont{Garamond}      % Elegant serif
\setmainfont{Baskerville}   % Traditional serif
\setmainfont{Georgia}       % Screen-friendly
\setmainfont{Hoefler Text}  % macOS default
```

**Check available fonts:**
```bash
fc-list : family | sort | uniq
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
- Verify all 6 indexes appear
- Note what you'd like to change

### Step 2: Read the Docs (15 min)
- Skim through `README.md` for complete features
- Bookmark `QUICKREF.md` for command reference
- Understand the architecture from `PROJECT.md`

### Step 3: Add Your Content (10 min)
- If using Capacities, export and process your data
- If using markdown, copy your files to `source/`
- Build: `./build.sh source/your-file.md`
- See how your content looks

### Step 4: Customize (Ongoing)
- Experiment with colors
- Try different fonts
- Adjust layout
- Add names to the filter
- Customize index categories

### Step 5: Plan Your Book (Thinking time)
- How do you want to organize entries?
- By day? By month? By year?
- What additional features do you need?
- Which indexes are most useful to you?

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
chmod +x *.sh
```

### "Font not found" error
**Fix**: Change the font in the template
```bash
# Check available fonts
fc-list : family | sort | uniq

# Then edit templates/journal-template.tex
# Change \setmainfont{Corundum Text Book} to an available font
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
- Look at `logs/build.sh-build.log`

### Names aren't colored
**Check**:
- Is the name in the `common_names` list?
- Add it to `filters/name-filter.lua`
- Rebuild after adding

### Indexes are missing
**Check**:
- Look at `logs/build.sh-index.log` for errors
- Verify `.idx` files exist in `output/`
- Verify `.ind` files exist in `output/`
- Check that build.sh processes all 6 indexes

### Build works but output looks wrong
**Fix**: Clean build (output directory gets stale)
```bash
# Output is cleaned automatically now, but you can check:
ls output/
# Should see fresh .idx and .ind files after each build
```

---

## 💡 Pro Tips for Beginners

1. **Always test with small files first** - Don't try your entire journal on the first run!

2. **Keep backups** - Preprocessing creates .bak files automatically

3. **Make one change at a time** - Easier to debug if something breaks

4. **Check the logs** - When builds fail, logs/ directory tells you why

5. **Start simple** - Get the basic workflow working before heavy customization

6. **Use version control** - Consider git for tracking template changes

7. **Print a test page** - Before printing a whole book, print one page at actual size

8. **Clean builds are safe** - build.sh cleans output/ by default (use --keep-output sparingly)

9. **Verify all indexes** - Check that all 6 indexes appear in your PDF

10. **Font troubleshooting** - If you see font errors, use fc-list to find alternatives

---

## 🎯 Your First Hour Checklist

- [ ] Install all required software (Homebrew, Pandoc, MacTeX)
- [ ] Verify installations work
- [ ] Build a sample PDF successfully
- [ ] Open and review the PDF
- [ ] Verify all 6 indexes appear
- [ ] Try one color customization
- [ ] Add one person's name to the filter
- [ ] Rebuild and see the changes
- [ ] Read through README.md
- [ ] Process your own content (Capacities export or markdown)
- [ ] Build your own journal successfully

---

## 🎊 You're Ready!

If you've made it here and have a working PDF, **congratulations!** 🎉

You now have:
- ✅ A complete, working workflow
- ✅ Your first journal PDF
- ✅ Six comprehensive indexes
- ✅ Five powerful filters processing your content
- ✅ The knowledge to customize it
- ✅ All the tools you need

**What's Next?**
- Read `README.md` for detailed features and customization
- Explore `PROJECT.md` to understand the system architecture
- Use `QUICKREF.md` as your daily command reference
- Process your full Capacities export or markdown journal
- Customize fonts, colors, and layout to your taste
- Print your beautiful journal!

---

## 📞 Need Help?

**First:**
1. Check the error message carefully
2. Look in `INSTALL.md` troubleshooting section
3. Review `QUICKREF.md` for command syntax
4. Check the log files in `logs/` directory
5. Verify all 6 .ind files exist in `output/`

**Remember:**
- Installation is the hardest part - once it's working, it's smooth sailing!
- Most issues are simple fixes (permissions, PATH, missing packages, fonts)
- The sample files are your testing ground - use them to experiment!
- Clean builds prevent many issues - output/ is cleaned automatically

---

**Ready to create beautiful journals?** 📚✨

Quick start: `./build.sh source/journal.md`

Capacities workflow: `./process-capacities-export.sh` → `./preprocess-capacities.sh` → `./build.sh source/journal.md`
