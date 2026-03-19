# ╔══════════════════════════════════════╗
# ║  Custom Tab Bar (tab_bar.py)          ║
# ║  Phantom Theme Flat Style              ║
# ╚══════════════════════════════════════╝
#
# This file is loaded by Kitty when tab_bar_style = custom.
# It requires the Kitty Python API (available at runtime only).

import datetime
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Phantom colors as RGB ints
    GREEN = as_rgb(0x7EC8A0)
    BG = as_rgb(0x0a0a0a)
    SURFACE = as_rgb(0x141414)
    DIM = as_rgb(0x555555)
    BORDER = as_rgb(0x1e1e1e)

    if tab.is_active:
        bg_color = GREEN
        fg_color = BG
        indicator = " \u25b8"
    else:
        bg_color = SURFACE
        fg_color = DIM
        indicator = ""

    # Separator between tabs
    if index > 0:
        screen.cursor.bg = BG
        screen.cursor.fg = BORDER
        screen.draw("\u2502")

    # Tab content
    screen.cursor.bg = bg_color
    screen.cursor.fg = fg_color

    title = tab.title if len(tab.title) <= 15 else tab.title[:14] + "\u2026"
    tab_text = f" {index + 1}:{title}{indicator} "
    screen.draw(tab_text)

    # Right-align clock on last tab
    if is_last:
        remaining = screen.columns - screen.cursor.x - 8
        if remaining > 0:
            screen.cursor.bg = BG
            screen.cursor.fg = BG
            screen.draw(" " * remaining)

        now = datetime.datetime.now().strftime("%H:%M")
        screen.cursor.bg = BG
        screen.cursor.fg = DIM
        screen.draw(f" {now} ")

    return screen.cursor.x
