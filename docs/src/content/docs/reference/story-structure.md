---
title: Story Structure
description: The structure of the story in StoryTailor
---

The story is like a tree, and there are mainly four types 
of objects within the StoryTailor story tree. Including:

- StoryManager
- Chapters
- Branches
- Dialogues

## StoryManager

The StoryManager is the root of the tree, which stores 
a list of chapters.

Within your project's folder, The information about the 
StoryManager itself is stored in `Project/story/StoryManager.json`

It is forbidden to create a chapter named "StoryManager" 
due to the fact information about chapters are stored 
within the same folder.

## Chapters

Chapters are a way to organize your story into multiple 
major sections. A chapter stores information about branches 
and there *must* be a branch named "main", which represents 
the entry point of the chapter.

As mentioned above, The file storing the chapter's information 
is stored within the same folder as the StoryManager, in 
`Project/story/ChapterName.json`. The filename will not exactly 
match the chapter name you set within the editor as the chapter 
name is sanitized before it will be used as the filename, ensuring 
fewer issues with illegal filenames.

However, It is an undefined behaviour on how the editor will act 
when facing Windows' case-insensitive filesystem (Meaning that 
the filename `a.txt` and `A.txt` refers to the same file). So 
please be careful when working with multiple operating systems.
You can read more on the topic on [Microsoft's "Adjust case 
sensitivity" article](https://learn.microsoft.com/en-us/windows/wsl/case-sensitivity).

## Branches

Branches are smaller units to organize your dialogues in. Branch 
names should likely never be shown to players and are for 
organization purposes.

Unlike chapters or dialogues, Branches are not in a specific order 
and when a branch ends and there is no instruction to go to a specific 
branch next, The next chapter will be loaded, or the game ending will 
be triggered.

You can't remove the branch named "main" as it is the entry point 
of a chapter. You could however leave it empty, if you really do not 
need it.

Technically, you could actually delete the main branch by modifying 
the chapter's JSON file, but it is highly not recommended to do so.

## Dialogues

Dialogues are the actual story, storing the message you want to display 
in your game.

In the future, Dialogues might be changed to be called "Actions" instead,
To make it more similar to other scripts, such as Ren'Py scripts. And actions 
to show characters, change backgrounds, etc. will be in its own block of action.

