# Story Structure

This page explains the structure of the Story in StoryTailor.

<tldr>
    <b>TL;DR</b>
    <p>The structure is as follows:</p>
    <p>StoryManager &rArr; Chapters &rArr; Branches &rArr; Dialogues</p>
</tldr>

The story object consists of four types in StoryTailor. Which are:
- StoryManager
- Chapters
- Branches
- Dialogues

**Implementation Stage:** Implemented

## StoryManager
StoryManager is a story object which basically, 
is the root of the story. This object is automatically created, 
you don't have to manage it yourself.

StoryManager is a list of Chapters.

## Chapters
Chapters are meant to be a way to organize text into different 
sections.

Chapters are a list of Branches. (Or a "Dictionary" to be precise.)

## Branches
Branches are made so that you can, well... branch your story into 
different paths according to the user's choice, variables, 
and stuff.

## Dialogues
This is pretty straightforward; Dialogues contains a text content, 
With optional events which allows you to create a choice for the 
user, show new characters, change backgrounds, etc.

