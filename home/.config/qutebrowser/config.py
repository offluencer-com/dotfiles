from pathlib import Path

config.load_autoconfig(False)

c.content.blocking.method = 'both'
c.content.user_stylesheets = ['~/.cache/wal/youtube.css']
c.colors.webpage.preferred_color_scheme = 'dark'

def wal_colors():
    path = Path.home() / ".cache/wal/colors"
    values = path.read_text().splitlines()
    return {f"color{i}": v for i, v in enumerate(values)}

w = wal_colors()
dark  = w["color0"]
light = w["color15"]

# Custom homepageHTML
#
#c.url.start_pages = ["file:///home/YOURUSER/.config/qutebrowser/start.html"]

# Start page and new tabs
import subprocess

bm_script = Path.home() / ".config/qutebrowser/scripts/bookmarks.py"
subprocess.run(["python3", str(bm_script)])

start = "file://" + str(Path.home() / ".cache/qute-bookmarks.html")
c.url.start_pages = [start]
c.url.default_page = start
c.colors.webpage.bg = dark

# Statusbar
c.colors.statusbar.normal.bg = dark
c.colors.statusbar.normal.fg = light
c.colors.statusbar.command.bg = dark
c.colors.statusbar.command.fg = light
c.colors.statusbar.url.fg = light

# Tabs: inactive = dim gray text
c.colors.tabs.bar.bg = dark
c.colors.tabs.even.bg = dark
c.colors.tabs.odd.bg = dark
c.colors.tabs.even.fg = w["color8"]
c.colors.tabs.odd.fg = w["color8"]

# Tabs: active = transparent, bright text
c.colors.tabs.selected.even.bg = dark
c.colors.tabs.selected.odd.bg = dark
c.colors.tabs.selected.even.fg = light
c.colors.tabs.selected.odd.fg = light

c.fonts.tabs.selected = "bold default_size default_family"
c.fonts.tabs.unselected = "default_size default_family"
c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "11pt"

# fonts used when websites don't specify their own
c.fonts.web.family.standard = "JetBrainsMono Nerd Font"
c.fonts.web.family.sans_serif = "JetBrainsMono Nerd Font"
c.fonts.web.family.fixed = "JetBrainsMono Nerd Font"


# Completion
c.colors.completion.fg = light
c.colors.completion.even.bg = dark
c.colors.completion.odd.bg = dark
c.colors.completion.category.bg = dark
c.colors.completion.category.fg = light
c.colors.completion.item.selected.bg = light
c.colors.completion.item.selected.fg = dark

# Prompts and messages
c.colors.prompts.bg = dark
c.colors.prompts.fg = light
c.colors.messages.info.bg = dark
c.colors.messages.info.fg = light

css_path = Path.home() / ".cache/wal/qute.css"
css_path.write_text(f"""
body {{ background: {dark} !important; color: {light} !important; }}
table, thead, tbody, tr, td, th {{ background: transparent !important; color: {light} !important; }}
a, a:visited {{ color: {light} !important; }}
""")
c.content.user_stylesheets = [str(css_path)]


#BINDS
config.bind("B", f"bookmark-add ;; spawn python3 {bm_script}")
config.bind("<Alt+b>", f"spawn --userscript {Path.home()}/.config/qutebrowser/scripts/bookmarks.py")
