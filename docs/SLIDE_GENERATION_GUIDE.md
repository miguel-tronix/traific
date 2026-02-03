# Generating Slides from presentation.md

The presentation.md file has been enhanced with Marp frontmatter and is ready to be converted to slides.

## Option 1: Marp CLI (Recommended - Fast & Clean)

### Installation
```bash
npm install -g @marp-team/marp-cli
```

### Generate HTML Slides
```bash
cd /home/migtronix/ansible/ai-workloads/traific/docs
marp presentation.md -o presentation.html
```

### Generate PDF Slides
```bash
marp presentation.md --pdf -o presentation.pdf
```

### Generate PowerPoint
```bash
marp presentation.md --pptx -o presentation.pptx
```

### Preview in Browser (Live Reload)
```bash
marp -s presentation.md
# Opens browser at http://localhost:8080
```

## Option 2: Reveal.js (Interactive Web Slides)

### Installation
```bash
npm install -g reveal-md
```

### Generate Slides
```bash
cd /home/migtronix/ansible/ai-workloads/traific/docs
reveal-md presentation.md --theme night
```

### Export to PDF
```bash
reveal-md presentation.md --print presentation-reveal.pdf
```

## Option 3: Pandoc to PowerPoint

### Installation
```bash
sudo apt-get install pandoc
```

### Generate PowerPoint
```bash
pandoc presentation.md -o presentation.pptx
```

## Customization

### Change Marp Theme
Edit the frontmatter in presentation.md:
```yaml
theme: gaia  # Options: default, gaia, uncover
```

### Custom Footer
Already configured in frontmatter:
```yaml
footer: 'Traific Platform | Confidential'
```

## Next Steps

1. Install Marp CLI (recommended): `npm install -g @marp-team/marp-cli`
2. Generate slides: `marp presentation.md -o presentation.html`
3. Review and present!
