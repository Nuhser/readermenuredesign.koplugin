# zzz-readermenuredesign.koplugin
A redesign of the various reader menus in KOReader, including the Dictionary Quick Lookup popup and Reader Highlight menu.

<p align="left">
  <img src="https://github.com/user-attachments/assets/2d82282a-96c9-43b7-aaea-fb27a74d2f52" width=45%>
</p>

Includes an option to show 'unknown' buttons in the Reader Highlight menu:
<p align="left">
  <img src="https://github.com/user-attachments/assets/162b8b8c-c6b5-4149-a8d9-b5e9bbeb64dd" width=45%>
  <img src="https://github.com/user-attachments/assets/9dbfec8c-88e0-4b91-9f13-7eb50f1f881c" width=45%>
</p>


This plugin also modifies the UI for the [WordReference plugin](https://github.com/kristianpennacchia/wordreference.koplugin) definition popup:

<p align="left">
  <img src="https://github.com/user-attachments/assets/f3daf3fe-acd9-4e33-8878-87a00b7e64df" width=45%>
</p>

## Install

- Download the [latest release](https://github.com/kristianpennacchia/zzz-readermenuredesign.koplugin/releases/latest).
- Unzip `zzz-readermenuredesign.koplugin.zip`.
- Copy the `zzz-readermenuredesign.koplugin` folder to your KOReader `plugins` directory on the device.
- Copy the icons into the equivalent folder in KOReader. E.g. `/koreader/resources/icons/mdlight`
- Restart KOReader.

#### Troubleshooting

- If the icons don't appear and you instead see 'hazard' symbols, try putting the icons directly into `/koreader/resources/icons` instead of `mdlight`.

## Settings

- Reader Highlight menu:
  - Open Menu → Tools 🛠️ → More tools → Reader Menu Redesign → Show Unknown Buttons In Reader Highlight Menu.
  - This will toggle showing/hiding the 'unknown' buttons (buttons without special handling in this plugin) in the Reader Highlight menu.
- Dict Quick Lookup:
  - Open Menu → Tools 🛠️ → More tools → Reader Menu Redesign → Show Nav Buttons In Dict Quick Lookup.
  - This will toggle showing/hiding the 'nav' buttons in the Dict Quick Lookup to navigate between dictionaries, wikipedia entires, etc.
  - Alternatively: You can simply swipe left-to-right to navigate instead, but these buttons are more useful for PC/Mac.
