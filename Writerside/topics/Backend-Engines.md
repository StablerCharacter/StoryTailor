# Backend Engines

<tldr>
    <b>TL;DR</b>
    <p>Use Flame Engine. Source: Trust me, bro.</p>
</tldr>

Backend Engines only matter when you decide to export your project 
into an executable. Currently, You can choose four backend engines in 
StoryTailor. It actually doesn't matter much which one you choose at 
the moment. **The preview is forced to be rendered in Flame Engine.**

The limitation of being only able to preview in Flame Engine might be 
removed in the future. However, It will only be removed in the PC version 
of the software because you can't just casually install compilers on 
Android without the help of special apps.

**Implementation Stage:** Partially Implemented

HaxeFlixel
: HaxeFlixel is a game engine made for the programming language "Haxe"
  StoryTailor will build your game on top of this framework.<br/>
  Supports native Windows, native macOS, native Linux, native iOS, 
  native Android, Adobe Flash\*, Adobe AIR, and Web.

Flame Engine (Recommended)
: Flame Engine is a game engine made for Flutter.
  It is recommended because it is what you will use when previewing your game.
  Supports Windows, macOS, Android, and iOS.

StablerCharacter.cs
: A C# implementation of the game engine in the StablerCharacter family.
  It is based on Raylib_cs. Only supports Windows, Linux, and macOS.

StablerCharacter.ts
: A TypeScript implementation of the game engine in the StablerCharacter family.
  This backend engine could possibly be the second backend engine to get support 
  for previewing the game right in the app because it's web based.
  Supports Web, Windows, macOS, and Linux. Could be built for Android and iOS 
  with extra workaround.

\*The Adobe Flash target is only there for testing. It's probably not a great 
idea to give out Flash games in this day and age where the support for it already 
ended a few years ago.

## What could possibly be implemented after those

RenPy
: A game engine popular for writing Visual Novels.
  Supports Android, Web, Linux, Windows, macOS, and iOS.

Godot
: A game engine often famous for its 2D capabilities.
  Supports Windows, macOS, Linux, Android, iOS, and Web.
