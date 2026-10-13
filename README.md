# RPG Farm Prototype

This project is a simple Godot 4.2 farming RPG prototype intended for Android phones. It uses placeholder art and focuses on core systems you requested:
- shops
- crafting
- seasonal crops
- stamina system
- planting, growing, and harvesting

Features included
- Player movement with stamina and sprinting
- Planting seeds into a small crop field
- Crop growth over time
- Harvesting and inventory updates
- Shop buying/selling items
- Crafting recipes
- Time/season cycle
- Save/load support
- Mobile-friendly touch buttons in the UI

Project structure
- project.godot
- scenes/Main.tscn
- scenes/Player.tscn
- scenes/Crop.tscn
- scripts/game.gd
- scripts/main.gd
- scripts/player.gd
- scripts/crop.gd
- art/*.svg

How to run in Godot
1. Open Godot 4.2.
2. Use "Import" and select this folder.
3. Open the project and run the Main scene.
4. Use:
   - WASD to move
   - Shift to sprint
   - E to plant and harvest
   - F to toggle shop
   - C to craft fertilizer

Android notes
- This is designed to be mobile friendly with touch buttons.
- For APK export, you still need the Android SDK and NDK configured in your local Godot setup.
- The project includes a simple UI with buttons, ready for touch input.

Notes
- Art is temporary placeholder SVGs and can be replaced when you provide final assets.
- The crop field is intentionally simple and small so you can expand it later.

Next steps
- Replace placeholder SVG art with your own sprites.
- Add more crop types and season-specific recipes.
- Add NPCs, quests, and larger maps.
- Build an APK for Android once your SDK is set up.
